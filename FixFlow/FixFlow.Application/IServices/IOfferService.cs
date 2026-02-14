using FixFlow.Application.Common;
using FixFlow.Application.DTOs.Request;
using FixFlow.Application.DTOs.Response;
using FixFlow.Application.Filters;

namespace FixFlow.Application.IServices;

public interface IOfferService
    : IBaseService<OfferResponse, CreateOfferRequest, UpdateOfferRequest, OfferQueryFilter>
{
    Task<OfferResponse> GetByIdForUserAsync(int id, int userId, string role);
    Task<OfferResponse> CreateOfferAsync(CreateOfferRequest dto, int technicianId);
    Task<OfferResponse> UpdateOfferAsync(int id, UpdateOfferRequest dto, int technicianId);
    Task<PagedResult<OfferResponse>> GetMyOffersAsync(OfferQueryFilter filter, int technicianId);
    Task<List<OfferResponse>> GetOffersForRequestAsync(int requestId, int customerId);
    Task<OfferResponse> AcceptOfferAsync(int offerId, int customerId);
    Task<OfferResponse> WithdrawOfferAsync(int offerId, int technicianId);
}
