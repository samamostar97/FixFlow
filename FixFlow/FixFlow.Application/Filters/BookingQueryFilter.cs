using FixFlow.Application.Common;
using FixFlow.Core.Enums;

namespace FixFlow.Application.Filters;

public class BookingQueryFilter : PaginationRequest
{
    public string? Search { get; set; }
    public JobStatus? JobStatus { get; set; }
    public int? CustomerId { get; set; }
    public int? TechnicianId { get; set; }
}
