using FixFlow.Application.Common;

namespace FixFlow.Application.Filters;

public class RepairCategoryQueryFilter : PaginationRequest
{
    public string? Search { get; set; }
}
