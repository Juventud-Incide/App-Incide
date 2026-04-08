using backend.Data.Entities;
using backend.Infraestructure.API_Services_Interfaces;

namespace backend.Infraestructure.API_Services
{
    // TODO: reemplazar por envío real (SMTP/SendGrid) y leer destinatario RRHH
    // desde appsettings ("Hr:Email"). Por ahora solo se loggea para dejar el
    // hook listo en el flujo de subida de documentos.
    public class LoggingNotificationService : INotificationService
    {
        private readonly ILogger<LoggingNotificationService> _logger;

        public LoggingNotificationService(ILogger<LoggingNotificationService> logger)
        {
            _logger = logger;
        }

        public Task NotifyHrDocumentsReadyAsync(
            Provider provider,
            IEnumerable<Document> documents,
            CancellationToken ct)
        {
            var fullName = $"{provider.User.FirstName} {provider.User.LastName}";
            var docsSummary = string.Join(
                "; ",
                documents.Select(d => $"{d.DocumentType}={d.FileUrl}"));

            _logger.LogInformation(
                "[RRHH-NOTIF] Proveedor listo para revisión final. ProviderId={ProviderId}, Nombre={FullName}, Email={Email}, Documentos=[{Docs}]",
                provider.Id,
                fullName,
                provider.User.Email,
                docsSummary);

            return Task.CompletedTask;
        }
    }
}
