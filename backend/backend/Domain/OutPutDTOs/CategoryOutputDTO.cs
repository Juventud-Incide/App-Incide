namespace backend.Domain.OutPutDTOs
{
    public class CategoryOutputDTO
    {
        public int    Id                  { get; set; }
        public string Name                { get; set; } = string.Empty;
        public string Icon                { get; set; } = string.Empty;
        public int    ActiveProviderCount { get; set; }
    }
}
