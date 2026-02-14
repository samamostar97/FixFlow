using FixFlow.Application.DTOs.Request;
using FixFlow.Application.DTOs.Response;
using FixFlow.Application.Filters;

namespace FixFlow.Application.IServices;

public interface IRepairCategoryService
    : IBaseService<RepairCategoryResponse, CreateRepairCategoryRequest, UpdateRepairCategoryRequest, RepairCategoryQueryFilter>
{
}
