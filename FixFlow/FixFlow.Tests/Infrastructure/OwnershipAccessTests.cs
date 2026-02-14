using FixFlow.Application.Exceptions;
using FixFlow.Core.Entities;
using FixFlow.Core.Enums;
using FixFlow.Infrastructure.Data;
using FixFlow.Tests.TestSupport;

namespace FixFlow.Tests.Infrastructure;

public class OwnershipAccessTests
{
    [Fact]
    public async Task Customer_CannotRead_OtherCustomerRepairRequestDetail()
    {
        var dbPath = Path.Combine(Path.GetTempPath(), $"fixflow-tests-{Guid.NewGuid():N}.db");
        await using var context = new FixFlowDbContext(TestFixtureFactory.CreateSqliteOptions(dbPath));
        await context.Database.EnsureCreatedAsync();

        var seed = await SeedOwnershipScenarioAsync(context);
        var service = TestFixtureFactory.CreateRepairRequestService(context);

        await Assert.ThrowsAsync<ForbiddenException>(
            () => service.GetByIdForUserAsync(seed.RepairRequestId, seed.OtherCustomerId, "Customer"));
    }

    [Fact]
    public async Task Technician_CannotRead_BookingThatIsNotAssignedToThem()
    {
        var dbPath = Path.Combine(Path.GetTempPath(), $"fixflow-tests-{Guid.NewGuid():N}.db");
        await using var context = new FixFlowDbContext(TestFixtureFactory.CreateSqliteOptions(dbPath));
        await context.Database.EnsureCreatedAsync();

        var seed = await SeedOwnershipScenarioAsync(context);
        var service = TestFixtureFactory.CreateBookingService(context);

        await Assert.ThrowsAsync<ForbiddenException>(
            () => service.GetByIdForUserAsync(seed.BookingId, seed.OtherTechnicianId, "Technician"));
    }

    [Fact]
    public async Task Admin_CanRead_AllProtectedDetails()
    {
        var dbPath = Path.Combine(Path.GetTempPath(), $"fixflow-tests-{Guid.NewGuid():N}.db");
        await using var context = new FixFlowDbContext(TestFixtureFactory.CreateSqliteOptions(dbPath));
        await context.Database.EnsureCreatedAsync();

        var seed = await SeedOwnershipScenarioAsync(context);
        var repairRequestService = TestFixtureFactory.CreateRepairRequestService(context);
        var offerService = TestFixtureFactory.CreateOfferService(context);
        var bookingService = TestFixtureFactory.CreateBookingService(context);

        var request = await repairRequestService.GetByIdForUserAsync(seed.RepairRequestId, seed.AdminId, "Admin");
        var offer = await offerService.GetByIdForUserAsync(seed.OfferId, seed.AdminId, "Admin");
        var booking = await bookingService.GetByIdForUserAsync(seed.BookingId, seed.AdminId, "Admin");

        Assert.Equal(seed.RepairRequestId, request.Id);
        Assert.Equal(seed.OfferId, offer.Id);
        Assert.Equal(seed.BookingId, booking.Id);
    }

    private static async Task<OwnershipSeed> SeedOwnershipScenarioAsync(FixFlowDbContext context)
    {
        var admin = TestFixtureFactory.CreateUser("admin@test.local", UserRole.Admin, "Admin", "User");
        var ownerCustomer = TestFixtureFactory.CreateUser("owner@test.local", UserRole.Customer, "Owner", "Customer");
        var otherCustomer = TestFixtureFactory.CreateUser("other@test.local", UserRole.Customer, "Other", "Customer");
        var ownerTechnician = TestFixtureFactory.CreateUser("tech-owner@test.local", UserRole.Technician, "Tech", "Owner");
        var otherTechnician = TestFixtureFactory.CreateUser("tech-other@test.local", UserRole.Technician, "Tech", "Other");

        var category = new RepairCategory { Name = "Laptop" };

        context.AddRange(admin, ownerCustomer, otherCustomer, ownerTechnician, otherTechnician, category);
        await context.SaveChangesAsync();

        var request = new RepairRequest
        {
            CategoryId = category.Id,
            CustomerId = ownerCustomer.Id,
            Description = "Laptop se ne pali",
            PreferenceType = PreferenceType.OnSite,
            Address = "Mostar",
            Status = RepairRequestStatus.Accepted,
        };

        context.RepairRequests.Add(request);
        await context.SaveChangesAsync();

        var offer = new Offer
        {
            RepairRequestId = request.Id,
            TechnicianId = ownerTechnician.Id,
            Price = 120,
            EstimatedDays = 2,
            ServiceType = ServiceType.OnSite,
            Note = "Mogu doci danas",
            Status = OfferStatus.Accepted,
        };

        context.Offers.Add(offer);
        await context.SaveChangesAsync();

        var booking = new Booking
        {
            RepairRequestId = request.Id,
            OfferId = offer.Id,
            CustomerId = ownerCustomer.Id,
            TechnicianId = ownerTechnician.Id,
            JobStatus = JobStatus.Received,
            TotalAmount = offer.Price,
        };

        context.Bookings.Add(booking);
        await context.SaveChangesAsync();

        return new OwnershipSeed(
            admin.Id,
            otherCustomer.Id,
            otherTechnician.Id,
            request.Id,
            offer.Id,
            booking.Id);
    }

    private sealed record OwnershipSeed(
        int AdminId,
        int OtherCustomerId,
        int OtherTechnicianId,
        int RepairRequestId,
        int OfferId,
        int BookingId);
}
