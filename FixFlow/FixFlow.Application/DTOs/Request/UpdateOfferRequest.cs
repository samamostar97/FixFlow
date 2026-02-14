using System.ComponentModel.DataAnnotations;

namespace FixFlow.Application.DTOs.Request;

public class UpdateOfferRequest
{
    [Range(0.01, 100000, ErrorMessage = "Cijena mora biti između 0.01 i 100,000.")]
    public decimal? Price { get; set; }

    [Range(1, 365, ErrorMessage = "Broj dana mora biti između 1 i 365.")]
    public int? EstimatedDays { get; set; }

    public int? ServiceType { get; set; }

    [StringLength(1000, ErrorMessage = "Napomena ne može biti duža od 1000 karaktera.")]
    public string? Note { get; set; }
}
