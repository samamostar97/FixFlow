using FixFlow.Core.Enums;

namespace FixFlow.Core.Entities;

public class Booking : BaseEntity
{
    public int RepairRequestId { get; set; }
    public RepairRequest RepairRequest { get; set; } = null!;

    public int OfferId { get; set; }
    public Offer Offer { get; set; } = null!;

    public int CustomerId { get; set; }
    public User Customer { get; set; } = null!;

    public int TechnicianId { get; set; }
    public User Technician { get; set; } = null!;

    public DateTime? ScheduledDate { get; set; }
    public TimeSpan? ScheduledTime { get; set; }

    public JobStatus JobStatus { get; set; }

    public string? PartsDescription { get; set; }
    public decimal? PartsCost { get; set; }

    public decimal TotalAmount { get; set; }

    public ICollection<JobStatusHistory> StatusHistory { get; set; } = new List<JobStatusHistory>();
}
