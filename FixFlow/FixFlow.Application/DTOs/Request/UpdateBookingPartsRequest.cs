using System.ComponentModel.DataAnnotations;

namespace FixFlow.Application.DTOs.Request;

public class UpdateBookingPartsRequest
{
    [Required(ErrorMessage = "Opis dijela je obavezan.")]
    [StringLength(1000, MinimumLength = 2, ErrorMessage = "Opis dijela mora imati između 2 i 1000 karaktera.")]
    public string PartsDescription { get; set; } = string.Empty;

    [Required(ErrorMessage = "Cijena dijela je obavezna.")]
    [Range(0.01, 100000, ErrorMessage = "Cijena dijela mora biti između 0.01 i 100,000.")]
    public decimal PartsCost { get; set; }
}
