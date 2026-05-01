namespace backend.Domain.OutPutDTOs.Cotizacion
{
    public class ChatRoomOutputDTO
    {
        public int      Id               { get; set; }
        public int      ServiceRequestId { get; set; }
        public int      ProviderId       { get; set; }
        public DateTime CreationDate     { get; set; }
    }
}
