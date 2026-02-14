using FixFlow.API.Extensions;
using FixFlow.Application.DTOs.Request;
using FixFlow.Application.DTOs.Response;
using FixFlow.Application.IServices;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FixFlow.API.Controllers;

[ApiController]
[Route("api/users")]
[Authorize]
public class UserController : ControllerBase
{
    private readonly IUserService _userService;

    public UserController(IUserService userService)
    {
        _userService = userService;
    }

    [HttpGet("me")]
    public async Task<ActionResult<UserResponse>> GetProfile()
    {
        var userId = User.GetRequiredUserId();
        var result = await _userService.GetProfileAsync(userId);
        return Ok(result);
    }

    [HttpPut("me")]
    public async Task<ActionResult<UserResponse>> UpdateProfile([FromBody] UpdateProfileRequest request)
    {
        var userId = User.GetRequiredUserId();
        var result = await _userService.UpdateProfileAsync(userId, request);
        return Ok(result);
    }
}
