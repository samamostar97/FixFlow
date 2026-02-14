using System.ComponentModel.DataAnnotations;
using FixFlow.Core.Enums;

namespace FixFlow.Application.DTOs.Request;

public class RegisterRequest
{
    [Required(ErrorMessage = "Email je obavezan.")]
    [EmailAddress(ErrorMessage = "Email format nije validan.")]
    [StringLength(256, ErrorMessage = "Email ne može biti duži od 256 karaktera.")]
    public string Email { get; set; } = string.Empty;

    [Required(ErrorMessage = "Lozinka je obavezna.")]
    [StringLength(100, MinimumLength = 6, ErrorMessage = "Lozinka mora imati najmanje 6 karaktera.")]
    public string Password { get; set; } = string.Empty;

    [Required(ErrorMessage = "Ime je obavezno.")]
    [StringLength(100, MinimumLength = 2, ErrorMessage = "Ime mora imati između 2 i 100 karaktera.")]
    public string FirstName { get; set; } = string.Empty;

    [Required(ErrorMessage = "Prezime je obavezno.")]
    [StringLength(100, MinimumLength = 2, ErrorMessage = "Prezime mora imati između 2 i 100 karaktera.")]
    public string LastName { get; set; } = string.Empty;

    [Phone(ErrorMessage = "Broj telefona nije validan.")]
    [StringLength(20, ErrorMessage = "Broj telefona ne može biti duži od 20 karaktera.")]
    public string? Phone { get; set; }

    [Required(ErrorMessage = "Uloga je obavezna.")]
    public UserRole Role { get; set; }
}
