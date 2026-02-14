using FixFlow.Core.Enums;

namespace FixFlow.Application.DTOs.Response;

public class JobStatusHistoryResponse
{
    public int Id { get; set; }
    public int BookingId { get; set; }
    public JobStatus PreviousStatus { get; set; }
    public JobStatus NewStatus { get; set; }
    public string? Note { get; set; }
    public int ChangedById { get; set; }
    public string ChangedByFirstName { get; set; } = string.Empty;
    public string ChangedByLastName { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
}
