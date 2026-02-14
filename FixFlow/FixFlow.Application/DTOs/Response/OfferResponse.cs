using FixFlow.Core.Enums;

namespace FixFlow.Application.DTOs.Response;

public class OfferResponse
{
    public int Id { get; set; }

    public int RepairRequestId { get; set; }
    public string RepairRequestCategoryName { get; set; } = string.Empty;

    public int TechnicianId { get; set; }
    public string TechnicianFirstName { get; set; } = string.Empty;
    public string TechnicianLastName { get; set; } = string.Empty;

    public decimal Price { get; set; }
    public int EstimatedDays { get; set; }
    public ServiceType ServiceType { get; set; }
    public string? Note { get; set; }

    public OfferStatus Status { get; set; }

    public DateTime CreatedAt { get; set; }
}
