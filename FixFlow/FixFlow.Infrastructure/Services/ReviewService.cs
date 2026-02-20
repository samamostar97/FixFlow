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

public class ReviewService : IReviewService
{
    private readonly IRepository<Review> _reviewRepository;
    private readonly IRepository<Booking> _bookingRepository;
    private readonly IRepository<TechnicianProfile> _technicianProfileRepository;
    private readonly ILogger<ReviewService> _logger;

    public ReviewService(
        IRepository<Review> reviewRepository,
        IRepository<Booking> bookingRepository,
        IRepository<TechnicianProfile> technicianProfileRepository,
        ILogger<ReviewService> logger)
    {
        _reviewRepository = reviewRepository;
        _bookingRepository = bookingRepository;
        _technicianProfileRepository = technicianProfileRepository;
        _logger = logger;
    }

    public async Task<ReviewResponse> CreateAsync(CreateReviewRequest dto, int customerId)
    {
        var booking = await _bookingRepository.AsQueryable()
            .FirstOrDefaultAsync(b => b.Id == dto.BookingId)
            ?? throw new KeyNotFoundException("Posao nije pronaden.");

        if (booking.CustomerId != customerId)
            throw new ForbiddenException("Nemate pravo ostaviti ocjenu za ovaj posao.");

        if (booking.JobStatus != JobStatus.Completed)
            throw new InvalidOperationException("Ocjena se moze ostaviti samo za zavrsene poslove.");

        var alreadyReviewed = await _reviewRepository.AsQueryable()
            .AnyAsync(r => r.BookingId == dto.BookingId);
        if (alreadyReviewed)
            throw new ConflictException("Vec ste ostavili ocjenu za ovaj posao.");

        var review = new Review
        {
            BookingId = dto.BookingId,
            CustomerId = customerId,
            TechnicianId = booking.TechnicianId,
            Rating = dto.Rating,
            Comment = dto.Comment?.Trim(),
        };

        try
        {
            await _reviewRepository.AddAsync(review);
        }
        catch (DbUpdateException ex) when (IsUniqueConstraintViolation(ex))
        {
            throw new ConflictException("Vec ste ostavili ocjenu za ovaj posao.");
        }

        await UpdateTechnicianAverageRatingAsync(booking.TechnicianId);

        _logger.LogInformation("Review {ReviewId} created for booking {BookingId} by customer {CustomerId}",
            review.Id, dto.BookingId, customerId);

        return await GetByIdAsync(review.Id);
    }

    public async Task<ReviewResponse?> GetByBookingIdAsync(int bookingId)
    {
        var review = await BuildQuery()
            .FirstOrDefaultAsync(r => r.BookingId == bookingId);

        return review?.Adapt<ReviewResponse>();
    }

    public async Task<PagedResult<ReviewResponse>> GetForTechnicianAsync(
        int technicianId, ReviewQueryFilter filter)
    {
        filter.TechnicianId = technicianId;
        return await GetAllAsync(filter);
    }

    public async Task<PagedResult<ReviewResponse>> GetAllAsync(ReviewQueryFilter filter)
    {
        var query = BuildQuery();
        query = ApplyFilter(query, filter);

        var totalCount = await query.CountAsync();
        var items = await query
            .Skip((filter.PageNumber - 1) * filter.PageSize)
            .Take(filter.PageSize)
            .ToListAsync();

        return new PagedResult<ReviewResponse>
        {
            Items = items.Adapt<List<ReviewResponse>>(),
            TotalCount = totalCount,
            PageNumber = filter.PageNumber,
            PageSize = filter.PageSize,
        };
    }

    private async Task<ReviewResponse> GetByIdAsync(int id)
    {
        var review = await BuildQuery()
            .FirstOrDefaultAsync(r => r.Id == id)
            ?? throw new KeyNotFoundException("Ocjena nije pronadena.");

        return review.Adapt<ReviewResponse>();
    }

    private IQueryable<Review> BuildQuery()
    {
        return _reviewRepository.AsQueryable()
            .Include(r => r.Customer)
            .Include(r => r.Technician);
    }

    private IQueryable<Review> ApplyFilter(IQueryable<Review> query, ReviewQueryFilter filter)
    {
        return query
            .WhereIf(filter.TechnicianId.HasValue, r => r.TechnicianId == filter.TechnicianId)
            .WhereIf(filter.CustomerId.HasValue, r => r.CustomerId == filter.CustomerId)
            .WhereIf(filter.MinRating.HasValue, r => r.Rating >= filter.MinRating)
            .OrderByDescending(r => r.CreatedAt);
    }

    private async Task UpdateTechnicianAverageRatingAsync(int technicianId)
    {
        var avgRating = await _reviewRepository.AsQueryable()
            .Where(r => r.TechnicianId == technicianId)
            .AverageAsync(r => (double?)r.Rating) ?? 0;

        var profile = await _technicianProfileRepository.AsQueryable()
            .FirstOrDefaultAsync(p => p.UserId == technicianId);

        if (profile != null)
        {
            profile.AverageRating = Math.Round(avgRating, 2);
            await _technicianProfileRepository.UpdateAsync(profile);
        }
    }

    private static bool IsUniqueConstraintViolation(DbUpdateException exception)
    {
        if (exception.InnerException is SqlException sqlException)
        {
            return sqlException.Number is 2601 or 2627;
        }

        var message = exception.InnerException?.Message ?? exception.Message;
        return message.Contains("IX_Reviews_BookingId", StringComparison.OrdinalIgnoreCase)
               || message.Contains("UNIQUE", StringComparison.OrdinalIgnoreCase)
               || message.Contains("duplicate", StringComparison.OrdinalIgnoreCase);
    }
}
