namespace backend.Data.Entities
{
    public class ProviderCategory
    {
        public int      ProviderId { get; set; }
        public Provider Provider   { get; set; } = null!;
        public int      CategoryId { get; set; }
        public Category Category   { get; set; } = null!;
    }
}
