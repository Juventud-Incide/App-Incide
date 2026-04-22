using backend.Data.DataDB;
using backend.Data.Entities;
using backend.Domain.OutPutDTOs.Cotizacion;
using backend.Infraestructure.API_Services_Interfaces;
using Microsoft.EntityFrameworkCore;

namespace backend.Infraestructure.API_Services
{
    public class ChatService : IChatService
    {
        private readonly AppDbContext         _context;
        private readonly INotificationService _notifications;

        public ChatService(AppDbContext context, INotificationService notifications)
        {
            _context       = context;
            _notifications = notifications;
        }

        // ── Mappers ───────────────────────────────────────────────────────────

        private static ChatMessageOutputDTO ToMessageDTO(ChatMessage m, User sender) => new()
        {
            Id         = m.Id,
            ChatRoomId = m.ChatRoomId,
            SenderId   = m.SenderId,
            SenderName = $"{sender.FirstName} {sender.LastName}",
            Content    = m.Content,
            IsRead     = m.IsRead,
            SentAt     = m.CreationDate
        };

        // ── Private helpers ───────────────────────────────────────────────────

        // Loads room with all navigations needed for auth + notifications.
        // Throws KeyNotFoundException if room doesn't exist, UnauthorizedAccessException if
        // userId is not the client of the linked ServiceRequest nor the Provider of the room.
        private async Task<ChatRoom> GetAuthorizedRoomAsync(int chatRoomId, int userId, CancellationToken ct)
        {
            var room = await _context.ChatRooms
                .Include(cr => cr.ServiceRequest).ThenInclude(sr => sr.Client).ThenInclude(c => c.User)
                .Include(cr => cr.Provider).ThenInclude(p => p.User)
                .FirstOrDefaultAsync(cr => cr.Id == chatRoomId && !cr.IsDeleted, ct)
                ?? throw new KeyNotFoundException($"Chat room {chatRoomId} not found.");

            if (room.ServiceRequest.Client.UserId != userId && room.Provider.UserId != userId)
                throw new UnauthorizedAccessException("You are not a participant of this chat room.");

            return room;
        }

        // ── Public methods ────────────────────────────────────────────────────

        public async Task AuthorizeRoomAccessAsync(int chatRoomId, int userId, CancellationToken ct)
            => await GetAuthorizedRoomAsync(chatRoomId, userId, ct);

        public async Task<ChatMessageOutputDTO> SaveMessageAsync(
            int chatRoomId, int senderUserId, string content, CancellationToken ct)
        {
            var room       = await GetAuthorizedRoomAsync(chatRoomId, senderUserId, ct);
            var isClient   = room.ServiceRequest.Client.UserId == senderUserId;
            var senderUser = isClient ? room.ServiceRequest.Client.User : room.Provider.User;
            var recipient  = isClient ? room.Provider.User : room.ServiceRequest.Client.User;

            var message = new ChatMessage
            {
                ChatRoomId   = chatRoomId,
                SenderId     = senderUserId,
                Content      = content,
                IsRead       = false,
                IsActive     = true,
                CreationDate = DateTime.UtcNow,
                LastUpdate   = DateTime.UtcNow
            };

            _context.ChatMessages.Add(message);
            room.LastUpdate = DateTime.UtcNow;
            await _context.SaveChangesAsync(ct);

            await _notifications.NotifyNewChatMessageAsync(recipient, room, message, ct);

            return ToMessageDTO(message, senderUser);
        }

        public async Task<List<ChatMessageOutputDTO>> GetHistoryAsync(
            int chatRoomId, int userId, int limit, CancellationToken ct)
        {
            await GetAuthorizedRoomAsync(chatRoomId, userId, ct);

            // Fetch last N ordered newest-first, then flip to chronological for the client
            var messages = await _context.ChatMessages
                .Include(m => m.Sender)
                .Where(m => m.ChatRoomId == chatRoomId && !m.IsDeleted)
                .OrderByDescending(m => m.CreationDate)
                .Take(limit)
                .ToListAsync(ct);

            return [.. messages.OrderBy(m => m.CreationDate)
                               .Select(m => ToMessageDTO(m, m.Sender))];
        }

        public async Task<List<ChatRoomSummaryOutputDTO>> GetMyRoomsAsync(int userId, CancellationToken ct)
        {
            var client = await _context.Clients
                .FirstOrDefaultAsync(c => c.UserId == userId, ct);

            var provider = client == null
                ? await _context.Providers.FirstOrDefaultAsync(p => p.UserId == userId, ct)
                : null;

            if (client == null && provider == null)
                throw new InvalidOperationException("No client or provider profile found for this user.");

            var query = _context.ChatRooms
                .Include(cr => cr.ServiceRequest).ThenInclude(sr => sr.ServiceItem)
                .Include(cr => cr.ServiceRequest).ThenInclude(sr => sr.Client).ThenInclude(c => c.User)
                .Include(cr => cr.Provider).ThenInclude(p => p.User)
                .Where(cr => !cr.IsDeleted);

            query = client != null
                ? query.Where(cr => cr.ServiceRequest.ClientId == client.Id)
                : query.Where(cr => cr.ProviderId == provider!.Id);

            var rooms = await query
                .OrderByDescending(cr => cr.LastUpdate)
                .ToListAsync(ct);

            if (rooms.Count == 0)
                return [];

            var roomIds = rooms.Select(r => r.Id).ToList();

            // One query for last message + unread count; group in memory
            var allMessages = await _context.ChatMessages
                .Where(m => roomIds.Contains(m.ChatRoomId) && !m.IsDeleted)
                .OrderByDescending(m => m.CreationDate)
                .ToListAsync(ct);

            var lastMsgByRoom = allMessages
                .GroupBy(m => m.ChatRoomId)
                .ToDictionary(g => g.Key, g => g.First());

            var unreadByRoom = allMessages
                .Where(m => !m.IsRead && m.SenderId != userId)
                .GroupBy(m => m.ChatRoomId)
                .ToDictionary(g => g.Key, g => g.Count());

            return rooms.Select(cr =>
            {
                lastMsgByRoom.TryGetValue(cr.Id, out var lastMsg);
                unreadByRoom.TryGetValue(cr.Id, out var unread);
                return new ChatRoomSummaryOutputDTO
                {
                    Id                 = cr.Id,
                    ServiceRequestId   = cr.ServiceRequestId,
                    ServiceName        = cr.ServiceRequest.ServiceItem.Name,
                    ProviderId         = cr.ProviderId,
                    ProviderName       = $"{cr.Provider.User.FirstName} {cr.Provider.User.LastName}",
                    ClientId           = cr.ServiceRequest.ClientId,
                    ClientName         = $"{cr.ServiceRequest.Client.User.FirstName} {cr.ServiceRequest.Client.User.LastName}",
                    LastMessageContent = lastMsg?.Content,
                    LastMessageAt      = lastMsg?.CreationDate,
                    UnreadCount        = unread,
                    CreationDate       = cr.CreationDate
                };
            }).ToList();
        }
    }
}
