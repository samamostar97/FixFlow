using System.Linq.Expressions;
using System.Security.Claims;
using FixFlow.Application.Common;
using FixFlow.Core.Entities;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;

namespace FixFlow.Infrastructure.Data;

public class FixFlowDbContext : DbContext
{
    public DbSet<User> Users => Set<User>();
    public DbSet<RepairCategory> RepairCategories => Set<RepairCategory>();
    public DbSet<TechnicianProfile> TechnicianProfiles => Set<TechnicianProfile>();
    public DbSet<RepairRequest> RepairRequests => Set<RepairRequest>();
    public DbSet<RequestImage> RequestImages => Set<RequestImage>();
    public DbSet<Offer> Offers => Set<Offer>();
    public DbSet<Booking> Bookings => Set<Booking>();
    public DbSet<JobStatusHistory> JobStatusHistories => Set<JobStatusHistory>();
    public DbSet<Review> Reviews => Set<Review>();
    public DbSet<Payment> Payments => Set<Payment>();

    private readonly IHttpContextAccessor? _httpContextAccessor;

    public FixFlowDbContext(DbContextOptions<FixFlowDbContext> options, IHttpContextAccessor? httpContextAccessor = null)
        : base(options)
    {
        _httpContextAccessor = httpContextAccessor;
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        foreach (var entityType in modelBuilder.Model.GetEntityTypes())
        {
            if (typeof(BaseEntity).IsAssignableFrom(entityType.ClrType))
            {
                modelBuilder.Entity(entityType.ClrType)
                    .HasQueryFilter(
                        BuildSoftDeleteFilter(entityType.ClrType));
            }
        }

        modelBuilder.ApplyConfigurationsFromAssembly(typeof(FixFlowDbContext).Assembly);
    }

    public override async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        var userId = GetCurrentUserId();
        var now = DateTimeUtils.Now;

        foreach (var entry in ChangeTracker.Entries<BaseEntity>())
        {
            switch (entry.State)
            {
                case EntityState.Added:
                    entry.Entity.CreatedAt = now;
                    entry.Entity.CreatedBy = userId;
                    break;

                case EntityState.Modified:
                    entry.Entity.UpdatedAt = now;
                    entry.Entity.UpdatedBy = userId;
                    break;

                case EntityState.Deleted:
                    entry.State = EntityState.Modified;
                    entry.Entity.IsDeleted = true;
                    entry.Entity.UpdatedAt = now;
                    entry.Entity.UpdatedBy = userId;
                    break;
            }
        }

        return await base.SaveChangesAsync(cancellationToken);
    }

    private int? GetCurrentUserId()
    {
        var userIdClaim = _httpContextAccessor?.HttpContext?.User
            .FindFirst(ClaimTypes.NameIdentifier)?.Value;

        return int.TryParse(userIdClaim, out var userId) ? userId : null;
    }

    private static LambdaExpression BuildSoftDeleteFilter(Type entityType)
    {
        var parameter = System.Linq.Expressions.Expression.Parameter(entityType, "e");
        var property = System.Linq.Expressions.Expression.Property(parameter, nameof(BaseEntity.IsDeleted));
        var condition = System.Linq.Expressions.Expression.Equal(property,
            System.Linq.Expressions.Expression.Constant(false));
        return System.Linq.Expressions.Expression.Lambda(condition, parameter);
    }
}
