using FixFlow.Application.Common;
using FixFlow.Core.Enums;

namespace FixFlow.Application.Filters;

public class PaymentQueryFilter : PaginationRequest
{
    public int? BookingId { get; set; }
    public int? UserId { get; set; }
    public PaymentStatus? Status { get; set; }
    public PaymentType? Type { get; set; }
}
