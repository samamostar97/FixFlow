using FixFlow.Application.Exceptions;
using FixFlow.Core.Entities;
using FixFlow.Core.Enums;
using FixFlow.Infrastructure.Data;
using FixFlow.Tests.TestSupport;
using Microsoft.EntityFrameworkCore;

namespace FixFlow.Tests.Infrastructure;

public class OfferAcceptanceTests
{
    [Fact]
    public async Task AcceptOffer_CreatesOneBooking_AndRejectsOtherPendingOffers()
    {
        var dbPath = Path.Combine(Path.GetTempPath(), $"fixflow-tests-{Guid.NewGuid():N}.db");
        await using var context = new FixFlowDbContext(TestFixtureFactory.CreateSqliteOptions(dbPath));
        await context.Database.EnsureCreatedAsync();

        var seed = await SeedOfferScenarioAsync(context);
        var service = TestFixtureFactory.CreateOfferService(context);

        await service.AcceptOfferAsync(seed.FirstOfferId, seed.CustomerId);

        var request = await context.RepairRequests.SingleAsync(r => r.Id == seed.RepairRequestId);
        var offers = await context.Offers.Where(o => o.RepairRequestId == seed.RepairRequestId).ToListAsync();
        var bookings = await context.Bookings.Where(b => b.RepairRequestId == seed.RepairRequestId).ToListAsync();

        Assert.Equal(RepairRequestStatus.Accepted, request.Status);
        Assert.Single(bookings);
        Assert.Equal(1, offers.Count(o => o.Status == OfferStatus.Accepted));
        Assert.Equal(1, offers.Count(o => o.Status == OfferStatus.Rejected));
    }

    [Fact]
    public async Task ParallelAcceptOffer_DoesNotCreateDuplicateBooking()
    {
        var dbPath = Path.Combine(Path.GetTempPath(), $"fixflow-tests-{Guid.NewGuid():N}.db");
        await using (var context = new FixFlowDbContext(TestFixtureFactory.CreateSqliteOptions(dbPath)))
        {
            await context.Database.EnsureCreatedAsync();
            _ = await SeedOfferScenarioAsync(context);
        }

        var seed = await LoadSeedAsync(dbPath);

        var firstAccept = TryAcceptAsync(dbPath, seed.FirstOfferId, seed.CustomerId);
        var secondAccept = TryAcceptAsync(dbPath, seed.SecondOfferId, seed.CustomerId);
        var outcomes = await Task.WhenAll(firstAccept, secondAccept);

        Assert.Equal(1, outcomes.Count(o => o.Succeeded));
        Assert.Equal(1, outcomes.Count(o => !o.Succeeded));
        Assert.Contains(
            outcomes.Where(o => !o.Succeeded),
            o => o.Error is ConflictException or InvalidOperationException);

        await using var verificationContext = new FixFlowDbContext(TestFixtureFactory.CreateSqliteOptions(dbPath));
        var bookings = await verificationContext.Bookings
            .Where(b => b.RepairRequestId == seed.RepairRequestId)
            .ToListAsync();
        var offers = await verificationContext.Offers
            .Where(o => o.RepairRequestId == seed.RepairRequestId)
            .ToListAsync();

        Assert.Single(bookings);
        Assert.Equal(1, offers.Count(o => o.Status == OfferStatus.Accepted));
    }

    private static async Task<AcceptOutcome> TryAcceptAsync(string dbPath, int offerId, int customerId)
    {
        try
        {
            await using var context = new FixFlowDbContext(TestFixtureFactory.CreateSqliteOptions(dbPath));
            var service = TestFixtureFactory.CreateOfferService(context);
            await service.AcceptOfferAsync(offerId, customerId);
            return new AcceptOutcome(true, null);
        }
        catch (Exception ex)
        {
            return new AcceptOutcome(false, ex);
        }
    }

    private static async Task<OfferSeed> SeedOfferScenarioAsync(FixFlowDbContext context)
    {
        var customer = TestFixtureFactory.CreateUser("customer@test.local", UserRole.Customer, "Cust", "One");
        var technicianOne = TestFixtureFactory.CreateUser("tech1@test.local", UserRole.Technician, "Tech", "One");
        var technicianTwo = TestFixtureFactory.CreateUser("tech2@test.local", UserRole.Technician, "Tech", "Two");
        var category = new RepairCategory { Name = "Laptop" };

        context.AddRange(customer, technicianOne, technicianTwo, category);
        await context.SaveChangesAsync();

        var request = new RepairRequest
        {
            CategoryId = category.Id,
            CustomerId = customer.Id,
            Description = "Laptop usporen i pregrijava se",
            PreferenceType = PreferenceType.DropOff,
            Status = RepairRequestStatus.Open,
        };
        context.RepairRequests.Add(request);
        await context.SaveChangesAsync();

        var firstOffer = new Offer
        {
            RepairRequestId = request.Id,
            TechnicianId = technicianOne.Id,
            Price = 80,
            EstimatedDays = 2,
            ServiceType = ServiceType.InShop,
            Status = OfferStatus.Pending,
        };
        var secondOffer = new Offer
        {
            RepairRequestId = request.Id,
            TechnicianId = technicianTwo.Id,
            Price = 75,
            EstimatedDays = 3,
            ServiceType = ServiceType.InShop,
            Status = OfferStatus.Pending,
        };

        context.AddRange(firstOffer, secondOffer);
        await context.SaveChangesAsync();

        return new OfferSeed(customer.Id, request.Id, firstOffer.Id, secondOffer.Id);
    }

    private static async Task<OfferSeed> LoadSeedAsync(string dbPath)
    {
        await using var context = new FixFlowDbContext(TestFixtureFactory.CreateSqliteOptions(dbPath));
        var request = await context.RepairRequests.SingleAsync();
        var customerId = request.CustomerId;
        var offers = await context.Offers
            .Where(o => o.RepairRequestId == request.Id)
            .OrderBy(o => o.Id)
            .ToListAsync();

        return new OfferSeed(customerId, request.Id, offers[0].Id, offers[1].Id);
    }

    private sealed record OfferSeed(int CustomerId, int RepairRequestId, int FirstOfferId, int SecondOfferId);
    private sealed record AcceptOutcome(bool Succeeded, Exception? Error);
}
