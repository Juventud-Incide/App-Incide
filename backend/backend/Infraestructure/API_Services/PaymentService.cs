using backend.Data.DataDB;
using backend.Data.Entities;
using backend.Domain.DTOs.Payment;
using backend.Domain.Enum;
using backend.Domain.OutPutDTOs.Payment;
using backend.Infraestructure.API_Services_Interfaces;
using backend.Infraestructure.Configuration;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Stripe;

namespace backend.Infraestructure.API_Services
{
    public class PaymentService : IPaymentService
    {
        private readonly AppDbContext          _context;
        private readonly IStripeService        _stripe;
        private readonly INotificationService  _notifications;
        private readonly StripeOptions         _stripeOptions;

        public PaymentService(
            AppDbContext context,
            IStripeService stripe,
            INotificationService notifications,
            IOptions<StripeOptions> stripeOptions)
        {
            _context       = context;
            _stripe        = stripe;
            _notifications = notifications;
            _stripeOptions = stripeOptions.Value;
        }

        // ── Mapper ───────────────────────────────────────────────────────────

        private static PaymentOutPutDTO ToDTO(Payment p) => new()
        {
            Id            = p.Id,
            Folio         = $"PAY-{p.Id:D6}",
            CotizacionId  = p.CotizacionId,
            Status        = p.Status.ToString(),
            Amount        = p.Amount,
            Currency      = p.Currency,
            ProviderName  = $"{p.Provider.User.FirstName} {p.Provider.User.LastName}",
            FailureReason = p.FailureReason,
            CreationDate  = p.CreationDate,
            PaidAt        = p.PaidAt,
            ReleasedAt    = p.ReleasedAt
        };

        private PaymentInitiatedOutPutDTO ToInitiatedDTO(Payment p) => new()
        {
            Id             = p.Id,
            Folio          = $"PAY-{p.Id:D6}",
            ClientSecret   = p.StripeClientSecret ?? string.Empty,
            PublishableKey = _stripeOptions.PublishableKey,
            Amount         = p.Amount,
            Currency       = p.Currency
        };

        // ── InitiateAsync ────────────────────────────────────────────────────

        public async Task<PaymentInitiatedOutPutDTO> InitiateAsync(
            int userId, InitiatePaymentDTO dto, CancellationToken ct)
        {
            var client = await _context.Clients
                .FirstOrDefaultAsync(c => c.UserId == userId, ct)
                ?? throw new InvalidOperationException("No client profile found for this user.");

            var cotizacion = await _context.Cotizaciones
                .Include(c => c.Provider).ThenInclude(p => p.User)
                .Include(c => c.ServiceRequest).ThenInclude(sr => sr.ServiceItem)
                .FirstOrDefaultAsync(c => c.Id == dto.CotizacionId && !c.IsDeleted, ct)
                ?? throw new KeyNotFoundException("Cotizacion not found.");

            if (cotizacion.ServiceRequest.ClientId != client.Id)
                throw new InvalidOperationException("This cotizacion does not belong to you.");

            if (cotizacion.Status != CotizacionStatus.Accepted)
                throw new InvalidOperationException("Only accepted cotizaciones can be paid.");

            // Idempotency: return existing Pending payment for this cotizacion
            var existing = await _context.Payments
                .FirstOrDefaultAsync(p => p.CotizacionId == dto.CotizacionId
                                       && !p.IsDeleted
                                       && p.Status == PaymentStatus.Pending, ct);

            if (existing != null)
                return ToInitiatedDTO(existing);

            var description = $"INCIDE - {cotizacion.ServiceRequest.ServiceItem.Name}";
            var (intentId, clientSecret) = await _stripe.CreatePaymentIntentAsync(
                cotizacion.Amount, cotizacion.Currency, description, ct);

            var payment = new Payment
            {
                CotizacionId          = cotizacion.Id,
                ClientId              = client.Id,
                ProviderId            = cotizacion.ProviderId,
                Amount                = cotizacion.Amount,
                Currency              = cotizacion.Currency,
                Status                = PaymentStatus.Pending,
                StripePaymentIntentId = intentId,
                StripeClientSecret    = clientSecret,
                CreationDate          = DateTime.UtcNow,
                LastUpdate            = DateTime.UtcNow,
                IsActive              = true
            };

            _context.Payments.Add(payment);
            await _context.SaveChangesAsync(ct);

            return ToInitiatedDTO(payment);
        }

        // ── HandleWebhookAsync ───────────────────────────────────────────────

        public async Task HandleWebhookAsync(
            string payload, string stripeSignature, CancellationToken ct)
        {
            Event stripeEvent;
            try
            {
                stripeEvent = _stripe.ConstructWebhookEvent(payload, stripeSignature);
            }
            catch (StripeException)
            {
                throw new InvalidOperationException("Invalid Stripe webhook signature.");
            }

            var payment = stripeEvent.Type switch
            {
                "payment_intent.succeeded"      => await ResolvePaymentByIntent(stripeEvent, ct),
                "payment_intent.payment_failed" => await ResolvePaymentByIntent(stripeEvent, ct),
                "charge.refunded"               => await ResolvePaymentByCharge(stripeEvent, ct),
                _                               => null
            };

            if (payment == null) return;

            // Idempotency guard
            if (payment.StripeLastEventId == stripeEvent.Id) return;

            switch (stripeEvent.Type)
            {
                case "payment_intent.succeeded":
                    var intent = stripeEvent.Data.Object as PaymentIntent;
                    payment.Status        = PaymentStatus.Succeeded;
                    payment.PaidAt        = DateTime.UtcNow;
                    payment.StripeChargeId = intent?.LatestChargeId;
                    break;

                case "payment_intent.payment_failed":
                    var failedIntent = stripeEvent.Data.Object as PaymentIntent;
                    payment.Status        = PaymentStatus.Failed;
                    payment.FailureReason = failedIntent?.LastPaymentError?.Message;
                    break;

                case "charge.refunded":
                    payment.Status = PaymentStatus.Refunded;
                    break;
            }

            payment.StripeLastEventId = stripeEvent.Id;
            payment.LastUpdate        = DateTime.UtcNow;
            await _context.SaveChangesAsync(ct);

            if (stripeEvent.Type == "payment_intent.succeeded")
            {
                var cotizacion = await _context.Cotizaciones
                    .Include(c => c.ServiceRequest).ThenInclude(sr => sr.ServiceItem)
                    .Include(c => c.Provider).ThenInclude(p => p.User)
                    .FirstOrDefaultAsync(c => c.Id == payment.CotizacionId, ct);

                var client = await _context.Clients
                    .Include(c => c.User)
                    .FirstOrDefaultAsync(c => c.Id == payment.ClientId, ct);

                if (cotizacion != null && client != null)
                    await _notifications.NotifyPaymentSucceededAsync(
                        payment, client, cotizacion.Provider, cotizacion.ServiceRequest, ct);
            }
        }

        // ── GetMyPaymentsAsync ───────────────────────────────────────────────

        public async Task<List<PaymentOutPutDTO>> GetMyPaymentsAsync(int userId, CancellationToken ct)
        {
            var client = await _context.Clients
                .FirstOrDefaultAsync(c => c.UserId == userId, ct)
                ?? throw new InvalidOperationException("No client profile found for this user.");

            return await _context.Payments
                .Include(p => p.Provider).ThenInclude(p => p.User)
                .Where(p => p.ClientId == client.Id && !p.IsDeleted)
                .OrderByDescending(p => p.CreationDate)
                .Select(p => ToDTO(p))
                .ToListAsync(ct);
        }

        // ── GetByIdAsync ─────────────────────────────────────────────────────

        public async Task<PaymentOutPutDTO?> GetByIdAsync(int paymentId, int userId, CancellationToken ct)
        {
            var payment = await _context.Payments
                .Include(p => p.Provider).ThenInclude(p => p.User)
                .Include(p => p.Client)
                .FirstOrDefaultAsync(p => p.Id == paymentId && !p.IsDeleted, ct);

            if (payment == null) return null;

            var isClient   = payment.Client.UserId == userId;
            var isProvider = payment.Provider.UserId == userId;

            if (!isClient && !isProvider) return null;

            return ToDTO(payment);
        }

        // ── ReleaseAsync ─────────────────────────────────────────────────────

        public async Task<PaymentOutPutDTO> ReleaseAsync(int paymentId, int userId, CancellationToken ct)
        {
            var client = await _context.Clients
                .FirstOrDefaultAsync(c => c.UserId == userId, ct)
                ?? throw new InvalidOperationException("No client profile found for this user.");

            var payment = await _context.Payments
                .Include(p => p.Provider).ThenInclude(p => p.User)
                .FirstOrDefaultAsync(p => p.Id == paymentId && !p.IsDeleted, ct)
                ?? throw new KeyNotFoundException("Payment not found.");

            if (payment.ClientId != client.Id)
                throw new InvalidOperationException("This payment does not belong to you.");

            if (payment.Status != PaymentStatus.Succeeded)
                throw new InvalidOperationException("Only succeeded payments can be released.");

            payment.Status     = PaymentStatus.Released;
            payment.ReleasedAt = DateTime.UtcNow;
            payment.LastUpdate = DateTime.UtcNow;

            await _context.SaveChangesAsync(ct);
            return ToDTO(payment);
        }

        // ── Helpers ──────────────────────────────────────────────────────────

        private async Task<Payment?> ResolvePaymentByIntent(Event stripeEvent, CancellationToken ct)
        {
            var intent = stripeEvent.Data.Object as PaymentIntent;
            if (intent == null) return null;

            return await _context.Payments
                .FirstOrDefaultAsync(p => p.StripePaymentIntentId == intent.Id && !p.IsDeleted, ct);
        }

        private async Task<Payment?> ResolvePaymentByCharge(Event stripeEvent, CancellationToken ct)
        {
            var charge = stripeEvent.Data.Object as Charge;
            if (charge == null) return null;

            return await _context.Payments
                .FirstOrDefaultAsync(p => p.StripeChargeId == charge.Id && !p.IsDeleted, ct);
        }
    }
}
