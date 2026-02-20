namespace FixFlow.Core.Entities;

public class Review : BaseEntity
{
    public int BookingId { get; set; }
    public Booking Booking { get; set; } = null!;

    public int CustomerId { get; set; }
    public User Customer { get; set; } = null!;

    public int TechnicianId { get; set; }
    public User Technician { get; set; } = null!;

    public int Rating { get; set; }
    public string? Comment { get; set; }
}
