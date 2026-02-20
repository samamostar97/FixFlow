using FixFlow.Application.IRepositories;
using FixFlow.Core.Entities;
using FixFlow.Core.Enums;
using FixFlow.Infrastructure.Data;
using FixFlow.Infrastructure.Mapping;
using FixFlow.Infrastructure.Repositories;
using FixFlow.Infrastructure.Services;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging.Abstractions;

namespace FixFlow.Tests.TestSupport;

internal static class TestFixtureFactory
{
    private static readonly object MapsterLock = new();
    private static bool _mapsterRegistered;

    internal static DbContextOptions<FixFlowDbContext> CreateSqliteOptions(string dataSource)
    {
        return new DbContextOptionsBuilder<FixFlowDbContext>()
            .UseSqlite($"Data Source={dataSource}")
            .Options;
    }

    internal static User CreateUser(string email, UserRole role, string firstName, string lastName)
    {
        return new User
        {
            Email = email,
            PasswordHash = "hash",
            FirstName = firstName,
            LastName = lastName,
            Role = role,
        };
    }

    internal static RepairRequestService CreateRepairRequestService(FixFlowDbContext context)
    {
        EnsureMapsterRegistered();
        return new RepairRequestService(
            new BaseRepository<RepairRequest>(context),
            new BaseRepository<RepairCategory>(context),
            new BaseRepository<RequestImage>(context),
            CreateUploadConfiguration(),
            NullLogger<RepairRequestService>.Instance);
    }

    internal static BookingService CreateBookingService(FixFlowDbContext context)
    {
        EnsureMapsterRegistered();
        return new BookingService(
            new BaseRepository<Booking>(context),
            new BaseRepository<JobStatusHistory>(context),
            new BaseRepository<Offer>(context),
            new BaseRepository<RepairRequest>(context),
            NullLogger<BookingService>.Instance);
    }

    internal static OfferService CreateOfferService(FixFlowDbContext context)
    {
        EnsureMapsterRegistered();
        return new OfferService(
            new BaseRepository<Offer>(context),
            new BaseRepository<RepairRequest>(context),
            CreateBookingService(context),
            context,
            NullLogger<OfferService>.Instance);
    }

    internal static ReviewService CreateReviewService(FixFlowDbContext context)
    {
        EnsureMapsterRegistered();
        return new ReviewService(
            new BaseRepository<Review>(context),
            new BaseRepository<Booking>(context),
            new BaseRepository<TechnicianProfile>(context),
            NullLogger<ReviewService>.Instance);
    }

    internal static PaymentService CreatePaymentService(FixFlowDbContext context)
    {
        EnsureMapsterRegistered();
        return new PaymentService(
            new BaseRepository<Payment>(context),
            new BaseRepository<Booking>(context),
            CreateStripeConfiguration(),
            NullLogger<PaymentService>.Instance);
    }

    internal static AuthService CreateAuthService(FixFlowDbContext context)
    {
        return new AuthService(
            new BaseRepository<User>(context),
            CreateJwtConfiguration(),
            NullLogger<AuthService>.Instance);
    }

    private static IConfiguration CreateUploadConfiguration()
    {
        var values = new Dictionary<string, string?>
        {
            ["FileUpload:StoragePath"] = "wwwroot/uploads",
            ["FileUpload:MaxFileSizeBytes"] = "5242880",
            ["FileUpload:AllowedImageExtensions:0"] = ".jpg",
            ["FileUpload:AllowedImageExtensions:1"] = ".jpeg",
            ["FileUpload:AllowedImageExtensions:2"] = ".png",
            ["FileUpload:AllowedImageExtensions:3"] = ".webp",
        };

        return new ConfigurationBuilder()
            .AddInMemoryCollection(values)
            .Build();
    }

    private static IConfiguration CreateJwtConfiguration()
    {
        var values = new Dictionary<string, string?>
        {
            ["Jwt:Secret"] = "ThisIsATestSecretKeyThatIsLongEnough123456",
            ["Jwt:Issuer"] = "FixFlow.Tests",
            ["Jwt:Audience"] = "FixFlow.Tests",
            ["Jwt:ExpirationInMinutes"] = "60",
        };

        return new ConfigurationBuilder()
            .AddInMemoryCollection(values)
            .Build();
    }

    private static IConfiguration CreateStripeConfiguration()
    {
        var values = new Dictionary<string, string?>
        {
            ["Stripe:SecretKey"] = "sk_test_fake",
            ["Stripe:WebhookSecret"] = "whsec_test_fake",
        };

        return new ConfigurationBuilder()
            .AddInMemoryCollection(values)
            .Build();
    }

    private static void EnsureMapsterRegistered()
    {
        if (_mapsterRegistered)
        {
            return;
        }

        lock (MapsterLock)
        {
            if (_mapsterRegistered)
            {
                return;
            }

            MappingConfig.RegisterMappings();
            _mapsterRegistered = true;
        }
    }
}
