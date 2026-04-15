using backend.Domain.DTOs.Cotizacion;
using backend.Domain.OutPutDTOs.Cotizacion;

namespace backend.Infraestructure.API_Services_Interfaces
{
    public interface ICotizacionService
    {
        // ── Client ──────────────────────────────────────────────────────────
        Task<ServiceRequestOutputDTO> CreateServiceRequestAsync(int userId, CreateServiceRequestDTO dto, CancellationToken ct);
        Task<List<ServiceRequestOutputDTO>> GetMyRequestsAsync(int userId, CancellationToken ct);
        Task<ServiceRequestOutputDTO?> GetRequestByIdAsync(int requestId, int userId, CancellationToken ct);
        Task<CotizacionOutputDTO> AcceptCotizacionAsync(int cotizacionId, int userId, CancellationToken ct);
        Task<CotizacionOutputDTO> RejectCotizacionAsync(int cotizacionId, int userId, RejectCotizacionDTO dto, CancellationToken ct);

        // ── Provider ─────────────────────────────────────────────────────────
        Task<List<ServiceRequestMapOutputDTO>> GetMapAsync(int userId, CotizacionesMapQueryDTO query, CancellationToken ct);
        Task<CotizacionOutputDTO> SubmitCotizacionAsync(int requestId, int userId, SubmitCotizacionDTO dto, CancellationToken ct);
        Task<List<CotizacionOutputDTO>> GetMyCotizacionesAsync(int userId, CancellationToken ct);
        Task<bool> WithdrawCotizacionAsync(int cotizacionId, int userId, CancellationToken ct);
    }
}
