using FixFlow.Application.Common;

namespace FixFlow.Application.Filters;

public class TechnicianProfileQueryFilter : PaginationRequest
{
    public string? Search { get; set; }
    public bool? IsVerified { get; set; }
    public string? Zone { get; set; }
}
