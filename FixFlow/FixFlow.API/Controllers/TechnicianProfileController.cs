using FixFlow.API.Extensions;
using FixFlow.Application.Common;
using FixFlow.Application.DTOs.Request;
using FixFlow.Application.DTOs.Response;
using FixFlow.Application.Filters;
using FixFlow.Application.IServices;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FixFlow.API.Controllers;

[Route("api/technician-profiles")]
public class TechnicianProfileController
    : BaseController<TechnicianProfileResponse, CreateTechnicianProfileRequest,
        UpdateTechnicianProfileRequest, TechnicianProfileQueryFilter>
{
    private readonly ITechnicianProfileService _profileService;

    public TechnicianProfileController(ITechnicianProfileService service) : base(service)
    {
        _profileService = service;
    }

    [HttpGet]
    [Authorize(Roles = "Admin")]
    public override async Task<ActionResult<PagedResult<TechnicianProfileResponse>>> GetAll(
        [FromQuery] TechnicianProfileQueryFilter filter)
        => await base.GetAll(filter);

    [HttpPost]
    [Authorize(Roles = "Admin")]
    public override async Task<ActionResult<TechnicianProfileResponse>> Create(
        [FromBody] CreateTechnicianProfileRequest dto)
        => await base.Create(dto);

    [HttpPut("{id}")]
    [Authorize(Roles = "Admin")]
    public override async Task<ActionResult<TechnicianProfileResponse>> Update(
        int id, [FromBody] UpdateTechnicianProfileRequest dto)
        => await base.Update(id, dto);

    [HttpDelete("{id}")]
    [Authorize(Roles = "Admin")]
    public override async Task<ActionResult> Delete(int id)
        => await base.Delete(id);

    [HttpGet("me")]
    [Authorize(Roles = "Technician")]
    public async Task<ActionResult<TechnicianProfileResponse>> GetMyProfile()
    {
        var userId = User.GetRequiredUserId();
        return Ok(await _profileService.GetMyProfileAsync(userId));
    }

    [HttpPut("me")]
    [Authorize(Roles = "Technician")]
    public async Task<ActionResult<TechnicianProfileResponse>> UpdateMyProfile(
        [FromBody] UpdateTechnicianProfileRequest request)
    {
        var userId = User.GetRequiredUserId();
        return Ok(await _profileService.UpdateMyProfileAsync(userId, request));
    }

    [HttpPut("{id}/verify")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<TechnicianProfileResponse>> Verify(int id)
    {
        return Ok(await _profileService.VerifyAsync(id));
    }
}
