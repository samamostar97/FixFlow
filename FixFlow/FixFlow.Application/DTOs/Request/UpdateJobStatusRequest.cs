using System.ComponentModel.DataAnnotations;

namespace FixFlow.Application.DTOs.Request;

public class UpdateJobStatusRequest
{
    [Required(ErrorMessage = "Novi status je obavezan.")]
    public int NewStatus { get; set; }

    [StringLength(500, ErrorMessage = "Napomena ne može biti duža od 500 karaktera.")]
    public string? Note { get; set; }
}
