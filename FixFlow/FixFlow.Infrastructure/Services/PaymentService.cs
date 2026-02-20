using FixFlow.Application.Common;
using FixFlow.Application.DTOs.Request;
using FixFlow.Application.DTOs.Response;
using FixFlow.Application.Filters;
using FixFlow.Application.Helpers;
using FixFlow.Application.IRepositories;
using FixFlow.Application.IServices;
using FixFlow.Core.Entities;
using FixFlow.Core.Enums;
using Mapster;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Stripe;

namespace FixFlow.Infrastructure.Services;

public class PaymentService : IPaymentService
{
    private readonly IRepository<Payment> _repository;
    private readonly IRepository<Booking> _bookingRepository;
    private readonly ILogger<PaymentService> _logger;

    public PaymentService(
        IRepository<Payment> repository,
        IRepository<Booking> bookingRepository,
        IConfiguration configuration,
        ILogger<PaymentService> logger)
    {
        _repository = repository;
        _bookingRepository = bookingRepository;
        _logger = logger;
    }

    public async Task<CheckoutResponse> CreatePaymentIntentAsync(CreateCheckoutRequest request, int userId)
    {
        var booking = await _bookingRepository.AsQueryable()
            .Include(b => b.Offer)
            .FirstOrDefaultAsync(b => b.Id == request.BookingId)
            ?? throw new KeyNotFoundException("Posao nije pronađen.");

        if (booking.CustomerId != userId)
            throw new UnauthorizedAccessException("Nemate pristup ovom poslu.");

        var existingPayment = await _repository.AsQueryable()
            .AnyAsync(p => p.BookingId == request.BookingId
                && (p.Status == PaymentStatus.Completed || p.Status == PaymentStatus.Pending));
        if (existingPayment)
            throw new InvalidOperationException("Uplata za ovaj posao već postoji.");

        var amount = booking.TotalAmount > 0 ? booking.TotalAmount : booking.Offer.Price;
        var amountInCents = (long)(amount * 100);

        var options = new PaymentIntentCreateOptions
        {
            Amount = amountInCents,
            Currency = "bam",
            PaymentMethodTypes = new List<string> { "card" },
            Metadata = new Dictionary<string, string>
            {
                { "bookingId", booking.Id.ToString() },
                { "userId", userId.ToString() },
            },
        };

        var service = new PaymentIntentService();
        var intent = await service.CreateAsync(options);

        var payment = new Payment
        {
            BookingId = booking.Id,
            UserId = userId,
            Amount = amount,
            Type = PaymentType.Full,
            Status = PaymentStatus.Pending,
            StripePaymentIntentId = intent.Id,
        };
        await _repository.AddAsync(payment);

        _logger.LogInformation("PaymentIntent {IntentId} created for booking {BookingId}",
            intent.Id, booking.Id);

        return new CheckoutResponse
        {
            ClientSecret = intent.ClientSecret,
            PaymentIntentId = intent.Id,
            Amount = amount,
        };
    }

    public async Task<PaymentResponse> ConfirmPaymentAsync(ConfirmPaymentRequest request, int userId)
    {
        var payment = await _repository.AsQueryable()
            .Include(p => p.User)
            .FirstOrDefaultAsync(p => p.StripePaymentIntentId == request.PaymentIntentId
                && p.BookingId == request.BookingId)
            ?? throw new KeyNotFoundException("Uplata nije pronađena.");

        if (payment.UserId != userId)
            throw new UnauthorizedAccessException("Nemate pristup ovoj uplati.");

        if (payment.Status == PaymentStatus.Completed)
            return payment.Adapt<PaymentResponse>();

        var service = new PaymentIntentService();
        var intent = await service.GetAsync(request.PaymentIntentId);

        if (intent.Status != "succeeded")
            throw new InvalidOperationException("Uplata nije uspjela. Pokušajte ponovo.");

        if (intent.Metadata.TryGetValue("userId", out var metaUserId)
            && metaUserId != userId.ToString())
            throw new UnauthorizedAccessException("Nemate pristup ovoj uplati.");

        var expectedAmount = (long)(payment.Amount * 100);
        if (intent.Amount != expectedAmount)
            throw new InvalidOperationException("Iznos uplate se ne podudara.");

        payment.Status = PaymentStatus.Completed;
        await _repository.UpdateAsync(payment);

        _logger.LogInformation("Payment {PaymentId} confirmed for booking {BookingId}",
            payment.Id, payment.BookingId);

        return payment.Adapt<PaymentResponse>();
    }

    public async Task<PaymentResponse?> GetByBookingIdAsync(int bookingId)
    {
        var payment = await BuildQuery()
            .FirstOrDefaultAsync(p => p.BookingId == bookingId);

        return payment?.Adapt<PaymentResponse>();
    }

    public async Task<PagedResult<PaymentResponse>> GetAllAsync(PaymentQueryFilter filter)
    {
        var query = BuildQuery();
        query = ApplyFilter(query, filter);

        var totalCount = await query.CountAsync();
        var items = await query
            .OrderByDescending(p => p.CreatedAt)
            .Skip((filter.PageNumber - 1) * filter.PageSize)
            .Take(filter.PageSize)
            .ToListAsync();

        return new PagedResult<PaymentResponse>
        {
            Items = items.Adapt<List<PaymentResponse>>(),
            TotalCount = totalCount,
            PageNumber = filter.PageNumber,
            PageSize = filter.PageSize,
        };
    }

    public async Task<PaymentResponse> RefundAsync(CreateRefundRequest request)
    {
        var payment = await BuildQuery()
            .FirstOrDefaultAsync(p => p.Id == request.PaymentId)
            ?? throw new KeyNotFoundException("Uplata nije pronađena.");

        if (payment.Status != PaymentStatus.Completed)
            throw new InvalidOperationException("Samo završene uplate se mogu refundirati.");

        if (string.IsNullOrEmpty(payment.StripePaymentIntentId))
            throw new InvalidOperationException("Uplata nema Stripe referencu za refund.");

        var refundOptions = new RefundCreateOptions
        {
            PaymentIntent = payment.StripePaymentIntentId,
            Reason = "requested_by_customer",
        };

        var refundService = new RefundService();
        await refundService.CreateAsync(refundOptions);

        payment.Status = PaymentStatus.Refunded;
        await _repository.UpdateAsync(payment);

        _logger.LogInformation("Payment {PaymentId} refunded. Reason: {Reason}",
            payment.Id, request.Reason ?? "N/A");

        return payment.Adapt<PaymentResponse>();
    }

    private IQueryable<Payment> BuildQuery()
    {
        return _repository.AsQueryable()
            .Include(p => p.User);
    }

    private static IQueryable<Payment> ApplyFilter(IQueryable<Payment> query, PaymentQueryFilter filter)
    {
        return query
            .WhereIf(filter.BookingId.HasValue, p => p.BookingId == filter.BookingId!.Value)
            .WhereIf(filter.UserId.HasValue, p => p.UserId == filter.UserId!.Value)
            .WhereIf(filter.Status.HasValue, p => p.Status == filter.Status!.Value)
            .WhereIf(filter.Type.HasValue, p => p.Type == filter.Type!.Value);
    }
}
