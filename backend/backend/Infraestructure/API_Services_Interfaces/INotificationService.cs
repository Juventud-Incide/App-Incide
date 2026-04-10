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
    }
}
