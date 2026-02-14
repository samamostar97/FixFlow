using FixFlow.Application.Common;
using FixFlow.Application.DTOs.Request;
using FixFlow.Application.DTOs.Response;
using FixFlow.Application.Filters;

namespace FixFlow.Application.IServices;

public interface IBookingService
{
    Task<BookingResponse> CreateBookingFromOfferAsync(int offerId, int customerId);
    Task<BookingResponse> GetByIdAsync(int id);
    Task<BookingResponse> GetByIdForUserAsync(int id, int userId, string role);
    Task<PagedResult<BookingResponse>> GetAllAsync(BookingQueryFilter filter);
    Task<PagedResult<BookingResponse>> GetMyBookingsAsync(BookingQueryFilter filter, int userId, string role);
    Task<BookingResponse> UpdateJobStatusAsync(int bookingId, UpdateJobStatusRequest dto, int technicianId);
    Task<BookingResponse> UpdatePartsAsync(int bookingId, UpdateBookingPartsRequest dto, int technicianId);
}
