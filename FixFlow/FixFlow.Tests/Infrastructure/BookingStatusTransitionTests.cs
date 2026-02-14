using FixFlow.Application.DTOs.Request;
using FixFlow.Core.Entities;
using FixFlow.Core.Enums;
using FixFlow.Infrastructure.Data;
using FixFlow.Tests.TestSupport;
using Microsoft.EntityFrameworkCore;

namespace FixFlow.Tests.Infrastructure;

public class BookingStatusTransitionTests
{
    [Fact]
    public async Task UpdateJobStatus_AllowsValidTransition()
    {
        var dbPath = Path.Combine(Path.GetTempPath(), $"fixflow-tests-{Guid.NewGuid():N}.db");
        await using var context = new FixFlowDbContext(TestFixtureFactory.CreateSqliteOptions(dbPath));
        await context.Database.EnsureCreatedAsync();

        var seed = await SeedBookingScenarioAsync(context);
        var bookingService = TestFixtureFactory.CreateBookingService(context);

        var result = await bookingService.UpdateJobStatusAsync(
            seed.BookingId,
            new UpdateJobStatusRequest { NewStatus = (int)JobStatus.Diagnostics, Note = "Dijagnostika zapoceta" },
            seed.TechnicianId);

        var request = await context.RepairRequests.SingleAsync(r => r.Id == seed.RepairRequestId);
        Assert.Equal(JobStatus.Diagnostics, result.JobStatus);
        Assert.Equal(RepairRequestStatus.InProgress, request.Status);
    }

    [Fact]
    public async Task UpdateJobStatus_RejectsInvalidTransition()
    {
        var dbPath = Path.Combine(Path.GetTempPath(), $"fixflow-tests-{Guid.NewGuid():N}.db");
        await using var context = new FixFlowDbContext(TestFixtureFactory.CreateSqliteOptions(dbPath));
        await context.Database.EnsureCreatedAsync();

        var seed = await SeedBookingScenarioAsync(context);
        var bookingService = TestFixtureFactory.CreateBookingService(context);

        await Assert.ThrowsAsync<InvalidOperationException>(() =>
            bookingService.UpdateJobStatusAsync(
                seed.BookingId,
                new UpdateJobStatusRequest { NewStatus = (int)JobStatus.Completed },
                seed.TechnicianId));
    }

    private static async Task<BookingSeed> SeedBookingScenarioAsync(FixFlowDbContext context)
    {
        var customer = TestFixtureFactory.CreateUser("customer2@test.local", UserRole.Customer, "Cust", "Two");
        var technician = TestFixtureFactory.CreateUser("tech3@test.local", UserRole.Technician, "Tech", "Three");
        var category = new RepairCategory { Name = "Bicikl" };

        context.AddRange(customer, technician, category);
        await context.SaveChangesAsync();

        var request = new RepairRequest
        {
            CategoryId = category.Id,
            CustomerId = customer.Id,
            Description = "Kocnice ne rade",
            PreferenceType = PreferenceType.OnSite,
            Status = RepairRequestStatus.Accepted,
        };
        context.RepairRequests.Add(request);
        await context.SaveChangesAsync();

        var offer = new Offer
        {
            RepairRequestId = request.Id,
            TechnicianId = technician.Id,
            Price = 60,
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
            JobStatus = JobStatus.Received,
            TotalAmount = offer.Price,
        };
        context.Bookings.Add(booking);
        await context.SaveChangesAsync();

        return new BookingSeed(booking.Id, request.Id, technician.Id);
    }

    private sealed record BookingSeed(int BookingId, int RepairRequestId, int TechnicianId);
}
