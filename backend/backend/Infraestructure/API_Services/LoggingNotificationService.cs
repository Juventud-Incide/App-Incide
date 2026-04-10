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

        public Task NotifyProviderAffiliationApprovedAsync(Provider provider, CancellationToken ct)
        {
            var fullName = $"{provider.User.FirstName} {provider.User.LastName}";

            _logger.LogInformation(
                "[PROVIDER-NOTIF] Afiliación APROBADA. ProviderId={ProviderId}, Nombre={FullName}, Email={Email}. Mensaje: 'Tu afiliación ha sido aprobada, ya puedes operar en la plataforma.'",
                provider.Id,
                fullName,
                provider.User.Email);

            return Task.CompletedTask;
        }

        public Task NotifyProviderAffiliationRejectedAsync(Provider provider, string reason, CancellationToken ct)
        {
            var fullName = $"{provider.User.FirstName} {provider.User.LastName}";

            _logger.LogInformation(
                "[PROVIDER-NOTIF] Afiliación RECHAZADA. ProviderId={ProviderId}, Nombre={FullName}, Email={Email}, Motivo={Reason}. Mensaje: 'Tu afiliación fue rechazada por el siguiente motivo: {Reason}'",
                provider.Id,
                fullName,
                provider.User.Email,
                reason,
                reason);

            return Task.CompletedTask;
        }
    }
}
