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
[Route("api/bookings")]
[Authorize]
public class BookingController : ControllerBase
{
    private readonly IBookingService _bookingService;

    public BookingController(IBookingService bookingService)
    {
        _bookingService = bookingService;
    }

    // GET /api/bookings — Admin only
    [HttpGet]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<PagedResult<BookingResponse>>> GetAll(
        [FromQuery] BookingQueryFilter filter)
    {
        return Ok(await _bookingService.GetAllAsync(filter));
    }

    // GET /api/bookings/{id} — Authenticated
    [HttpGet("{id}")]
    public async Task<ActionResult<BookingResponse>> GetById(int id)
    {
        var userId = User.GetRequiredUserId();
        var role = User.GetRequiredUserRole();
        return Ok(await _bookingService.GetByIdForUserAsync(id, userId, role));
    }

    // GET /api/bookings/my — Customer or Technician
    [HttpGet("my")]
    [Authorize(Roles = "Customer,Technician")]
    public async Task<ActionResult<PagedResult<BookingResponse>>> GetMyBookings(
        [FromQuery] BookingQueryFilter filter)
    {
        var userId = User.GetRequiredUserId();
        var role = User.GetRequiredUserRole();
        return Ok(await _bookingService.GetMyBookingsAsync(filter, userId, role));
    }

    // PATCH /api/bookings/{id}/status — Technician only
    [HttpPatch("{id}/status")]
    [Authorize(Roles = "Technician")]
    public async Task<ActionResult<BookingResponse>> UpdateJobStatus(
        int id, [FromBody] UpdateJobStatusRequest dto)
    {
        var userId = User.GetRequiredUserId();
        return Ok(await _bookingService.UpdateJobStatusAsync(id, dto, userId));
    }

    // PATCH /api/bookings/{id}/parts — Technician only
    [HttpPatch("{id}/parts")]
    [Authorize(Roles = "Technician")]
    public async Task<ActionResult<BookingResponse>> UpdateParts(
        int id, [FromBody] UpdateBookingPartsRequest dto)
    {
        var userId = User.GetRequiredUserId();
        return Ok(await _bookingService.UpdatePartsAsync(id, dto, userId));
    }
}
