using backend.Data.Entities;
using backend.Infraestructure.API_Services_Interfaces;
using Microsoft.Extensions.Logging;

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

        public Task NotifyClientProviderInterestedAsync(Client client, ServiceRequest request, Provider provider, CancellationToken ct)
        {
            var clientName   = $"{client.User.FirstName} {client.User.LastName}";
            var providerName = $"{provider.User.FirstName} {provider.User.LastName}";

            _logger.LogInformation(
                "[COTIZACION-NOTIF] Proveedor interesado. ClientId={ClientId}, Nombre={ClientName}, SolicitudId={RequestId}, ProviderId={ProviderId}, Proveedor={ProviderName}. Mensaje: '{ProviderName} está interesado en tu solicitud.'",
                client.Id, clientName, request.Id, provider.Id, providerName, providerName);

            // TODO: reemplazar por push notification real (FCM/OneSignal)
            return Task.CompletedTask;
        }

        public Task NotifyClientRequestCancelledAsync(Client client, ServiceRequest request, CancellationToken ct)
        {
            var clientName = $"{client.User.FirstName} {client.User.LastName}";

            _logger.LogInformation(
                "[COTIZACION-NOTIF] Solicitud cancelada. ClientId={ClientId}, Nombre={ClientName}, SolicitudId={RequestId}. Mensaje: 'Tu solicitud #{RequestId} ha sido cancelada.'",
                client.Id, clientName, request.Id, request.Id);

            // TODO: reemplazar por push notification real (FCM/OneSignal)
            return Task.CompletedTask;
        }

        public Task NotifyNewChatMessageAsync(User recipient, ChatRoom room, ChatMessage message, CancellationToken ct)
        {
            var preview = message.Content.Length > 50
                ? string.Concat(message.Content.AsSpan(0, 50), "…")
                : message.Content;

            _logger.LogInformation(
                "[CHAT-NOTIF] Nuevo mensaje. RecipientId={RecipientId}, Email={Email}, RoomId={RoomId}, Preview=\"{Preview}\". TODO: reemplazar por FCM push notification.",
                recipient.Id, recipient.Email, room.Id, preview);

            // TODO: reemplazar por FCM push notification real
            return Task.CompletedTask;
        }

        public Task NotifyPaymentSucceededAsync(
            Payment payment, Client client, Provider provider, ServiceRequest serviceRequest, CancellationToken ct)
        {
            // TODO: reemplazar por envío real de correo (SendGrid / SMTP)
            var folio        = $"PAY-{payment.Id:D6}";
            var clientName   = $"{client.User.FirstName} {client.User.LastName}";
            var providerName = $"{provider.User.FirstName} {provider.User.LastName}";
            var monto        = $"{payment.Amount:N2} {payment.Currency}";
            var fecha        = (payment.PaidAt ?? DateTime.UtcNow).ToString("dd/MM/yyyy HH:mm") + " UTC";
            var servicio     = serviceRequest.ServiceItem?.Name ?? $"Solicitud #{serviceRequest.Id}";

            // ── Correo al CLIENTE ────────────────────────────────────────────
            _logger.LogInformation(
                "[PAYMENT-EMAIL → CLIENTE] Para: {ClientEmail}\n" +
                "Asunto: Pago confirmado - {Folio}\n" +
                "Cuerpo:\n" +
                "  Hola {ClientName},\n" +
                "  Tu pago ha sido procesado exitosamente.\n" +
                "  -----------------------------------\n" +
                "  Folio:    {Folio}\n" +
                "  Servicio: {Servicio}\n" +
                "  Monto:    {Monto}\n" +
                "  Fecha:    {Fecha}\n" +
                "  Proveedor: {ProviderName}\n" +
                "  -----------------------------------\n" +
                "  Gracias por usar INCIDE.",
                client.User.Email, folio, clientName,
                folio, servicio, monto, fecha, providerName);

            // ── Correo al PROVEEDOR ──────────────────────────────────────────
            _logger.LogInformation(
                "[PAYMENT-EMAIL → PROVEEDOR] Para: {ProviderEmail}\n" +
                "Asunto: Nuevo pago recibido - {Folio}\n" +
                "Cuerpo:\n" +
                "  Hola {ProviderName},\n" +
                "  Se ha confirmado un pago por tu servicio.\n" +
                "  -----------------------------------\n" +
                "  Folio:    {Folio}\n" +
                "  Servicio: {Servicio}\n" +
                "  Monto:    {Monto}\n" +
                "  Fecha:    {Fecha}\n" +
                "  Cliente:  {ClientName}\n" +
                "  -----------------------------------\n" +
                "  Los fondos serán liberados cuando el cliente confirme el trabajo.",
                provider.User.Email, folio, providerName,
                folio, servicio, monto, fecha, clientName);

            return Task.CompletedTask;
        }
    }
}
