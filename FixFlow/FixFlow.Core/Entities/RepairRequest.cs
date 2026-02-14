using FixFlow.Core.Enums;

namespace FixFlow.Core.Entities;

public class RepairRequest : BaseEntity
{
    public int CategoryId { get; set; }
    public RepairCategory Category { get; set; } = null!;

    public int CustomerId { get; set; }
    public User Customer { get; set; } = null!;

    public string Description { get; set; } = string.Empty;
    public PreferenceType PreferenceType { get; set; }

    public double? Latitude { get; set; }
    public double? Longitude { get; set; }
    public string? Address { get; set; }

    public RepairRequestStatus Status { get; set; }

    public ICollection<RequestImage> Images { get; set; } = new List<RequestImage>();
    public ICollection<Offer> Offers { get; set; } = new List<Offer>();
    public Booking? Booking { get; set; }
}
