using FixFlow.Core.Enums;

namespace FixFlow.Application.DTOs.Response;

public class BookingResponse
{
    public int Id { get; set; }

    public int RepairRequestId { get; set; }
    public string RepairRequestDescription { get; set; } = string.Empty;
    public string RepairRequestCategoryName { get; set; } = string.Empty;

    public int OfferId { get; set; }
    public decimal OfferPrice { get; set; }
    public int OfferEstimatedDays { get; set; }
    public ServiceType OfferServiceType { get; set; }

    public int CustomerId { get; set; }
    public string CustomerFirstName { get; set; } = string.Empty;
    public string CustomerLastName { get; set; } = string.Empty;
    public string? CustomerPhone { get; set; }

    public int TechnicianId { get; set; }
    public string TechnicianFirstName { get; set; } = string.Empty;
    public string TechnicianLastName { get; set; } = string.Empty;
    public string? TechnicianPhone { get; set; }

    public DateTime? ScheduledDate { get; set; }
    public TimeSpan? ScheduledTime { get; set; }

    public JobStatus JobStatus { get; set; }

    public string? PartsDescription { get; set; }
    public decimal? PartsCost { get; set; }

    public decimal TotalAmount { get; set; }

    public List<JobStatusHistoryResponse> StatusHistory { get; set; } = new();

    public DateTime CreatedAt { get; set; }
}
