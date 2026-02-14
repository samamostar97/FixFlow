using FixFlow.Application.Common;
using FixFlow.Application.IServices;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FixFlow.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public abstract class BaseController<TResponse, TCreate, TUpdate, TFilter> : ControllerBase
    where TFilter : PaginationRequest
{
    protected readonly IBaseService<TResponse, TCreate, TUpdate, TFilter> _service;

    protected BaseController(IBaseService<TResponse, TCreate, TUpdate, TFilter> service)
    {
        _service = service;
    }

    [HttpGet]
    public virtual async Task<ActionResult<PagedResult<TResponse>>> GetAll([FromQuery] TFilter filter)
    {
        var result = await _service.GetAllAsync(filter);
        return Ok(result);
    }

    [HttpGet("{id}")]
    public virtual async Task<ActionResult<TResponse>> GetById(int id)
    {
        var result = await _service.GetByIdAsync(id);
        return Ok(result);
    }

    [HttpPost]
    public virtual async Task<ActionResult<TResponse>> Create([FromBody] TCreate dto)
    {
        var result = await _service.CreateAsync(dto);
        return Ok(result);
    }

    [HttpPut("{id}")]
    public virtual async Task<ActionResult<TResponse>> Update(int id, [FromBody] TUpdate dto)
    {
        var result = await _service.UpdateAsync(id, dto);
        return Ok(result);
    }

    [HttpDelete("{id}")]
    public virtual async Task<ActionResult> Delete(int id)
    {
        await _service.DeleteAsync(id);
        return NoContent();
    }

    [HttpGet("lookup")]
    public virtual async Task<ActionResult<List<LookupResponse>>> GetLookup()
    {
        var result = await _service.GetLookupAsync();
        return Ok(result);
    }
}
