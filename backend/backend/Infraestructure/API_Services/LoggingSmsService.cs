using backend.Infraestructure.API_Services_Interfaces;

namespace backend.Infraestructure.API_Services
{
    // TODO: reemplazar por envío real vía Twilio/AWS SNS.
    // Mantener la interfaz ISmsService; solo intercambiar el registro en Program.cs.
    public class LoggingSmsService : ISmsService
    {
        private readonly ILogger<LoggingSmsService> _logger;

        public LoggingSmsService(ILogger<LoggingSmsService> logger)
        {
            _logger = logger;
        }

        public Task SendAsync(string toPhoneNumber, string message, CancellationToken ct = default)
        {
            _logger.LogInformation(
                "[SMS-STUB] Para: {Phone} | Mensaje: {Message}",
                toPhoneNumber, message);

            return Task.CompletedTask;
        }
    }
}
