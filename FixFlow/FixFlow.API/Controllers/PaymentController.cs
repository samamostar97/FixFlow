using FixFlow.API.Extensions;
using FixFlow.Application.DTOs.Request;
using FixFlow.Application.DTOs.Response;
using FixFlow.Application.Filters;
using FixFlow.Application.IServices;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FixFlow.API.Controllers;

[ApiController]
[Route("api/payments")]
public class PaymentController : ControllerBase
{
    private readonly IPaymentService _paymentService;

    public PaymentController(IPaymentService paymentService)
    {
        _paymentService = paymentService;
    }

    [HttpPost("checkout")]
    [Authorize(Roles = "Customer")]
    public async Task<ActionResult<CheckoutResponse>> CreateCheckout(
        [FromBody] CreateCheckoutRequest request)
    {
        var userId = User.GetRequiredUserId();
        var result = await _paymentService.CreatePaymentIntentAsync(request, userId);
        return Ok(result);
    }

    [HttpPost("confirm")]
    [Authorize(Roles = "Customer")]
    public async Task<ActionResult<PaymentResponse>> ConfirmPayment(
        [FromBody] ConfirmPaymentRequest request)
    {
        var userId = User.GetRequiredUserId();
        var result = await _paymentService.ConfirmPaymentAsync(request, userId);
        return Ok(result);
    }

    [HttpGet("booking/{bookingId}")]
    [Authorize]
    public async Task<ActionResult<PaymentResponse>> GetByBookingId(int bookingId)
    {
        var result = await _paymentService.GetByBookingIdAsync(bookingId);
        if (result == null) return NotFound();
        return Ok(result);
    }

    [HttpGet]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<List<PaymentResponse>>> GetAll(
        [FromQuery] PaymentQueryFilter filter)
    {
        var result = await _paymentService.GetAllAsync(filter);
        return Ok(result);
    }

    [HttpPost("refund")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<PaymentResponse>> Refund(
        [FromBody] CreateRefundRequest request)
    {
        var result = await _paymentService.RefundAsync(request);
        return Ok(result);
    }
}
