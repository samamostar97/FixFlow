using FixFlow.API.Extensions;
using FixFlow.Application.Common;
using FixFlow.Application.DTOs.Request;
using FixFlow.Application.DTOs.Response;
using FixFlow.Application.Filters;
using FixFlow.Application.IServices;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FixFlow.API.Controllers;

[ApiController]
[Route("api/reviews")]
[Authorize]
public class ReviewController : ControllerBase
{
    private readonly IReviewService _reviewService;

    public ReviewController(IReviewService reviewService)
    {
        _reviewService = reviewService;
    }

    // POST /api/reviews — Customer only
    [HttpPost]
    [Authorize(Roles = "Customer")]
    public async Task<ActionResult<ReviewResponse>> Create([FromBody] CreateReviewRequest dto)
    {
        var userId = User.GetRequiredUserId();
        var result = await _reviewService.CreateAsync(dto, userId);
        return StatusCode(201, result);
    }

    // GET /api/reviews/booking/{bookingId} — Authenticated
    [HttpGet("booking/{bookingId}")]
    public async Task<ActionResult<ReviewResponse>> GetByBookingId(int bookingId)
    {
        var review = await _reviewService.GetByBookingIdAsync(bookingId);
        if (review == null) return NotFound();
        return Ok(review);
    }

    // GET /api/reviews/technician/{technicianId} — Authenticated
    [HttpGet("technician/{technicianId}")]
    public async Task<ActionResult<PagedResult<ReviewResponse>>> GetForTechnician(
        int technicianId, [FromQuery] ReviewQueryFilter filter)
    {
        return Ok(await _reviewService.GetForTechnicianAsync(technicianId, filter));
    }

    // GET /api/reviews — Admin only
    [HttpGet]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<PagedResult<ReviewResponse>>> GetAll(
        [FromQuery] ReviewQueryFilter filter)
    {
        return Ok(await _reviewService.GetAllAsync(filter));
    }
}
