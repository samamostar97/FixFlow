using FixFlow.Core.Enums;

namespace FixFlow.Core.Entities;

public class Payment : BaseEntity
{
    public int BookingId { get; set; }
    public Booking Booking { get; set; } = null!;

    public int UserId { get; set; }
    public User User { get; set; } = null!;

    public decimal Amount { get; set; }
    public PaymentType Type { get; set; }
    public PaymentStatus Status { get; set; }

    public string? StripePaymentIntentId { get; set; }
    public string? StripeSessionId { get; set; }
}
