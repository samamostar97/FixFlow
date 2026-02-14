using FixFlow.Application.Common;
using FixFlow.Core.Enums;

namespace FixFlow.Application.Filters;

public class OfferQueryFilter : PaginationRequest
{
    public string? Search { get; set; }
    public OfferStatus? Status { get; set; }
    public ServiceType? ServiceType { get; set; }
    public int? RepairRequestId { get; set; }
    public int? TechnicianId { get; set; }
}
