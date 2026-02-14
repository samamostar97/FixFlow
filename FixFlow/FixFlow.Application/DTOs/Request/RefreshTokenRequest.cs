using System.ComponentModel.DataAnnotations;

namespace FixFlow.Application.DTOs.Request;

public class RefreshTokenRequest
{
    [Required(ErrorMessage = "Token je obavezan.")]
    public string Token { get; set; } = string.Empty;
}
