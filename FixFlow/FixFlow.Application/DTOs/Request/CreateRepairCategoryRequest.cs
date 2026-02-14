using System.ComponentModel.DataAnnotations;

namespace FixFlow.Application.DTOs.Request;

public class CreateRepairCategoryRequest
{
    [Required(ErrorMessage = "Naziv kategorije je obavezan.")]
    [StringLength(100, MinimumLength = 2, ErrorMessage = "Naziv mora imati između 2 i 100 karaktera.")]
    public string Name { get; set; } = string.Empty;
}
