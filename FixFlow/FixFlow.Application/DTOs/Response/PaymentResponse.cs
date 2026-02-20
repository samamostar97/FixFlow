using FixFlow.Core.Enums;

namespace FixFlow.Application.DTOs.Response;

public class PaymentResponse
{
    public int Id { get; set; }
    public int BookingId { get; set; }
    public int UserId { get; set; }
    public string UserFirstName { get; set; } = string.Empty;
    public string UserLastName { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public PaymentType Type { get; set; }
    public PaymentStatus Status { get; set; }
    public string? StripePaymentIntentId { get; set; }
    public string? StripeSessionId { get; set; }
    public DateTime CreatedAt { get; set; }
}
