using FixFlow.Core.Enums;

namespace FixFlow.Core.Entities;

public class JobStatusHistory : BaseEntity
{
    public int BookingId { get; set; }
    public Booking Booking { get; set; } = null!;

    public JobStatus PreviousStatus { get; set; }
    public JobStatus NewStatus { get; set; }

    public string? Note { get; set; }

    public int ChangedById { get; set; }
    public User ChangedBy { get; set; } = null!;
}
