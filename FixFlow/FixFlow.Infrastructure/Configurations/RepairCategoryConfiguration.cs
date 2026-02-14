using FixFlow.Core.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FixFlow.Infrastructure.Configurations;

public class RepairCategoryConfiguration : IEntityTypeConfiguration<RepairCategory>
{
    public void Configure(EntityTypeBuilder<RepairCategory> builder)
    {
        builder.HasKey(c => c.Id);

        builder.Property(c => c.Name)
            .IsRequired()
            .HasMaxLength(100);

        builder.HasIndex(c => c.Name)
            .IsUnique()
            .HasFilter("IsDeleted = 0");
    }
}
