using FixFlow.Core.Entities;
using FixFlow.Core.Enums;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FixFlow.Infrastructure.Configurations;

public class OfferConfiguration : IEntityTypeConfiguration<Offer>
{
    public void Configure(EntityTypeBuilder<Offer> builder)
    {
        builder.HasKey(o => o.Id);

        builder.HasOne(o => o.RepairRequest)
            .WithMany(r => r.Offers)
            .HasForeignKey(o => o.RepairRequestId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(o => o.Technician)
            .WithMany()
            .HasForeignKey(o => o.TechnicianId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.Property(o => o.Price)
            .IsRequired()
            .HasColumnType("decimal(10,2)");

        builder.Property(o => o.EstimatedDays)
            .IsRequired();

        builder.Property(o => o.ServiceType)
            .IsRequired();

        builder.Property(o => o.Note)
            .HasMaxLength(1000);

        builder.Property(o => o.Status)
            .IsRequired()
            .HasDefaultValue(OfferStatus.Pending);
    }
}
