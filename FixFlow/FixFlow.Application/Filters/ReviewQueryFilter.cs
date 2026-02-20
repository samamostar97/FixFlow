using FixFlow.Application.Common;

namespace FixFlow.Application.Filters;

public class ReviewQueryFilter : PaginationRequest
{
    public int? TechnicianId { get; set; }
    public int? CustomerId { get; set; }
    public int? MinRating { get; set; }
}
