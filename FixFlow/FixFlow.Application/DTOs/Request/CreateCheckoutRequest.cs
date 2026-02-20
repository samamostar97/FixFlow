using System.ComponentModel.DataAnnotations;

namespace FixFlow.Application.DTOs.Request;

public class CreateCheckoutRequest
{
    [Required(ErrorMessage = "Booking je obavezan.")]
    public int BookingId { get; set; }
}
