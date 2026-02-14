using System.Data;
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
using FixFlow.Infrastructure.Data;
using Mapster;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace FixFlow.Infrastructure.Services;

public class OfferService
    : BaseService<Offer, OfferResponse, CreateOfferRequest,
        UpdateOfferRequest, OfferQueryFilter>,
      IOfferService
{
    private readonly IRepository<RepairRequest> _repairRequestRepository;
    private readonly IBookingService _bookingService;
    private readonly FixFlowDbContext _dbContext;
    private readonly ILogger<OfferService> _logger;

    public OfferService(
        IRepository<Offer> repository,
        IRepository<RepairRequest> repairRequestRepository,
        IBookingService bookingService,
        FixFlowDbContext dbContext,
        ILogger<OfferService> logger) : base(repository)
    {
        _repairRequestRepository = repairRequestRepository;
        _bookingService = bookingService;
        _dbContext = dbContext;
        _logger = logger;
    }

    protected override IQueryable<Offer> ApplyFilter(IQueryable<Offer> query, OfferQueryFilter filter)
    {
        return query
            .Include(o => o.RepairRequest).ThenInclude(r => r.Category)
            .Include(o => o.Technician)
            .WhereIf(!string.IsNullOrWhiteSpace(filter.Search),
                o => o.Technician.FirstName.ToLower().Contains(filter.Search!.ToLower())
                    || o.Technician.LastName.ToLower().Contains(filter.Search!.ToLower())
                    || (o.Note != null && o.Note.ToLower().Contains(filter.Search!.ToLower())))
            .WhereIf(filter.Status.HasValue, o => o.Status == filter.Status)
            .WhereIf(filter.ServiceType.HasValue, o => o.ServiceType == filter.ServiceType)
            .WhereIf(filter.RepairRequestId.HasValue, o => o.RepairRequestId == filter.RepairRequestId)
            .WhereIf(filter.TechnicianId.HasValue, o => o.TechnicianId == filter.TechnicianId)
            .OrderByDescending(o => o.CreatedAt);
    }

    public override async Task<OfferResponse> GetByIdAsync(int id)
    {
        var entity = await _repository.AsQueryable()
            .Include(o => o.RepairRequest).ThenInclude(r => r.Category)
            .Include(o => o.Technician)
            .FirstOrDefaultAsync(o => o.Id == id)
            ?? throw new KeyNotFoundException("Ponuda nije pronadena.");

        return entity.Adapt<OfferResponse>();
    }

    public async Task<OfferResponse> GetByIdForUserAsync(int id, int userId, string role)
    {
        var entity = await _repository.AsQueryable()
            .Include(o => o.RepairRequest).ThenInclude(r => r.Category)
            .Include(o => o.Technician)
            .FirstOrDefaultAsync(o => o.Id == id)
            ?? throw new KeyNotFoundException("Ponuda nije pronadena.");

        if (string.Equals(role, "Admin", StringComparison.OrdinalIgnoreCase))
        {
            return entity.Adapt<OfferResponse>();
        }

        if (string.Equals(role, "Customer", StringComparison.OrdinalIgnoreCase))
        {
            if (entity.RepairRequest.CustomerId != userId)
            {
                throw new ForbiddenException("Nemate pravo vidjeti ovu ponudu.");
            }

            return entity.Adapt<OfferResponse>();
        }

        if (string.Equals(role, "Technician", StringComparison.OrdinalIgnoreCase))
        {
            if (entity.TechnicianId != userId)
            {
                throw new ForbiddenException("Nemate pravo vidjeti ovu ponudu.");
            }

            return entity.Adapt<OfferResponse>();
        }

        throw new ForbiddenException("Nemate pravo vidjeti ovu ponudu.");
    }

    public async Task<OfferResponse> CreateOfferAsync(CreateOfferRequest dto, int technicianId)
    {
        var request = await _repairRequestRepository.AsQueryable()
            .FirstOrDefaultAsync(r => r.Id == dto.RepairRequestId)
            ?? throw new KeyNotFoundException("Zahtjev za popravku nije pronaden.");

        if (request.Status != RepairRequestStatus.Open && request.Status != RepairRequestStatus.Offered)
            throw new InvalidOperationException("Zahtjev vise ne prima ponude.");

        var alreadyOffered = await _repository.AsQueryable()
            .AnyAsync(o => o.RepairRequestId == dto.RepairRequestId && o.TechnicianId == technicianId);
        if (alreadyOffered)
            throw new ConflictException("Vec ste poslali ponudu za ovaj zahtjev.");

        var entity = dto.Adapt<Offer>();
        entity.TechnicianId = technicianId;
        entity.Status = OfferStatus.Pending;
        if (dto.Note != null) entity.Note = dto.Note.Trim();

        await _repository.AddAsync(entity);

        if (request.Status == RepairRequestStatus.Open)
        {
            request.Status = RepairRequestStatus.Offered;
            await _repairRequestRepository.UpdateAsync(request);
        }

        _logger.LogInformation("Offer {OfferId} created for request {RequestId} by technician {TechnicianId}",
            entity.Id, dto.RepairRequestId, technicianId);

        return await GetByIdAsync(entity.Id);
    }

    public async Task<OfferResponse> UpdateOfferAsync(int id, UpdateOfferRequest dto, int technicianId)
    {
        var entity = await _repository.AsQueryable()
            .Include(o => o.RepairRequest).ThenInclude(r => r.Category)
            .Include(o => o.Technician)
            .FirstOrDefaultAsync(o => o.Id == id)
            ?? throw new KeyNotFoundException("Ponuda nije pronadena.");

        if (entity.TechnicianId != technicianId)
            throw new ForbiddenException("Nemate pravo mijenjati ovu ponudu.");

        if (entity.Status != OfferStatus.Pending)
            throw new InvalidOperationException("Ponuda se moze mijenjati samo dok je na cekanju.");

        dto.Adapt(entity);
        if (dto.Note != null) entity.Note = dto.Note.Trim();

        await _repository.UpdateAsync(entity);

        return entity.Adapt<OfferResponse>();
    }

    public async Task<PagedResult<OfferResponse>> GetMyOffersAsync(OfferQueryFilter filter, int technicianId)
    {
        filter.TechnicianId = technicianId;
        return await GetAllAsync(filter);
    }

    public async Task<List<OfferResponse>> GetOffersForRequestAsync(int requestId, int customerId)
    {
        var request = await _repairRequestRepository.GetByIdAsync(requestId)
            ?? throw new KeyNotFoundException("Zahtjev za popravku nije pronaden.");

        if (request.CustomerId != customerId)
            throw new ForbiddenException("Nemate pravo vidjeti ponude za ovaj zahtjev.");

        var offers = await _repository.AsQueryable()
            .Include(o => o.RepairRequest).ThenInclude(r => r.Category)
            .Include(o => o.Technician)
            .Where(o => o.RepairRequestId == requestId)
            .OrderByDescending(o => o.CreatedAt)
            .ToListAsync();

        return offers.Adapt<List<OfferResponse>>();
    }

    public async Task<OfferResponse> AcceptOfferAsync(int offerId, int customerId)
    {
        await using var transaction = await _dbContext.Database.BeginTransactionAsync(IsolationLevel.Serializable);

        try
        {
            var offer = await _repository.AsQueryable()
                .Include(o => o.RepairRequest)
                .ThenInclude(r => r.Category)
                .Include(o => o.Technician)
                .FirstOrDefaultAsync(o => o.Id == offerId)
                ?? throw new KeyNotFoundException("Ponuda nije pronadena.");

            var request = await _repairRequestRepository.AsQueryable()
                .Include(r => r.Booking)
                .FirstOrDefaultAsync(r => r.Id == offer.RepairRequestId)
                ?? throw new KeyNotFoundException("Zahtjev za popravku nije pronaden.");

            if (request.CustomerId != customerId)
                throw new ForbiddenException("Nemate pravo prihvatiti ovu ponudu.");

            if (request.Booking != null)
                throw new ConflictException("Booking za ovaj zahtjev vec postoji.");

            if (offer.Status != OfferStatus.Pending)
                throw new InvalidOperationException("Samo ponude na cekanju se mogu prihvatiti.");

            if (request.Status != RepairRequestStatus.Open && request.Status != RepairRequestStatus.Offered)
                throw new InvalidOperationException("Zahtjev vise ne prima ponude.");

            offer.Status = OfferStatus.Accepted;
            await _repository.UpdateAsync(offer);

            request.Status = RepairRequestStatus.Accepted;
            await _repairRequestRepository.UpdateAsync(request);

            var otherOffers = await _repository.AsQueryable()
                .Where(o => o.RepairRequestId == request.Id
                            && o.Id != offerId
                            && o.Status == OfferStatus.Pending)
                .ToListAsync();

            foreach (var other in otherOffers)
            {
                other.Status = OfferStatus.Rejected;
                await _repository.UpdateAsync(other);
            }

            await _bookingService.CreateBookingFromOfferAsync(offerId, customerId);

            await transaction.CommitAsync();

            _logger.LogInformation("Offer {OfferId} accepted for request {RequestId} by customer {CustomerId}",
                offerId, request.Id, customerId);

            return await GetByIdAsync(offerId);
        }
        catch (DbUpdateException ex) when (IsUniqueConstraintViolation(ex))
        {
            await transaction.RollbackAsync();
            throw new ConflictException("Booking za ovaj zahtjev vec postoji.");
        }
        catch
        {
            await transaction.RollbackAsync();
            throw;
        }
    }

    public async Task<OfferResponse> WithdrawOfferAsync(int offerId, int technicianId)
    {
        var entity = await _repository.AsQueryable()
            .Include(o => o.RepairRequest).ThenInclude(r => r.Category)
            .Include(o => o.Technician)
            .FirstOrDefaultAsync(o => o.Id == offerId)
            ?? throw new KeyNotFoundException("Ponuda nije pronadena.");

        if (entity.TechnicianId != technicianId)
            throw new ForbiddenException("Nemate pravo povuci ovu ponudu.");

        if (entity.Status != OfferStatus.Pending)
            throw new InvalidOperationException("Samo ponude na cekanju se mogu povuci.");

        entity.Status = OfferStatus.Withdrawn;
        await _repository.UpdateAsync(entity);

        _logger.LogInformation("Offer {OfferId} withdrawn by technician {TechnicianId}", offerId, technicianId);

        return entity.Adapt<OfferResponse>();
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