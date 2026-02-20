using FixFlow.Application.Common;
using FixFlow.Application.DTOs.Request;
using FixFlow.Application.DTOs.Response;
using FixFlow.Application.Filters;

namespace FixFlow.Application.IServices;

public interface IPaymentService
{
    Task<CheckoutResponse> CreatePaymentIntentAsync(CreateCheckoutRequest request, int userId);
    Task<PaymentResponse> ConfirmPaymentAsync(ConfirmPaymentRequest request, int userId);
    Task<PaymentResponse?> GetByBookingIdAsync(int bookingId);
    Task<PagedResult<PaymentResponse>> GetAllAsync(PaymentQueryFilter filter);
    Task<PaymentResponse> RefundAsync(CreateRefundRequest request);
}
