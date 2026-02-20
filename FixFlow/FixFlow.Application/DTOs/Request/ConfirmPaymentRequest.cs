using System.ComponentModel.DataAnnotations;

namespace FixFlow.Application.DTOs.Request;

public class ConfirmPaymentRequest
{
    [Required(ErrorMessage = "Booking je obavezan.")]
    public int BookingId { get; set; }

    [Required(ErrorMessage = "Stripe PaymentIntent ID je obavezan.")]
    public string PaymentIntentId { get; set; } = string.Empty;
}
