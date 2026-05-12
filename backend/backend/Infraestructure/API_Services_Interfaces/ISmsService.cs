namespace backend.Infraestructure.API_Services_Interfaces
{
    public interface ISmsService
    {
        // TODO: reemplazar LoggingSmsService por implementación real (Twilio/AWS SNS).
        // Solo cambiar el binding en Program.cs, esta interfaz no cambia.
        Task SendAsync(string toPhoneNumber, string message, CancellationToken ct = default);
    }
}
