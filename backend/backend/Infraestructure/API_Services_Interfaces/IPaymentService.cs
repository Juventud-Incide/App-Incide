using backend.Domain.DTOs.Payment;
using backend.Domain.OutPutDTOs.Payment;

namespace backend.Infraestructure.API_Services_Interfaces
{
    public interface IPaymentService
    {
        Task<PaymentInitiatedOutPutDTO> InitiateAsync(int userId, InitiatePaymentDTO dto, CancellationToken ct);
        Task HandleWebhookAsync(string payload, string stripeSignature, CancellationToken ct);
        Task<List<PaymentOutPutDTO>> GetMyPaymentsAsync(int userId, CancellationToken ct);
        Task<PaymentOutPutDTO?> GetByIdAsync(int paymentId, int userId, CancellationToken ct);
        Task<PaymentOutPutDTO> ReleaseAsync(int paymentId, int userId, CancellationToken ct);
    }
}
