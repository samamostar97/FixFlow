namespace FixFlow.Application.DTOs.Response;

public class TechnicianProfileResponse
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public string UserFirstName { get; set; } = string.Empty;
    public string UserLastName { get; set; } = string.Empty;
    public string UserEmail { get; set; } = string.Empty;
    public string? UserPhone { get; set; }
    public string? Bio { get; set; }
    public string? Specialties { get; set; }
    public string? WorkingHours { get; set; }
    public string? Zone { get; set; }
    public bool IsVerified { get; set; }
    public double AverageRating { get; set; }
    public DateTime CreatedAt { get; set; }
}
