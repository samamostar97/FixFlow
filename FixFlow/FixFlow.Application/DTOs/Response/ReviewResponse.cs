namespace FixFlow.Application.DTOs.Response;

public class ReviewResponse
{
    public int Id { get; set; }

    public int BookingId { get; set; }

    public int CustomerId { get; set; }
    public string CustomerFirstName { get; set; } = string.Empty;
    public string CustomerLastName { get; set; } = string.Empty;

    public int TechnicianId { get; set; }
    public string TechnicianFirstName { get; set; } = string.Empty;
    public string TechnicianLastName { get; set; } = string.Empty;

    public int Rating { get; set; }
    public string? Comment { get; set; }

    public DateTime CreatedAt { get; set; }
}
