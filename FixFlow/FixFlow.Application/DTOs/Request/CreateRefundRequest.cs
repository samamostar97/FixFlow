using System.ComponentModel.DataAnnotations;

namespace FixFlow.Application.DTOs.Request;

public class CreateRefundRequest
{
    [Required(ErrorMessage = "ID uplate je obavezan.")]
    public int PaymentId { get; set; }

    [StringLength(500, ErrorMessage = "Razlog ne moze biti duzi od 500 karaktera.")]
    public string? Reason { get; set; }
}
