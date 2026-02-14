using FixFlow.Application.Common;
using FixFlow.Application.DTOs.Request;
using FixFlow.Application.DTOs.Response;
using FixFlow.Application.Exceptions;
using FixFlow.Application.Filters;
using FixFlow.Application.Helpers;
using FixFlow.Application.IRepositories;
using FixFlow.Application.IServices;
using FixFlow.Core.Entities;
using FixFlow.Core.Enums;
using Mapster;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace FixFlow.Infrastructure.Services;

public class BookingService : IBookingService
{
    private readonly IRepository<Booking> _bookingRepository;
    private readonly IRepository<JobStatusHistory> _statusHistoryRepository;
    private readonly IRepository<Offer> _offerRepository;
    private readonly IRepository<RepairRequest> _repairRequestRepository;
    private readonly ILogger<BookingService> _logger;

    public BookingService(
        IRepository<Booking> bookingRepository,
        IRepository<JobStatusHistory> statusHistoryRepository,
        IRepository<Offer> offerRepository,
        IRepository<RepairRequest> repairRequestRepository,
        ILogger<BookingService> logger)
    {
        _bookingRepository = bookingRepository;
        _statusHistoryRepository = statusHistoryRepository;
        _offerRepository = offerRepository;
        _repairRequestRepository = repairRequestRepository;
        _logger = logger;
    }

    public async Task<BookingResponse> CreateBookingFromOfferAsync(int offerId, int customerId)
    {
        var offer = await _offerRepository.AsQueryable()
            .Include(o => o.RepairRequest)
            .ThenInclude(r => r.Booking)
            .FirstOrDefaultAsync(o => o.Id == offerId)
            ?? throw new KeyNotFoundException("Ponuda nije pronadena.");

        if (offer.RepairRequest.CustomerId != customerId)
            throw new ForbiddenException("Nemate pravo kreirati booking za ovu ponudu.");

        if (offer.Status != OfferStatus.Accepted)
            throw new InvalidOperationException("Booking se moze kreirati samo za prihvacenu ponudu.");

        if (offer.RepairRequest.Booking != null)
            throw new ConflictException("Booking za ovaj zahtjev vec postoji.");

        var bookingExists = await _bookingRepository.AsQueryable()
            .AnyAsync(b => b.RepairRequestId == offer.RepairRequestId);
        if (bookingExists)
            throw new ConflictException("Booking za ovaj zahtjev vec postoji.");

        var booking = new Booking
        {
            RepairRequestId = offer.RepairRequestId,
            OfferId = offerId,
            CustomerId = customerId,
            TechnicianId = offer.TechnicianId,
            JobStatus = JobStatus.Received,
            TotalAmount = offer.Price,
        };

        try
        {
            await _bookingRepository.AddAsync(booking);
        }
        catch (DbUpdateException ex) when (IsUniqueConstraintViolation(ex))
        {
            throw new ConflictException("Booking za ovaj zahtjev vec postoji.");
        }

        await _statusHistoryRepository.AddAsync(new JobStatusHistory
        {
            BookingId = booking.Id,
            PreviousStatus = JobStatus.Received,
            NewStatus = JobStatus.Received,
            Note = "Posao kreiran.",
            ChangedById = customerId,
        });

        _logger.LogInformation("Booking {BookingId} created for offer {OfferId}, request {RequestId}",
            booking.Id, offerId, offer.RepairRequestId);

        return await GetByIdAsync(booking.Id);
    }

    public async Task<BookingResponse> GetByIdAsync(int id)
    {
        var booking = await BuildQuery()
            .FirstOrDefaultAsync(b => b.Id == id)
            ?? throw new KeyNotFoundException("Posao nije pronaden.");

        return booking.Adapt<BookingResponse>();
    }

    public async Task<BookingResponse> GetByIdForUserAsync(int id, int userId, string role)
    {
        var booking = await BuildQuery()
            .FirstOrDefaultAsync(b => b.Id == id)
            ?? throw new KeyNotFoundException("Posao nije pronaden.");

        if (string.Equals(role, "Admin", StringComparison.OrdinalIgnoreCase))
        {
            return booking.Adapt<BookingResponse>();
        }

        if (string.Equals(role, "Customer", StringComparison.OrdinalIgnoreCase))
        {
            if (booking.CustomerId != userId)
            {
                throw new ForbiddenException("Nemate pravo vidjeti ovaj posao.");
            }

            return booking.Adapt<BookingResponse>();
        }

        if (string.Equals(role, "Technician", StringComparison.OrdinalIgnoreCase))
        {
            if (booking.TechnicianId != userId)
            {
                throw new ForbiddenException("Nemate pravo vidjeti ovaj posao.");
            }

            return booking.Adapt<BookingResponse>();
        }

        throw new ForbiddenException("Nemate pravo vidjeti ovaj posao.");
    }

    public async Task<PagedResult<BookingResponse>> GetAllAsync(BookingQueryFilter filter)
    {
        var query = BuildQuery();
        query = ApplyFilter(query, filter);

        var totalCount = await query.CountAsync();
        var items = await query
            .Skip((filter.PageNumber - 1) * filter.PageSize)
            .Take(filter.PageSize)
            .ToListAsync();

        return new PagedResult<BookingResponse>
        {
            Items = items.Adapt<List<BookingResponse>>(),
            TotalCount = totalCount,
            PageNumber = filter.PageNumber,
            PageSize = filter.PageSize,
        };
    }

    public async Task<PagedResult<BookingResponse>> GetMyBookingsAsync(
        BookingQueryFilter filter, int userId, string role)
    {
        if (string.Equals(role, "Customer", StringComparison.OrdinalIgnoreCase))
        {
            filter.CustomerId = userId;
        }
        else if (string.Equals(role, "Technician", StringComparison.OrdinalIgnoreCase))
        {
            filter.TechnicianId = userId;
        }
        else if (!string.Equals(role, "Admin", StringComparison.OrdinalIgnoreCase))
        {
            throw new ForbiddenException("Nemate pravo vidjeti ove poslove.");
        }

        return await GetAllAsync(filter);
    }

    public async Task<BookingResponse> UpdateJobStatusAsync(
        int bookingId, UpdateJobStatusRequest dto, int technicianId)
    {
        var booking = await BuildQuery()
            .FirstOrDefaultAsync(b => b.Id == bookingId)
            ?? throw new KeyNotFoundException("Posao nije pronaden.");

        if (booking.TechnicianId != technicianId)
            throw new ForbiddenException("Nemate pravo mijenjati status ovog posla.");

        var newStatus = (JobStatus)dto.NewStatus;
        ValidateStatusTransition(booking.JobStatus, newStatus);

        var previousStatus = booking.JobStatus;
        booking.JobStatus = newStatus;
        await _bookingRepository.UpdateAsync(booking);

        await _statusHistoryRepository.AddAsync(new JobStatusHistory
        {
            BookingId = bookingId,
            PreviousStatus = previousStatus,
            NewStatus = newStatus,
            Note = dto.Note?.Trim(),
            ChangedById = technicianId,
        });

        await SyncRepairRequestStatusAsync(booking.RepairRequestId, newStatus);

        _logger.LogInformation("Booking {BookingId} status changed from {Previous} to {New} by technician {TechnicianId}",
            bookingId, previousStatus, newStatus, technicianId);

        return await GetByIdAsync(bookingId);
    }

    public async Task<BookingResponse> UpdatePartsAsync(
        int bookingId, UpdateBookingPartsRequest dto, int technicianId)
    {
        var booking = await BuildQuery()
            .FirstOrDefaultAsync(b => b.Id == bookingId)
            ?? throw new KeyNotFoundException("Posao nije pronaden.");

        if (booking.TechnicianId != technicianId)
            throw new ForbiddenException("Nemate pravo mijenjati ovaj posao.");

        if (booking.JobStatus != JobStatus.Diagnostics)
            throw new InvalidOperationException("Dijelovi se mogu dodati samo tokom dijagnostike.");

        booking.PartsDescription = dto.PartsDescription.Trim();
        booking.PartsCost = dto.PartsCost;
        booking.TotalAmount = booking.Offer.Price + dto.PartsCost;
        await _bookingRepository.UpdateAsync(booking);

        _logger.LogInformation("Parts added to booking {BookingId}: {PartsCost} KM", bookingId, dto.PartsCost);

        return await GetByIdAsync(bookingId);
    }

    private IQueryable<Booking> BuildQuery()
    {
        return _bookingRepository.AsQueryable()
            .Include(b => b.RepairRequest).ThenInclude(r => r.Category)
            .Include(b => b.Offer)
            .Include(b => b.Customer)
            .Include(b => b.Technician)
            .Include(b => b.StatusHistory).ThenInclude(h => h.ChangedBy);
    }

    private IQueryable<Booking> ApplyFilter(IQueryable<Booking> query, BookingQueryFilter filter)
    {
        return query
            .WhereIf(!string.IsNullOrWhiteSpace(filter.Search),
                b => b.Customer.FirstName.ToLower().Contains(filter.Search!.ToLower())
                    || b.Customer.LastName.ToLower().Contains(filter.Search!.ToLower())
                    || b.Technician.FirstName.ToLower().Contains(filter.Search!.ToLower())
                    || b.Technician.LastName.ToLower().Contains(filter.Search!.ToLower()))
            .WhereIf(filter.JobStatus.HasValue, b => b.JobStatus == filter.JobStatus)
            .WhereIf(filter.CustomerId.HasValue, b => b.CustomerId == filter.CustomerId)
            .WhereIf(filter.TechnicianId.HasValue, b => b.TechnicianId == filter.TechnicianId)
            .OrderByDescending(b => b.CreatedAt);
    }

    private static void ValidateStatusTransition(JobStatus current, JobStatus next)
    {
        var allowed = current switch
        {
            JobStatus.Received => new[] { JobStatus.Diagnostics },
            JobStatus.Diagnostics => new[] { JobStatus.WaitingForPart, JobStatus.Repaired },
            JobStatus.WaitingForPart => new[] { JobStatus.Repaired },
            JobStatus.Repaired => new[] { JobStatus.Completed },
            _ => Array.Empty<JobStatus>()
        };

        if (!allowed.Contains(next))
            throw new InvalidOperationException($"Nije moguce promijeniti status sa {current} na {next}.");
    }

    private async Task SyncRepairRequestStatusAsync(int repairRequestId, JobStatus newJobStatus)
    {
        var request = await _repairRequestRepository.GetByIdAsync(repairRequestId);
        if (request == null) return;

        if (newJobStatus == JobStatus.Diagnostics && request.Status == RepairRequestStatus.Accepted)
        {
            request.Status = RepairRequestStatus.InProgress;
            await _repairRequestRepository.UpdateAsync(request);
        }
        else if (newJobStatus == JobStatus.Completed)
        {
            request.Status = RepairRequestStatus.Completed;
            await _repairRequestRepository.UpdateAsync(request);
        }
    }

    private static bool IsUniqueConstraintViolation(DbUpdateException exception)
    {
        if (exception.InnerException is SqlException sqlException)
        {
            return sqlException.Number is 2601 or 2627;
        }

        var message = exception.InnerException?.Message ?? exception.Message;
        return message.Contains("IX_Bookings_RepairRequestId", StringComparison.OrdinalIgnoreCase)
               || message.Contains("UNIQUE", StringComparison.OrdinalIgnoreCase)
               || message.Contains("duplicate", StringComparison.OrdinalIgnoreCase);
    }
}