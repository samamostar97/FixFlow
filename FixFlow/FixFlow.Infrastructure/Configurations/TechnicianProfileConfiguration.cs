using FixFlow.Core.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FixFlow.Infrastructure.Configurations;

public class TechnicianProfileConfiguration : IEntityTypeConfiguration<TechnicianProfile>
{
    public void Configure(EntityTypeBuilder<TechnicianProfile> builder)
    {
        builder.HasKey(t => t.Id);

        builder.HasOne(t => t.User)
            .WithOne()
            .HasForeignKey<TechnicianProfile>(t => t.UserId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasIndex(t => t.UserId)
            .IsUnique()
            .HasFilter("IsDeleted = 0");

        builder.Property(t => t.Bio)
            .HasMaxLength(1000);

        builder.Property(t => t.Specialties)
            .HasMaxLength(500);

        builder.Property(t => t.WorkingHours)
            .HasMaxLength(200);

        builder.Property(t => t.Zone)
            .HasMaxLength(200);

        builder.Property(t => t.IsVerified)
            .IsRequired()
            .HasDefaultValue(false);

        builder.Property(t => t.AverageRating)
            .IsRequired()
            .HasDefaultValue(0.0);
    }
}
