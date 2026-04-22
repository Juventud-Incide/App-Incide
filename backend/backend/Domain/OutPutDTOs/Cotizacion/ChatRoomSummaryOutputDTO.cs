namespace backend.Domain.OutPutDTOs.Cotizacion
{
    public class ChatRoomSummaryOutputDTO
    {
        public int       Id                 { get; set; }
        public int       ServiceRequestId   { get; set; }
        public string    ServiceName        { get; set; } = string.Empty;
        public int       ProviderId         { get; set; }
        public string    ProviderName       { get; set; } = string.Empty;
        public int       ClientId           { get; set; }
        public string    ClientName         { get; set; } = string.Empty;
        public string?   LastMessageContent { get; set; }
        public DateTime? LastMessageAt      { get; set; }
        public int       UnreadCount        { get; set; }
        public DateTime  CreationDate       { get; set; }
    }
}
