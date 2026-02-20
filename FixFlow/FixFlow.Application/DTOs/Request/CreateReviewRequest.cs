using System.ComponentModel.DataAnnotations;

namespace FixFlow.Application.DTOs.Request;

public class CreateReviewRequest
{
    [Required(ErrorMessage = "Booking je obavezan.")]
    public int BookingId { get; set; }

    [Required(ErrorMessage = "Ocjena je obavezna.")]
    [Range(1, 5, ErrorMessage = "Ocjena mora biti između 1 i 5.")]
    public int Rating { get; set; }

    [StringLength(1000, ErrorMessage = "Komentar može imati najviše 1000 karaktera.")]
    public string? Comment { get; set; }
}
