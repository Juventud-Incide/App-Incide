namespace backend.Data.Entities
{
    public class Category : Entity
    {
        public string Name { get; set; } = string.Empty;
        public string Icon { get; set; } = string.Empty;
        public ICollection<ProviderCategory> Providers  { get; set; } = [];
        public ICollection<ServiceItem>      Services   { get; set; } = [];
        public ICollection<Question>         Questions  { get; set; } = [];
    }
}
