using FixFlow.Application.Common;
using FixFlow.Application.DTOs.Request;
using FixFlow.Application.DTOs.Response;
using FixFlow.Application.Exceptions;
using FixFlow.Application.Filters;
using FixFlow.Application.Helpers;
using FixFlow.Application.IRepositories;
using FixFlow.Application.IServices;
using FixFlow.Core.Entities;
using Microsoft.EntityFrameworkCore;

namespace FixFlow.Infrastructure.Services;

public class RepairCategoryService
    : BaseService<RepairCategory, RepairCategoryResponse, CreateRepairCategoryRequest, UpdateRepairCategoryRequest, RepairCategoryQueryFilter>,
      IRepairCategoryService
{
    public RepairCategoryService(IRepository<RepairCategory> repository) : base(repository) { }

    protected override IQueryable<RepairCategory> ApplyFilter(IQueryable<RepairCategory> query, RepairCategoryQueryFilter filter)
    {
        return query
            .WhereIf(!string.IsNullOrWhiteSpace(filter.Search),
                c => c.Name.ToLower().Contains(filter.Search!.ToLower()))
            .OrderBy(c => c.Name);
    }

    protected override async Task ValidateCreateAsync(RepairCategory entity, CreateRepairCategoryRequest dto)
    {
        var exists = await _repository.AsQueryable()
            .AnyAsync(c => c.Name.ToLower() == dto.Name.Trim().ToLower());

        if (exists)
            throw new ConflictException("Kategorija sa ovim nazivom već postoji.");
    }

    protected override async Task ValidateUpdateAsync(RepairCategory entity, UpdateRepairCategoryRequest dto)
    {
        if (dto.Name == null) return;

        var exists = await _repository.AsQueryable()
            .AnyAsync(c => c.Name.ToLower() == dto.Name.Trim().ToLower() && c.Id != entity.Id);

        if (exists)
            throw new ConflictException("Kategorija sa ovim nazivom već postoji.");
    }

    protected override Task PrepareCreateAsync(RepairCategory entity, CreateRepairCategoryRequest dto)
    {
        entity.Name = dto.Name.Trim();
        return Task.CompletedTask;
    }

    public override async Task<List<LookupResponse>> GetLookupAsync()
    {
        return await _repository.AsQueryable()
            .OrderBy(c => c.Name)
            .Select(c => new LookupResponse { Id = c.Id, Name = c.Name })
            .ToListAsync();
    }
}
