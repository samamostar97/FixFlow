using FixFlow.Core.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FixFlow.Infrastructure.Configurations;

public class RequestImageConfiguration : IEntityTypeConfiguration<RequestImage>
{
    public void Configure(EntityTypeBuilder<RequestImage> builder)
    {
        builder.HasKey(i => i.Id);

        builder.Property(i => i.ImagePath)
            .IsRequired()
            .HasMaxLength(500);

        builder.Property(i => i.OriginalFileName)
            .IsRequired()
            .HasMaxLength(255);

        builder.Property(i => i.FileSize)
            .IsRequired();
    }
}
