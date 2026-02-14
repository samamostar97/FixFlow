using FixFlow.Core.Enums;

namespace FixFlow.Application.DTOs.Response;

public class RepairRequestResponse
{
    public int Id { get; set; }

    public int CategoryId { get; set; }
    public string CategoryName { get; set; } = string.Empty;

    public int CustomerId { get; set; }
    public string CustomerFirstName { get; set; } = string.Empty;
    public string CustomerLastName { get; set; } = string.Empty;
    public string CustomerEmail { get; set; } = string.Empty;
    public string? CustomerPhone { get; set; }

    public string Description { get; set; } = string.Empty;
    public PreferenceType PreferenceType { get; set; }

    public double? Latitude { get; set; }
    public double? Longitude { get; set; }
    public string? Address { get; set; }

    public RepairRequestStatus Status { get; set; }

    public List<RequestImageResponse> Images { get; set; } = new();

    public DateTime CreatedAt { get; set; }
}
