using FixFlow.Core.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FixFlow.Infrastructure.Configurations;

public class JobStatusHistoryConfiguration : IEntityTypeConfiguration<JobStatusHistory>
{
    public void Configure(EntityTypeBuilder<JobStatusHistory> builder)
    {
        builder.HasKey(h => h.Id);

        builder.HasOne(h => h.Booking)
            .WithMany(b => b.StatusHistory)
            .HasForeignKey(h => h.BookingId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(h => h.ChangedBy)
            .WithMany()
            .HasForeignKey(h => h.ChangedById)
            .OnDelete(DeleteBehavior.Restrict);

        builder.Property(h => h.PreviousStatus)
            .IsRequired();

        builder.Property(h => h.NewStatus)
            .IsRequired();

        builder.Property(h => h.Note)
            .HasMaxLength(500);
    }
}
