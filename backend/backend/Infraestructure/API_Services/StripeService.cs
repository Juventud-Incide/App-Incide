using backend.Infraestructure.API_Services_Interfaces;
using backend.Infraestructure.Configuration;
using Microsoft.Extensions.Options;
using Stripe;

namespace backend.Infraestructure.API_Services
{
    public class StripeService : IStripeService
    {
        private readonly StripeOptions _options;

        public StripeService(IOptions<StripeOptions> options)
        {
            _options = options.Value;
        }

        public async Task<(string PaymentIntentId, string ClientSecret)> CreatePaymentIntentAsync(
            decimal amount, string currency, string description, CancellationToken ct)
        {
            var client  = new StripeClient(_options.SecretKey);
            var service = new PaymentIntentService(client);

            var createOptions = new PaymentIntentCreateOptions
            {
                // Stripe expects the amount in the smallest currency unit (centavos for MXN)
                Amount      = (long)(amount * 100),
                Currency    = currency.ToLowerInvariant(),
                Description = description,
                AutomaticPaymentMethods = new PaymentIntentAutomaticPaymentMethodsOptions
                {
                    Enabled = true
                }
            };

            var intent = await service.CreateAsync(createOptions, cancellationToken: ct);
            return (intent.Id, intent.ClientSecret);
        }

        public Event ConstructWebhookEvent(string json, string signature)
        {
            return EventUtility.ConstructEvent(json, signature, _options.WebhookSecret);
        }
    }
}
