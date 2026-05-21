namespace backend.Data.Entities
{
    public class ProviderServiceItem
    {
        public int         ProviderId    { get; set; }
        public Provider    Provider      { get; set; } = null!;
        public int         ServiceItemId { get; set; }
        public ServiceItem ServiceItem   { get; set; } = null!;
    }
}
