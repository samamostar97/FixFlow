namespace FixFlow.Core.Entities;

public class TechnicianProfile : BaseEntity
{
    public int UserId { get; set; }
    public User User { get; set; } = null!;

    public string? Bio { get; set; }
    public string? Specialties { get; set; }
    public string? WorkingHours { get; set; }
    public string? Zone { get; set; }
    public bool IsVerified { get; set; }
    public double AverageRating { get; set; }
}
