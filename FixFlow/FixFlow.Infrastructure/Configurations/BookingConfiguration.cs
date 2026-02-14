using FixFlow.Core.Entities;
using FixFlow.Core.Enums;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FixFlow.Infrastructure.Configurations;

public class BookingConfiguration : IEntityTypeConfiguration<Booking>
{
    public void Configure(EntityTypeBuilder<Booking> builder)
    {
        builder.HasKey(b => b.Id);

        builder.HasOne(b => b.RepairRequest)
            .WithOne(r => r.Booking)
            .HasForeignKey<Booking>(b => b.RepairRequestId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(b => b.Offer)
            .WithMany()
            .HasForeignKey(b => b.OfferId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(b => b.Customer)
            .WithMany()
            .HasForeignKey(b => b.CustomerId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(b => b.Technician)
            .WithMany()
            .HasForeignKey(b => b.TechnicianId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.Property(b => b.ScheduledDate)
            .IsRequired(false);

        builder.Property(b => b.ScheduledTime)
            .IsRequired(false);

        builder.Property(b => b.JobStatus)
            .IsRequired()
            .HasDefaultValue(JobStatus.Received);

        builder.Property(b => b.PartsDescription)
            .HasMaxLength(1000);

        builder.Property(b => b.PartsCost)
            .HasColumnType("decimal(10,2)");

        builder.Property(b => b.TotalAmount)
            .IsRequired()
            .HasColumnType("decimal(10,2)");
    }
}
