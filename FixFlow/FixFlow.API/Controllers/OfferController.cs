using FixFlow.API.Extensions;
using FixFlow.Application.Common;
using FixFlow.Application.DTOs.Request;
using FixFlow.Application.DTOs.Response;
using FixFlow.Application.Filters;
using FixFlow.Application.IServices;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FixFlow.API.Controllers;

[Route("api/offers")]
public class OfferController
    : BaseController<OfferResponse, CreateOfferRequest,
        UpdateOfferRequest, OfferQueryFilter>
{
    private readonly IOfferService _offerService;

    public OfferController(IOfferService service) : base(service)
    {
        _offerService = service;
    }

    // GET /api/offers — Admin only
    [HttpGet]
    [Authorize(Roles = "Admin")]
    public override async Task<ActionResult<PagedResult<OfferResponse>>> GetAll(
        [FromQuery] OfferQueryFilter filter)
        => await base.GetAll(filter);

    // GET /api/offers/{id} — any authenticated
    [HttpGet("{id}")]
    public override async Task<ActionResult<OfferResponse>> GetById(int id)
    {
        var userId = User.GetRequiredUserId();
        var role = User.GetRequiredUserRole();
        return Ok(await _offerService.GetByIdForUserAsync(id, userId, role));
    }

    // POST /api/offers — Technician only
    [HttpPost]
    [Authorize(Roles = "Technician")]
    public override async Task<ActionResult<OfferResponse>> Create(
        [FromBody] CreateOfferRequest dto)
    {
        var userId = User.GetRequiredUserId();
        var result = await _offerService.CreateOfferAsync(dto, userId);
        return Ok(result);
    }

    // PUT /api/offers/{id} — Technician only (own, Pending only)
    [HttpPut("{id}")]
    [Authorize(Roles = "Technician")]
    public override async Task<ActionResult<OfferResponse>> Update(
        int id, [FromBody] UpdateOfferRequest dto)
    {
        var userId = User.GetRequiredUserId();
        var result = await _offerService.UpdateOfferAsync(id, dto, userId);
        return Ok(result);
    }

    // DELETE /api/offers/{id} — Admin only
    [HttpDelete("{id}")]
    [Authorize(Roles = "Admin")]
    public override async Task<ActionResult> Delete(int id)
        => await base.Delete(id);

    // GET /api/offers/my — Technician only
    [HttpGet("my")]
    [Authorize(Roles = "Technician")]
    public async Task<ActionResult<PagedResult<OfferResponse>>> GetMyOffers(
        [FromQuery] OfferQueryFilter filter)
    {
        var userId = User.GetRequiredUserId();
        return Ok(await _offerService.GetMyOffersAsync(filter, userId));
    }

    // POST /api/offers/{id}/accept — Customer only
    [HttpPost("{id}/accept")]
    [Authorize(Roles = "Customer")]
    public async Task<ActionResult<OfferResponse>> Accept(int id)
    {
        var userId = User.GetRequiredUserId();
        return Ok(await _offerService.AcceptOfferAsync(id, userId));
    }

    // POST /api/offers/{id}/withdraw — Technician only
    [HttpPost("{id}/withdraw")]
    [Authorize(Roles = "Technician")]
    public async Task<ActionResult<OfferResponse>> Withdraw(int id)
    {
        var userId = User.GetRequiredUserId();
        return Ok(await _offerService.WithdrawOfferAsync(id, userId));
    }

}
