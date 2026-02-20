using FixFlow.Application.Common;
using FixFlow.Application.DTOs.Request;
using FixFlow.Application.DTOs.Response;
using FixFlow.Application.Filters;

namespace FixFlow.Application.IServices;

public interface IReviewService
{
    Task<ReviewResponse> CreateAsync(CreateReviewRequest dto, int customerId);
    Task<ReviewResponse?> GetByBookingIdAsync(int bookingId);
    Task<PagedResult<ReviewResponse>> GetForTechnicianAsync(int technicianId, ReviewQueryFilter filter);
    Task<PagedResult<ReviewResponse>> GetAllAsync(ReviewQueryFilter filter);
}
