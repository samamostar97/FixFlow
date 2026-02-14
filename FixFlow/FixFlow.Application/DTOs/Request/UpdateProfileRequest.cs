using System.ComponentModel.DataAnnotations;

namespace FixFlow.Application.DTOs.Request;

public class UpdateProfileRequest
{
    [StringLength(100, MinimumLength = 2, ErrorMessage = "Ime mora imati između 2 i 100 karaktera.")]
    public string? FirstName { get; set; }

    [StringLength(100, MinimumLength = 2, ErrorMessage = "Prezime mora imati između 2 i 100 karaktera.")]
    public string? LastName { get; set; }

    [Phone(ErrorMessage = "Broj telefona nije validan.")]
    [StringLength(20, ErrorMessage = "Broj telefona ne može biti duži od 20 karaktera.")]
    public string? Phone { get; set; }

    [StringLength(500, ErrorMessage = "Putanja slike ne može biti duža od 500 karaktera.")]
    public string? ProfileImage { get; set; }
}
