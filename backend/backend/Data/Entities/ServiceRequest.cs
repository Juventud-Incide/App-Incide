namespace backend.Data.Entities
{
    public class ServiceRequest : Entity
    {
        public int         ServiceItemId { get; set; }
        public ServiceItem ServiceItem   { get; set; } = null!;
        public int         ClientId      { get; set; }
        public Client      Client        { get; set; } = null!;
    }
}
