using FixFlow.Core.Entities;
using FixFlow.Core.Enums;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FixFlow.Infrastructure.Configurations;

public class PaymentConfiguration : IEntityTypeConfiguration<Payment>
{
    public void Configure(EntityTypeBuilder<Payment> builder)
    {
        builder.HasKey(p => p.Id);

        builder.HasOne(p => p.Booking)
            .WithMany()
            .HasForeignKey(p => p.BookingId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(p => p.User)
            .WithMany()
            .HasForeignKey(p => p.UserId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.Property(p => p.Amount)
            .IsRequired()
            .HasColumnType("decimal(10,2)");

        builder.Property(p => p.Type)
            .IsRequired();

        builder.Property(p => p.Status)
            .IsRequired()
            .HasDefaultValue(PaymentStatus.Pending);

        builder.Property(p => p.StripePaymentIntentId)
            .HasMaxLength(255);

        builder.Property(p => p.StripeSessionId)
            .HasMaxLength(255);

        builder.HasIndex(p => p.BookingId);
        builder.HasIndex(p => p.UserId);
        builder.HasIndex(p => p.StripeSessionId)
            .HasFilter("StripeSessionId IS NOT NULL");
    }
}
