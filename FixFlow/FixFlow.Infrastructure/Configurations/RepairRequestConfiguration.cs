using FixFlow.Core.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FixFlow.Infrastructure.Configurations;

public class RepairRequestConfiguration : IEntityTypeConfiguration<RepairRequest>
{
    public void Configure(EntityTypeBuilder<RepairRequest> builder)
    {
        builder.HasKey(r => r.Id);

        builder.HasOne(r => r.Category)
            .WithMany()
            .HasForeignKey(r => r.CategoryId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(r => r.Customer)
            .WithMany()
            .HasForeignKey(r => r.CustomerId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.Property(r => r.Description)
            .IsRequired()
            .HasMaxLength(2000);

        builder.Property(r => r.PreferenceType)
            .IsRequired();

        builder.Property(r => r.Address)
            .HasMaxLength(500);

        builder.Property(r => r.Status)
            .IsRequired()
            .HasDefaultValue(Core.Enums.RepairRequestStatus.Open);

        builder.HasMany(r => r.Images)
            .WithOne(i => i.RepairRequest)
            .HasForeignKey(i => i.RepairRequestId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
