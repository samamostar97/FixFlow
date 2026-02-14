using FixFlow.Core.Enums;

namespace FixFlow.Core.Entities;

public class Offer : BaseEntity
{
    public int RepairRequestId { get; set; }
    public RepairRequest RepairRequest { get; set; } = null!;

    public int TechnicianId { get; set; }
    public User Technician { get; set; } = null!;

    public decimal Price { get; set; }
    public int EstimatedDays { get; set; }
    public ServiceType ServiceType { get; set; }
    public string? Note { get; set; }

    public OfferStatus Status { get; set; }
}
