using backend.Domain.OutPutDTOs.Cotizacion;

namespace backend.Infraestructure.API_Services_Interfaces
{
    public interface IChatService
    {
        Task AuthorizeRoomAccessAsync(int chatRoomId, int userId, CancellationToken ct);
        Task<ChatMessageOutputDTO> SaveMessageAsync(int chatRoomId, int senderUserId, string content, CancellationToken ct);
        Task<List<ChatMessageOutputDTO>> GetHistoryAsync(int chatRoomId, int userId, int limit, CancellationToken ct);
        Task<List<ChatRoomSummaryOutputDTO>> GetMyRoomsAsync(int userId, CancellationToken ct);
    }
}
