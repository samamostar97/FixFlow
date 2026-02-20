using FixFlow.Application.DTOs.Request;
using FixFlow.Core.Entities;
using FixFlow.Core.Enums;
using FixFlow.Infrastructure.Data;
using FixFlow.Tests.TestSupport;
using Microsoft.EntityFrameworkCore;

namespace FixFlow.Tests.Infrastructure;

public class PaymentCheckoutTests
{
    private static async Task<(int CustomerId, int TechnicianId, int BookingId)>
        SeedBookingAsync(FixFlowDbContext context)
    {
        var customer = TestFixtureFactory.CreateUser("cust@test.com", UserRole.Customer, "Amir", "H");
        var technician = TestFixtureFactory.CreateUser("tech@test.com", UserRole.Technician, "Kemal", "M");
        context.Users.AddRange(customer, technician);

        var category = new RepairCategory { Name = "Test" };
        context.RepairCategories.Add(category);

        var request = new RepairRequest
        {
            Customer = customer,
            Category = category,
            Description = "Test repair",
            PreferenceType = PreferenceType.OnSite,
            Status = RepairRequestStatus.Accepted,
        };
        context.RepairRequests.Add(request);

        var offer = new Offer
        {
            RepairRequest = request,
            Technician = technician,
            Price = 100,
            EstimatedDays = 3,
            ServiceType = ServiceType.OnSite,
            Status = OfferStatus.Accepted,
        };
        context.Offers.Add(offer);

        var booking = new Booking
        {
            RepairRequest = request,
            Offer = offer,
            Customer = customer,
            Technician = technician,
            JobStatus = JobStatus.Received,
            TotalAmount = 100,
        };
        context.Bookings.Add(booking);
        await context.SaveChangesAsync();

        return (customer.Id, technician.Id, booking.Id);
    }

    [Fact]
    public async Task CreatePaymentIntent_WrongOwner_ThrowsUnauthorized()
    {
        var dbPath = Path.Combine(Path.GetTempPath(), $"fixflow-tests-{Guid.NewGuid():N}.db");
        await using var context = new FixFlowDbContext(TestFixtureFactory.CreateSqliteOptions(dbPath));
        await context.Database.EnsureCreatedAsync();

        var (_, technicianId, bookingId) = await SeedBookingAsync(context);
        var service = TestFixtureFactory.CreatePaymentService(context);

        await Assert.ThrowsAsync<UnauthorizedAccessException>(
            () => service.CreatePaymentIntentAsync(
                new CreateCheckoutRequest { BookingId = bookingId },
                technicianId));
    }

    [Fact]
    public async Task CreatePaymentIntent_BookingNotFound_ThrowsKeyNotFound()
    {
        var dbPath = Path.Combine(Path.GetTempPath(), $"fixflow-tests-{Guid.NewGuid():N}.db");
        await using var context = new FixFlowDbContext(TestFixtureFactory.CreateSqliteOptions(dbPath));
        await context.Database.EnsureCreatedAsync();

        var service = TestFixtureFactory.CreatePaymentService(context);

        await Assert.ThrowsAsync<KeyNotFoundException>(
            () => service.CreatePaymentIntentAsync(
                new CreateCheckoutRequest { BookingId = 9999 },
                1));
    }

    [Fact]
    public async Task CreatePaymentIntent_DuplicatePayment_ThrowsInvalidOperation()
    {
        var dbPath = Path.Combine(Path.GetTempPath(), $"fixflow-tests-{Guid.NewGuid():N}.db");
        await using var context = new FixFlowDbContext(TestFixtureFactory.CreateSqliteOptions(dbPath));
        await context.Database.EnsureCreatedAsync();

        var (customerId, _, bookingId) = await SeedBookingAsync(context);

        context.Payments.Add(new Payment
        {
            BookingId = bookingId,
            UserId = customerId,
            Amount = 100,
            Type = PaymentType.Full,
            Status = PaymentStatus.Completed,
        });
        await context.SaveChangesAsync();

        var service = TestFixtureFactory.CreatePaymentService(context);

        await Assert.ThrowsAsync<InvalidOperationException>(
            () => service.CreatePaymentIntentAsync(
                new CreateCheckoutRequest { BookingId = bookingId },
                customerId));
    }

    [Fact]
    public async Task ConfirmPayment_PaymentNotFound_ThrowsKeyNotFound()
    {
        var dbPath = Path.Combine(Path.GetTempPath(), $"fixflow-tests-{Guid.NewGuid():N}.db");
        await using var context = new FixFlowDbContext(TestFixtureFactory.CreateSqliteOptions(dbPath));
        await context.Database.EnsureCreatedAsync();

        var service = TestFixtureFactory.CreatePaymentService(context);

        await Assert.ThrowsAsync<KeyNotFoundException>(
            () => service.ConfirmPaymentAsync(
                new ConfirmPaymentRequest
                {
                    BookingId = 999,
                    PaymentIntentId = "pi_nonexistent",
                },
                1));
    }

    [Fact]
    public async Task ConfirmPayment_WrongOwner_ThrowsUnauthorized()
    {
        var dbPath = Path.Combine(Path.GetTempPath(), $"fixflow-tests-{Guid.NewGuid():N}.db");
        await using var context = new FixFlowDbContext(TestFixtureFactory.CreateSqliteOptions(dbPath));
        await context.Database.EnsureCreatedAsync();

        var (customerId, technicianId, bookingId) = await SeedBookingAsync(context);

        context.Payments.Add(new Payment
        {
            BookingId = bookingId,
            UserId = customerId,
            Amount = 100,
            Type = PaymentType.Full,
            Status = PaymentStatus.Pending,
            StripePaymentIntentId = "pi_test_123",
        });
        await context.SaveChangesAsync();

        var service = TestFixtureFactory.CreatePaymentService(context);

        await Assert.ThrowsAsync<UnauthorizedAccessException>(
            () => service.ConfirmPaymentAsync(
                new ConfirmPaymentRequest
                {
                    BookingId = bookingId,
                    PaymentIntentId = "pi_test_123",
                },
                technicianId));
    }

    [Fact]
    public async Task GetByBookingId_ReturnsPayment()
    {
        var dbPath = Path.Combine(Path.GetTempPath(), $"fixflow-tests-{Guid.NewGuid():N}.db");
        await using var context = new FixFlowDbContext(TestFixtureFactory.CreateSqliteOptions(dbPath));
        await context.Database.EnsureCreatedAsync();

        var (customerId, _, bookingId) = await SeedBookingAsync(context);

        context.Payments.Add(new Payment
        {
            BookingId = bookingId,
            UserId = customerId,
            Amount = 100,
            Type = PaymentType.Full,
            Status = PaymentStatus.Completed,
        });
        await context.SaveChangesAsync();

        var service = TestFixtureFactory.CreatePaymentService(context);
        var result = await service.GetByBookingIdAsync(bookingId);

        Assert.NotNull(result);
        Assert.Equal(100m, result!.Amount);
        Assert.Equal(PaymentStatus.Completed, result.Status);
        Assert.Equal("Amir", result.UserFirstName);
    }

    [Fact]
    public async Task Refund_NonCompletedPayment_ThrowsInvalidOperation()
    {
        var dbPath = Path.Combine(Path.GetTempPath(), $"fixflow-tests-{Guid.NewGuid():N}.db");
        await using var context = new FixFlowDbContext(TestFixtureFactory.CreateSqliteOptions(dbPath));
        await context.Database.EnsureCreatedAsync();

        var (customerId, _, bookingId) = await SeedBookingAsync(context);

        context.Payments.Add(new Payment
        {
            BookingId = bookingId,
            UserId = customerId,
            Amount = 100,
            Type = PaymentType.Full,
            Status = PaymentStatus.Pending,
        });
        await context.SaveChangesAsync();

        var payment = await context.Payments.FirstAsync();
        var service = TestFixtureFactory.CreatePaymentService(context);

        await Assert.ThrowsAsync<InvalidOperationException>(
            () => service.RefundAsync(new CreateRefundRequest
            {
                PaymentId = payment.Id,
                Reason = "Test",
            }));
    }
}
