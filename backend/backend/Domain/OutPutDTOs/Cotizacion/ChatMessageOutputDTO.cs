namespace backend.Domain.OutPutDTOs.Cotizacion
{
    public class ChatMessageOutputDTO
    {
        public int      Id         { get; set; }
        public int      ChatRoomId { get; set; }
        public int      SenderId   { get; set; }
        public string   SenderName { get; set; } = string.Empty;
        public string   Content    { get; set; } = string.Empty;
        public bool     IsRead     { get; set; }
        public DateTime SentAt     { get; set; }
    }
}
