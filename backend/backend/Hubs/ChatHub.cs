using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using backend.Infraestructure.API_Services_Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;

namespace backend.Hubs
{
    [Authorize]
    public class ChatHub : Hub
    {
        private readonly IChatService _chatService;

        public ChatHub(IChatService chatService)
        {
            _chatService = chatService;
        }

        // ── Helpers ───────────────────────────────────────────────────────────

        private int GetUserId() =>
            int.TryParse(Context.User?.FindFirstValue(JwtRegisteredClaimNames.Sub), out var id)
                ? id
                : throw new HubException("Unauthenticated.");

        private static string GroupName(int chatRoomId) => $"chat-room-{chatRoomId}";

        // ── Client-invocable methods ──────────────────────────────────────────

        /// <summary>
        /// Agrega la conexión actual al grupo SignalR de la sala.
        /// Lanza HubException si el usuario no pertenece a la sala.
        /// </summary>
        public async Task JoinRoom(int chatRoomId)
        {
            var userId = GetUserId();
            try
            {
                await _chatService.AuthorizeRoomAccessAsync(chatRoomId, userId, Context.ConnectionAborted);
                await Groups.AddToGroupAsync(Context.ConnectionId, GroupName(chatRoomId));
            }
            catch (KeyNotFoundException ex)    { throw new HubException(ex.Message); }
            catch (UnauthorizedAccessException) { throw new HubException("Access denied."); }
        }

        /// <summary>Saca la conexión del grupo. No requiere re-validar acceso.</summary>
        public async Task LeaveRoom(int chatRoomId)
        {
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, GroupName(chatRoomId));
        }

        /// <summary>
        /// Persiste el mensaje y hace broadcast a todos en el grupo (incluido el emisor).
        /// Valida acceso nuevamente para evitar que alguien en sala A envíe a sala B.
        /// </summary>
        public async Task SendMessage(int chatRoomId, string content)
        {
            if (string.IsNullOrWhiteSpace(content))
                throw new HubException("Message content cannot be empty.");

            if (content.Length > 2000)
                throw new HubException("Message exceeds maximum length of 2000 characters.");

            var userId = GetUserId();
            try
            {
                var message = await _chatService.SaveMessageAsync(
                    chatRoomId, userId, content.Trim(), Context.ConnectionAborted);

                await Clients.Group(GroupName(chatRoomId)).SendAsync("ReceiveMessage", message);
            }
            catch (KeyNotFoundException ex)    { throw new HubException(ex.Message); }
            catch (UnauthorizedAccessException) { throw new HubException("Access denied."); }
        }
    }
}
