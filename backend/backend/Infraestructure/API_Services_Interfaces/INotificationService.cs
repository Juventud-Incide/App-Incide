using backend.Data.Entities;

namespace backend.Infraestructure.API_Services_Interfaces
{
    public interface INotificationService
    {
        Task NotifyHrDocumentsReadyAsync(
            Provider provider,
            IEnumerable<Document> documents,
            CancellationToken ct);
    }
}
