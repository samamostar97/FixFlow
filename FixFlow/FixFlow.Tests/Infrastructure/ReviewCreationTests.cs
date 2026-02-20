using FixFlow.Application.DTOs.Request;
using FixFlow.Application.Exceptions;
using FixFlow.Core.Entities;
using FixFlow.Core.Enums;
using FixFlow.Infrastructure.Data;
using FixFlow.Tests.TestSupport;
using Microsoft.EntityFrameworkCore;

namespace FixFlow.Tests.Infrastructure;

public class ReviewCreationTests
{
    [Fact]
    public async Task CreateReview_ValidRequest_CreatesAndUpdatesAvgRating()
    {
        var dbPath = Path.Combine(Path.GetTempPath(), $"fixflow-tests-{Guid.NewGuid():N}.db");
        await using var context = new FixFlowDbContext(TestFixtureFactory.CreateSqliteOptions(dbPath));
        await context.Database.EnsureCreatedAsync();

        var seed = await SeedCompletedBookingAsync(context);
        var reviewService = TestFixtureFactory.CreateReviewService(context);

        var result = await reviewService.CreateAsync(
            new CreateReviewRequest { BookingId = seed.BookingId, Rating = 4, Comment = "Dobra usluga" },
            seed.CustomerId);

        Assert.Equal(4, result.Rating);
        Assert.Equal("Dobra usluga", result.Comment);
        Assert.Equal(seed.BookingId, result.BookingId);

        var profile = await context.TechnicianProfiles.SingleAsync(p => p.UserId == seed.TechnicianId);
        Assert.Equal(4.0, profile.AverageRating);
    }

    [Fact]
    public async Task CreateReview_NonCompletedBooking_Throws()
    {
        var dbPath = Path.Combine(Path.GetTempPath(), $"fixflow-tests-{Guid.NewGuid():N}.db");
        await using var context = new FixFlowDbContext(TestFixtureFactory.CreateSqliteOptions(dbPath));
        await context.Database.EnsureCreatedAsync();

        var seed = await SeedInProgressBookingAsync(context);
        var reviewService = TestFixtureFactory.CreateReviewService(context);

        await Assert.ThrowsAsync<InvalidOperationException>(() =>
            reviewService.CreateAsync(
                new CreateReviewRequest { BookingId = seed.BookingId, Rating = 5 },
                seed.CustomerId));
    }

    [Fact]
    public async Task CreateReview_DuplicateBooking_ThrowsConflict()
    {
        var dbPath = Path.Combine(Path.GetTempPath(), $"fixflow-tests-{Guid.NewGuid():N}.db");
        await using var context = new FixFlowDbContext(TestFixtureFactory.CreateSqliteOptions(dbPath));
        await context.Database.EnsureCreatedAsync();

        var seed = await SeedCompletedBookingAsync(context);
        var reviewService = TestFixtureFactory.CreateReviewService(context);

        await reviewService.CreateAsync(
            new CreateReviewRequest { BookingId = seed.BookingId, Rating = 5 },
            seed.CustomerId);

        await Assert.ThrowsAsync<ConflictException>(() =>
            reviewService.CreateAsync(
                new CreateReviewRequest { BookingId = seed.BookingId, Rating = 3 },
                seed.CustomerId));
    }

    [Fact]
    public async Task CreateReview_WrongCustomer_ThrowsForbidden()
    {
        var dbPath = Path.Combine(Path.GetTempPath(), $"fixflow-tests-{Guid.NewGuid():N}.db");
        await using var context = new FixFlowDbContext(TestFixtureFactory.CreateSqliteOptions(dbPath));
        await context.Database.EnsureCreatedAsync();

        var seed = await SeedCompletedBookingAsync(context);
        var otherCustomer = TestFixtureFactory.CreateUser("other@test.local", UserRole.Customer, "Other", "User");
        context.Users.Add(otherCustomer);
        await context.SaveChangesAsync();

        var reviewService = TestFixtureFactory.CreateReviewService(context);

        await Assert.ThrowsAsync<ForbiddenException>(() =>
            reviewService.CreateAsync(
                new CreateReviewRequest { BookingId = seed.BookingId, Rating = 5 },
                otherCustomer.Id));
    }

    [Fact]
    public async Task GetByBookingId_ExistingReview_ReturnsReview()
    {
        var dbPath = Path.Combine(Path.GetTempPath(), $"fixflow-tests-{Guid.NewGuid():N}.db");
        await using var context = new FixFlowDbContext(TestFixtureFactory.CreateSqliteOptions(dbPath));
        await context.Database.EnsureCreatedAsync();

        var seed = await SeedCompletedBookingAsync(context);
        var reviewService = TestFixtureFactory.CreateReviewService(context);

        await reviewService.CreateAsync(
            new CreateReviewRequest { BookingId = seed.BookingId, Rating = 5, Comment = "Odlicno!" },
            seed.CustomerId);

        var review = await reviewService.GetByBookingIdAsync(seed.BookingId);

        Assert.NotNull(review);
        Assert.Equal(5, review.Rating);
        Assert.Equal("Odlicno!", review.Comment);
    }

    private static async Task<ReviewSeed> SeedCompletedBookingAsync(FixFlowDbContext context)
    {
        var customer = TestFixtureFactory.CreateUser("reviewer@test.local", UserRole.Customer, "Amir", "Hodzic");
        var technician = TestFixtureFactory.CreateUser("tech@test.local", UserRole.Technician, "Kemal", "Mehic");
        var category = new RepairCategory { Name = "Laptop" };

        context.AddRange(customer, technician, category);
        await context.SaveChangesAsync();

        var profile = new TechnicianProfile
        {
            UserId = technician.Id,
            Bio = "Test",
            IsVerified = true,
        };
        context.TechnicianProfiles.Add(profile);
        await context.SaveChangesAsync();

        var request = new RepairRequest
        {
            CategoryId = category.Id,
            CustomerId = customer.Id,
            Description = "Laptop ne radi",
            PreferenceType = PreferenceType.DropOff,
            Status = RepairRequestStatus.Completed,
        };
        context.RepairRequests.Add(request);
        await context.SaveChangesAsync();

        var offer = new Offer
        {
            RepairRequestId = request.Id,
            TechnicianId = technician.Id,
            Price = 100,
            EstimatedDays = 3,
            ServiceType = ServiceType.InShop,
            Status = OfferStatus.Accepted,
        };
        context.Offers.Add(offer);
        await context.SaveChangesAsync();

        var booking = new Booking
        {
            RepairRequestId = request.Id,
            OfferId = offer.Id,
            CustomerId = customer.Id,
            TechnicianId = technician.Id,
            JobStatus = JobStatus.Completed,
            TotalAmount = 100,
        };
        context.Bookings.Add(booking);
        await context.SaveChangesAsync();

        return new ReviewSeed(booking.Id, customer.Id, technician.Id);
    }

    private static async Task<ReviewSeed> SeedInProgressBookingAsync(FixFlowDbContext context)
    {
        var customer = TestFixtureFactory.CreateUser("reviewer2@test.local", UserRole.Customer, "Emir", "Basic");
        var technician = TestFixtureFactory.CreateUser("tech2@test.local", UserRole.Technician, "Dino", "Civic");
        var category = new RepairCategory { Name = "Klima" };

        context.AddRange(customer, technician, category);
        await context.SaveChangesAsync();

        var profile = new TechnicianProfile
        {
            UserId = technician.Id,
            Bio = "Test",
            IsVerified = true,
        };
        context.TechnicianProfiles.Add(profile);
        await context.SaveChangesAsync();

        var request = new RepairRequest
        {
            CategoryId = category.Id,
            CustomerId = customer.Id,
            Description = "Klima ne hladi",
            PreferenceType = PreferenceType.OnSite,
            Status = RepairRequestStatus.InProgress,
        };
        context.RepairRequests.Add(request);
        await context.SaveChangesAsync();

        var offer = new Offer
        {
            RepairRequestId = request.Id,
            TechnicianId = technician.Id,
            Price = 50,
            EstimatedDays = 1,
            ServiceType = ServiceType.OnSite,
            Status = OfferStatus.Accepted,
        };
        context.Offers.Add(offer);
        await context.SaveChangesAsync();

        var booking = new Booking
        {
            RepairRequestId = request.Id,
            OfferId = offer.Id,
            CustomerId = customer.Id,
            TechnicianId = technician.Id,
            JobStatus = JobStatus.Diagnostics,
            TotalAmount = 50,
        };
        context.Bookings.Add(booking);
        await context.SaveChangesAsync();

        return new ReviewSeed(booking.Id, customer.Id, technician.Id);
    }

    private sealed record ReviewSeed(int BookingId, int CustomerId, int TechnicianId);
}
