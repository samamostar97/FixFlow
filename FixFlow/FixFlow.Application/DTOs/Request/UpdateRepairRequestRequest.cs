using System.ComponentModel.DataAnnotations;

namespace FixFlow.Application.DTOs.Request;

public class UpdateRepairRequestRequest
{
    public int? CategoryId { get; set; }

    [StringLength(2000, MinimumLength = 10, ErrorMessage = "Opis mora imati između 10 i 2000 karaktera.")]
    public string? Description { get; set; }

    public int? PreferenceType { get; set; }

    public double? Latitude { get; set; }

    public double? Longitude { get; set; }

    [StringLength(500, ErrorMessage = "Adresa ne može biti duža od 500 karaktera.")]
    public string? Address { get; set; }
}
