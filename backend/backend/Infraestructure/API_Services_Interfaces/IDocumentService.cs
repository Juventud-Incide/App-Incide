using backend.Domain.DTOs;
using backend.Domain.OutPutDTOs;

namespace backend.Infraestructure.API_Services_Interfaces
{
    public interface IDocumentService
    {
        Task<DocumentOutputDTO> UploadAsync(int userId, UploadDocumentDTO dto, CancellationToken ct);
    }
}
