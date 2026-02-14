using FixFlow.Application.Common;
using FixFlow.Core.Enums;

namespace FixFlow.Application.Filters;

public class RepairRequestQueryFilter : PaginationRequest
{
    public string? Search { get; set; }
    public RepairRequestStatus? Status { get; set; }
    public int? CategoryId { get; set; }
    public PreferenceType? PreferenceType { get; set; }
    public int? CustomerId { get; set; }
}
