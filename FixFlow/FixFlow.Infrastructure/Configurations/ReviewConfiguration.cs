using FixFlow.Core.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FixFlow.Infrastructure.Configurations;

public class ReviewConfiguration : IEntityTypeConfiguration<Review>
{
    public void Configure(EntityTypeBuilder<Review> builder)
    {
        builder.HasKey(r => r.Id);

        builder.HasOne(r => r.Booking)
            .WithOne()
            .HasForeignKey<Review>(r => r.BookingId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(r => r.Customer)
            .WithMany()
            .HasForeignKey(r => r.CustomerId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(r => r.Technician)
            .WithMany()
            .HasForeignKey(r => r.TechnicianId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.Property(r => r.Rating)
            .IsRequired();

        builder.Property(r => r.Comment)
            .HasMaxLength(1000);

        builder.HasIndex(r => r.BookingId)
            .IsUnique();
    }
}
