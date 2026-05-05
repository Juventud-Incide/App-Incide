using Stripe;

namespace backend.Infraestructure.API_Services_Interfaces
{
    public interface IStripeService
    {
        Task<(string PaymentIntentId, string ClientSecret)> CreatePaymentIntentAsync(
            decimal amount, string currency, string description, CancellationToken ct);

        Event ConstructWebhookEvent(string json, string signature);
    }
}
