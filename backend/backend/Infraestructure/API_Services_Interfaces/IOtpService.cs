namespace backend.Infraestructure.API_Services_Interfaces
{
    public interface IOtpService
    {
        Task SendOtpAsync(string phoneNumber, CancellationToken ct = default);

        /// <returns>true si el código es válido; false si es incorrecto, expirado o superó los intentos.</returns>
        Task<bool> VerifyOtpAsync(string phoneNumber, string code, CancellationToken ct = default);

        /// <summary>
        /// Verifica que exista un OTP verificado y no consumido para el teléfono,
        /// y lo marca como consumido de forma atómica. Llamado durante el registro.
        /// </summary>
        Task<bool> ConsumeVerifiedOtpAsync(string phoneNumber, CancellationToken ct = default);
    }
}
