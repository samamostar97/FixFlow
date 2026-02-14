using FixFlow.Core.Enums;

namespace FixFlow.Application.DTOs.Response;

public class UserResponse
{
    public int Id { get; set; }
    public string Email { get; set; } = string.Empty;
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string? Phone { get; set; }
    public UserRole Role { get; set; }
    public string? ProfileImage { get; set; }
    public DateTime CreatedAt { get; set; }
}
