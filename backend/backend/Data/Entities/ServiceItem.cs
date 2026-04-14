namespace backend.Data.Entities
{
    public class ServiceItem : Entity
    {
        public string Name        { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string Icon        { get; set; } = string.Empty;
        public int    CategoryId  { get; set; }
        public Category Category  { get; set; } = null!;
        public ICollection<ServiceRequest> Requests { get; set; } = [];
    }
}
