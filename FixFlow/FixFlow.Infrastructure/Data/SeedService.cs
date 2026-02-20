using FixFlow.Application.Common;
using FixFlow.Core.Entities;
using FixFlow.Core.Enums;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace FixFlow.Infrastructure.Data;

public class SeedService
{
    private readonly FixFlowDbContext _context;
    private readonly ILogger<SeedService> _logger;

    public SeedService(FixFlowDbContext context, ILogger<SeedService> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task SeedAsync()
    {
        if (await _context.Users.AnyAsync()) return;

        _logger.LogInformation("Seeding database...");

        var now = DateTimeUtils.Now;

        // ── Categories ──────────────────────────────────────────
        var categories = new List<RepairCategory>
        {
            new() { Name = "Laptop", CreatedAt = now },
            new() { Name = "Veš mašina", CreatedAt = now },
            new() { Name = "Mobilni telefon", CreatedAt = now },
            new() { Name = "Klima uređaj", CreatedAt = now },
            new() { Name = "Bicikl", CreatedAt = now },
        };
        await _context.RepairCategories.AddRangeAsync(categories);

        // ── Users ───────────────────────────────────────────────
        var admin = new User
        {
            FirstName = "Admin",
            LastName = "FixFlow",
            Email = "desktop",
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
            Role = UserRole.Admin,
            CreatedAt = now.AddDays(-60),
        };

        var customer = new User
        {
            FirstName = "Amir",
            LastName = "Hodžić",
            Email = "customerMobile",
            Phone = "061222333",
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
            Role = UserRole.Customer,
            CreatedAt = now.AddDays(-30),
        };

        var technician = new User
        {
            FirstName = "Kemal",
            LastName = "Mehić",
            Email = "technicianMobile",
            Phone = "062444555",
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
            Role = UserRole.Technician,
            CreatedAt = now.AddDays(-45),
        };
        await _context.Users.AddRangeAsync(admin, customer, technician);

        // ── TechnicianProfile ───────────────────────────────────
        await _context.TechnicianProfiles.AddAsync(new TechnicianProfile
        {
            User = technician,
            Bio = "10 godina iskustva sa kućanskim aparatima",
            Specialties = "Veš mašine, klima uređaji",
            IsVerified = true,
            AverageRating = 5.0,
            CreatedAt = now.AddDays(-44),
        });

        // ── A: Completed pipeline (payment + review) ────────────
        var requestA = new RepairRequest
        {
            Customer = customer,
            Category = categories[1], // Veš mašina
            Description = "Mašina ne centrifugira, čujan zvuk pri radu.",
            PreferenceType = PreferenceType.OnSite,
            Latitude = 43.3438,
            Longitude = 17.8078,
            Address = "Mostar, BiH",
            Status = RepairRequestStatus.Completed,
            CreatedAt = now.AddDays(-14),
        };

        var offerA = new Offer
        {
            RepairRequest = requestA,
            Technician = technician,
            Price = 80,
            EstimatedDays = 2,
            ServiceType = ServiceType.OnSite,
            Note = "Vjerovatno ležaj bubnja. Imam dio na stanju.",
            Status = OfferStatus.Accepted,
            CreatedAt = now.AddDays(-13),
        };

        var bookingA = new Booking
        {
            RepairRequest = requestA,
            Offer = offerA,
            Customer = customer,
            Technician = technician,
            ScheduledDate = now.AddDays(-11),
            JobStatus = JobStatus.Completed,
            TotalAmount = 80,
            CreatedAt = now.AddDays(-12),
        };

        await _context.RepairRequests.AddAsync(requestA);
        await _context.Offers.AddAsync(offerA);
        await _context.Bookings.AddAsync(bookingA);

        await _context.JobStatusHistories.AddRangeAsync(
            new JobStatusHistory
            {
                Booking = bookingA,
                PreviousStatus = JobStatus.Received,
                NewStatus = JobStatus.Diagnostics,
                ChangedBy = technician,
                CreatedAt = now.AddDays(-11),
            },
            new JobStatusHistory
            {
                Booking = bookingA,
                PreviousStatus = JobStatus.Diagnostics,
                NewStatus = JobStatus.Repaired,
                ChangedBy = technician,
                CreatedAt = now.AddDays(-8),
            },
            new JobStatusHistory
            {
                Booking = bookingA,
                PreviousStatus = JobStatus.Repaired,
                NewStatus = JobStatus.Completed,
                ChangedBy = technician,
                CreatedAt = now.AddDays(-6),
            }
        );

        await _context.Payments.AddAsync(new Payment
        {
            Booking = bookingA,
            User = customer,
            Amount = 80,
            Type = PaymentType.Full,
            Status = PaymentStatus.Completed,
            StripeSessionId = "cs_test_seed_a",
            StripePaymentIntentId = "pi_test_seed_a",
            CreatedAt = now.AddDays(-12),
        });

        await _context.Reviews.AddAsync(new Review
        {
            Booking = bookingA,
            Customer = customer,
            Technician = technician,
            Rating = 5,
            Comment = "Brza i kvalitetna popravka, preporučujem!",
            CreatedAt = now.AddDays(-5),
        });

        // ── B: In-progress booking (no payment yet) ─────────────
        var requestB = new RepairRequest
        {
            Customer = customer,
            Category = categories[3], // Klima
            Description = "Klima ne hladi, samo puše topao zrak.",
            PreferenceType = PreferenceType.OnSite,
            Latitude = 43.3503,
            Longitude = 17.8140,
            Address = "Bulevar, Mostar",
            Status = RepairRequestStatus.InProgress,
            CreatedAt = now.AddDays(-5),
        };

        var offerB = new Offer
        {
            RepairRequest = requestB,
            Technician = technician,
            Price = 120,
            EstimatedDays = 3,
            ServiceType = ServiceType.OnSite,
            Note = "Potrebno punjenje freona, moguća zamjena kompresora.",
            Status = OfferStatus.Accepted,
            CreatedAt = now.AddDays(-4),
        };

        var bookingB = new Booking
        {
            RepairRequest = requestB,
            Offer = offerB,
            Customer = customer,
            Technician = technician,
            ScheduledDate = now.AddDays(2),
            JobStatus = JobStatus.Diagnostics,
            TotalAmount = 120,
            CreatedAt = now.AddDays(-3),
        };

        await _context.RepairRequests.AddAsync(requestB);
        await _context.Offers.AddAsync(offerB);
        await _context.Bookings.AddAsync(bookingB);

        await _context.JobStatusHistories.AddAsync(new JobStatusHistory
        {
            Booking = bookingB,
            PreviousStatus = JobStatus.Received,
            NewStatus = JobStatus.Diagnostics,
            ChangedBy = technician,
            CreatedAt = now.AddDays(-1),
        });

        // ── C: Request with pending offer ───────────────────────
        var requestC = new RepairRequest
        {
            Customer = customer,
            Category = categories[0], // Laptop
            Description = "Laptop se pregrijava i gasi nakon 10 minuta korištenja.",
            PreferenceType = PreferenceType.DropOff,
            Status = RepairRequestStatus.Offered,
            CreatedAt = now.AddDays(-2),
        };

        await _context.RepairRequests.AddAsync(requestC);
        await _context.Offers.AddAsync(new Offer
        {
            RepairRequest = requestC,
            Technician = technician,
            Price = 60,
            EstimatedDays = 1,
            ServiceType = ServiceType.InShop,
            Note = "Čišćenje ventilacije i zamjena termalne paste.",
            Status = OfferStatus.Pending,
            CreatedAt = now.AddDays(-1),
        });

        // ── D: Fresh open request (no offers) ───────────────────
        await _context.RepairRequests.AddAsync(new RepairRequest
        {
            Customer = customer,
            Category = categories[2], // Mobilni telefon
            Description = "Ekran telefona ne reagira na dodir u donjem dijelu.",
            PreferenceType = PreferenceType.DropOff,
            Status = RepairRequestStatus.Open,
            CreatedAt = now.AddDays(-1),
        });

        await _context.SaveChangesAsync();

        _logger.LogInformation("Database seeded successfully");
    }
}
