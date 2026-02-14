using FixFlow.Application.DTOs.Request;
using FixFlow.Application.DTOs.Response;
using FixFlow.Application.Filters;
using FixFlow.Application.IServices;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FixFlow.API.Controllers;

[Route("api/repair-categories")]
public class RepairCategoryController
    : BaseController<RepairCategoryResponse, CreateRepairCategoryRequest, UpdateRepairCategoryRequest, RepairCategoryQueryFilter>
{
    public RepairCategoryController(IRepairCategoryService service) : base(service) { }

    [HttpPost]
    [Authorize(Roles = "Admin")]
    public override async Task<ActionResult<RepairCategoryResponse>> Create([FromBody] CreateRepairCategoryRequest dto)
        => await base.Create(dto);

    [HttpPut("{id}")]
    [Authorize(Roles = "Admin")]
    public override async Task<ActionResult<RepairCategoryResponse>> Update(int id, [FromBody] UpdateRepairCategoryRequest dto)
        => await base.Update(id, dto);

    [HttpDelete("{id}")]
    [Authorize(Roles = "Admin")]
    public override async Task<ActionResult> Delete(int id)
        => await base.Delete(id);
}
