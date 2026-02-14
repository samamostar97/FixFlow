using FixFlow.Application.Common;
using FixFlow.Application.IRepositories;
using FixFlow.Core.Entities;
using FixFlow.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace FixFlow.Infrastructure.Repositories;

public class BaseRepository<T> : IRepository<T> where T : BaseEntity
{
    protected readonly FixFlowDbContext _context;
    protected readonly DbSet<T> _dbSet;

    public BaseRepository(FixFlowDbContext context)
    {
        _context = context;
        _dbSet = context.Set<T>();
    }

    public async Task<T?> GetByIdAsync(int id)
        => await _dbSet.FirstOrDefaultAsync(x => x.Id == id && !x.IsDeleted);

    public async Task<List<T>> GetAllAsync()
        => await _dbSet.Where(x => !x.IsDeleted).ToListAsync();

    public async Task AddAsync(T entity)
    {
        entity.CreatedAt = DateTimeUtils.Now;
        await _dbSet.AddAsync(entity);
        await _context.SaveChangesAsync();
    }

    public async Task UpdateAsync(T entity)
    {
        entity.UpdatedAt = DateTimeUtils.Now;
        _dbSet.Update(entity);
        await _context.SaveChangesAsync();
    }

    public async Task DeleteAsync(T entity)
    {
        entity.IsDeleted = true;
        entity.UpdatedAt = DateTimeUtils.Now;
        await _context.SaveChangesAsync();
    }

    public IQueryable<T> AsQueryable()
        => _dbSet.Where(x => !x.IsDeleted).AsQueryable();
}
