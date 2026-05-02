namespace backend.Data.Entities
{
    public class ChatMessage : Entity
    {
        public int      ChatRoomId { get; set; }
        public ChatRoom ChatRoom   { get; set; } = default!;

        public int  SenderId { get; set; }
        public User Sender   { get; set; } = default!;

        public string Content { get; set; } = string.Empty;
        public bool   IsRead  { get; set; } = false;
    }
}
