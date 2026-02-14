using FixFlow.API.Extensions;
using FixFlow.Application.Common;
using FixFlow.Application.DTOs.Request;
using FixFlow.Application.DTOs.Response;
using FixFlow.Application.Filters;
using FixFlow.Application.IServices;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FixFlow.API.Controllers;

[Route("api/repair-requests")]
public class RepairRequestController
    : BaseController<RepairRequestResponse, CreateRepairRequestRequest,
        UpdateRepairRequestRequest, RepairRequestQueryFilter>
{
    private readonly IRepairRequestService _requestService;
    private readonly IOfferService _offerService;

    public RepairRequestController(IRepairRequestService service, IOfferService offerService) : base(service)
    {
        _requestService = service;
        _offerService = offerService;
    }

    // GET /api/repair-requests — Admin only
    [HttpGet]
    [Authorize(Roles = "Admin")]
    public override async Task<ActionResult<PagedResult<RepairRequestResponse>>> GetAll(
        [FromQuery] RepairRequestQueryFilter filter)
        => await base.GetAll(filter);

    // GET /api/repair-requests/{id} — any authenticated
    [HttpGet("{id}")]
    public override async Task<ActionResult<RepairRequestResponse>> GetById(int id)
    {
        var userId = User.GetRequiredUserId();
        var role = User.GetRequiredUserRole();
        return Ok(await _requestService.GetByIdForUserAsync(id, userId, role));
    }

    // POST /api/repair-requests — Customer only
    [HttpPost]
    [Authorize(Roles = "Customer")]
    public override async Task<ActionResult<RepairRequestResponse>> Create(
        [FromBody] CreateRepairRequestRequest dto)
    {
        var userId = User.GetRequiredUserId();
        var result = await _requestService.CreateRequestAsync(dto, userId);
        return Ok(result);
    }

    // PUT /api/repair-requests/{id} — Customer only (own, OPEN status)
    [HttpPut("{id}")]
    [Authorize(Roles = "Customer")]
    public override async Task<ActionResult<RepairRequestResponse>> Update(
        int id, [FromBody] UpdateRepairRequestRequest dto)
    {
        var userId = User.GetRequiredUserId();
        var result = await _requestService.UpdateRequestAsync(id, dto, userId);
        return Ok(result);
    }

    // DELETE /api/repair-requests/{id} — Admin only
    [HttpDelete("{id}")]
    [Authorize(Roles = "Admin")]
    public override async Task<ActionResult> Delete(int id)
        => await base.Delete(id);

    // GET /api/repair-requests/my — Customer only
    [HttpGet("my")]
    [Authorize(Roles = "Customer")]
    public async Task<ActionResult<PagedResult<RepairRequestResponse>>> GetMyRequests(
        [FromQuery] RepairRequestQueryFilter filter)
    {
        var userId = User.GetRequiredUserId();
        return Ok(await _requestService.GetMyRequestsAsync(filter, userId));
    }

    // GET /api/repair-requests/open — Technician only
    [HttpGet("open")]
    [Authorize(Roles = "Technician")]
    public async Task<ActionResult<PagedResult<RepairRequestResponse>>> GetOpenRequests(
        [FromQuery] RepairRequestQueryFilter filter)
    {
        return Ok(await _requestService.GetOpenRequestsAsync(filter));
    }

    // POST /api/repair-requests/{id}/cancel — Customer only
    [HttpPost("{id}/cancel")]
    [Authorize(Roles = "Customer")]
    public async Task<ActionResult<RepairRequestResponse>> Cancel(int id)
    {
        var userId = User.GetRequiredUserId();
        return Ok(await _requestService.CancelAsync(id, userId));
    }

    // POST /api/repair-requests/{id}/images — Customer only
    [HttpPost("{id}/images")]
    [Authorize(Roles = "Customer")]
    public async Task<ActionResult<List<RequestImageResponse>>> UploadImages(
        int id, [FromForm] IFormFile[] files)
    {
        var userId = User.GetRequiredUserId();
        var uploadData = files.Select(f => new FileUploadData
        {
            FileName = f.FileName,
            Length = f.Length,
            Content = f.OpenReadStream()
        }).ToArray();
        return Ok(await _requestService.UploadImagesAsync(id, uploadData, userId));
    }

    // DELETE /api/repair-requests/{id}/images/{imageId} — Customer only
    [HttpDelete("{id}/images/{imageId}")]
    [Authorize(Roles = "Customer")]
    public async Task<ActionResult> DeleteImage(int id, int imageId)
    {
        var userId = User.GetRequiredUserId();
        await _requestService.DeleteImageAsync(id, imageId, userId);
        return NoContent();
    }

    // GET /api/repair-requests/{id}/offers — Customer only (offers for my request)
    [HttpGet("{id}/offers")]
    [Authorize(Roles = "Customer")]
    public async Task<ActionResult<List<OfferResponse>>> GetOffersForRequest(int id)
    {
        var userId = User.GetRequiredUserId();
        return Ok(await _offerService.GetOffersForRequestAsync(id, userId));
    }

}
