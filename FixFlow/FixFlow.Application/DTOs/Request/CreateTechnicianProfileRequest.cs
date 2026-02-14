using System.ComponentModel.DataAnnotations;

namespace FixFlow.Application.DTOs.Request;

public class CreateTechnicianProfileRequest
{
    [Required(ErrorMessage = "Korisnik je obavezan.")]
    public int UserId { get; set; }

    [StringLength(1000, ErrorMessage = "Biografija ne može biti duža od 1000 karaktera.")]
    public string? Bio { get; set; }

    [StringLength(500, ErrorMessage = "Specijalnosti ne mogu biti duže od 500 karaktera.")]
    public string? Specialties { get; set; }

    [StringLength(200, ErrorMessage = "Radno vrijeme ne može biti duže od 200 karaktera.")]
    public string? WorkingHours { get; set; }

    [StringLength(200, ErrorMessage = "Zona ne može biti duža od 200 karaktera.")]
    public string? Zone { get; set; }
}
