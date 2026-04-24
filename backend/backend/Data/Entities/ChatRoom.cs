namespace backend.Data.Entities
{
    public class ChatRoom : Entity
    {
        public int            ServiceRequestId { get; set; }
        public ServiceRequest ServiceRequest   { get; set; } = default!;

        public int      ProviderId { get; set; }
        public Provider Provider   { get; set; } = default!;
    }
}
