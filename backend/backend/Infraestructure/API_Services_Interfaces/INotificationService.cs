using backend.Data.Entities;

namespace backend.Infraestructure.API_Services_Interfaces
{
    public interface INotificationService
    {
        Task NotifyHrDocumentsReadyAsync(
            Provider provider,
            IEnumerable<Document> documents,
            CancellationToken ct);

        Task NotifyProviderAffiliationApprovedAsync(Provider provider, CancellationToken ct);

        Task NotifyProviderAffiliationRejectedAsync(Provider provider, string reason, CancellationToken ct);

        Task NotifyClientProviderInterestedAsync(Client client, ServiceRequest request, Provider provider, CancellationToken ct);
        Task NotifyClientRequestCancelledAsync(Client client, ServiceRequest request, CancellationToken ct);

        // TODO: reemplazar por FCM push notification real
        Task NotifyNewChatMessageAsync(User recipient, ChatRoom room, ChatMessage message, CancellationToken ct);

        // TODO: reemplazar por envío real de correo (SendGrid / SMTP)
        Task NotifyPaymentSucceededAsync(Payment payment, Client client, Provider provider, ServiceRequest serviceRequest, CancellationToken ct);
    }
}
