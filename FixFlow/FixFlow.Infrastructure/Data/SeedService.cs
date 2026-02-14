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

        // 1. Categories
        var categories = new List<RepairCategory>
        {
            new() { Name = "Laptop" },
            new() { Name = "Veš mašina" },
            new() { Name = "Mobilni telefon" },
            new() { Name = "Klima uređaj" },
            new() { Name = "Bicikl" },
        };
        await _context.RepairCategories.AddRangeAsync(categories);

        // 2. Admin
        var admin = new User
        {
            FirstName = "Admin",
            LastName = "FixFlow",
            Email = "desktop",
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
            Role = UserRole.Admin,
        };
        await _context.Users.AddAsync(admin);

        // 3. Customer
        var customer = new User
        {
            FirstName = "Amir",
            LastName = "Hodžić",
            Email = "customerMobile",
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
            Role = UserRole.Customer,
        };

        // 4. Technician
        var technician = new User
        {
            FirstName = "Kemal",
            LastName = "Mehić",
            Email = "technicianMobile",
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
            Role = UserRole.Technician,
        };
        await _context.Users.AddRangeAsync(customer, technician);

        // 5. TechnicianProfile
        await _context.TechnicianProfiles.AddAsync(new TechnicianProfile
        {
            User = technician,
            Bio = "10 godina iskustva sa kućanskim aparatima",
            Specialties = "Veš mašine, klima uređaji",
            IsVerified = true,
        });

        // 6. Sample RepairRequests
        var request1 = new RepairRequest
        {
            Customer = customer,
            Category = categories[1], // Veš mašina
            Description = "Mašina ne centrifugira, čujan zvuk pri radu.",
            PreferenceType = PreferenceType.OnSite,
            Latitude = 43.3438,
            Longitude = 17.8078,
            Address = "Mostar, BiH",
            Status = RepairRequestStatus.Offered,
        };

        var request2 = new RepairRequest
        {
            Customer = customer,
            Category = categories[0], // Laptop
            Description = "Laptop se pregrijava i gasi nakon 10 minuta korištenja.",
            PreferenceType = PreferenceType.DropOff,
            Status = RepairRequestStatus.Open,
        };

        var request3 = new RepairRequest
        {
            Customer = customer,
            Category = categories[3], // Klima
            Description = "Klima ne hladi, samo puše topao zrak.",
            PreferenceType = PreferenceType.OnSite,
            Latitude = 43.3503,
            Longitude = 17.8140,
            Address = "Bulevar, Mostar",
            Status = RepairRequestStatus.Open,
        };
        await _context.RepairRequests.AddRangeAsync(request1, request2, request3);

        // 7. Sample Offer on request1 (accepted)
        var offer = new Offer
        {
            RepairRequest = request1,
            Technician = technician,
            Price = 80,
            EstimatedDays = 2,
            ServiceType = ServiceType.OnSite,
            Note = "Vjerovatno ležaj bubnja. Imam dio na stanju.",
            Status = OfferStatus.Accepted,
        };
        await _context.Offers.AddAsync(offer);

        // Update request1 to completed (booking went through full pipeline)
        request1.Status = RepairRequestStatus.Completed;

        // 8. Sample Booking (completed)
        var booking = new Booking
        {
            RepairRequest = request1,
            Offer = offer,
            Customer = customer,
            Technician = technician,
            JobStatus = JobStatus.Completed,
            TotalAmount = 80,
        };
        await _context.Bookings.AddAsync(booking);

        // 9. Status history — every transition logged
        await _context.JobStatusHistories.AddRangeAsync(
            new JobStatusHistory
            {
                Booking = booking,
                PreviousStatus = JobStatus.Received,
                NewStatus = JobStatus.Received,
                Note = "Posao kreiran.",
                ChangedBy = customer,
            },
            new JobStatusHistory
            {
                Booking = booking,
                PreviousStatus = JobStatus.Received,
                NewStatus = JobStatus.Diagnostics,
                ChangedBy = technician,
            },
            new JobStatusHistory
            {
                Booking = booking,
                PreviousStatus = JobStatus.Diagnostics,
                NewStatus = JobStatus.Repaired,
                ChangedBy = technician,
            },
            new JobStatusHistory
            {
                Booking = booking,
                PreviousStatus = JobStatus.Repaired,
                NewStatus = JobStatus.Completed,
                ChangedBy = technician,
            }
        );

        await _context.SaveChangesAsync();

        _logger.LogInformation("Database seeded successfully");
    }
}
