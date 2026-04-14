namespace backend.Domain.OutPutDTOs
{
    public class ProviderCategoryOutputDTO
    {
        public int    CategoryId   { get; set; }
        public string CategoryName { get; set; } = string.Empty;
        public string CategoryIcon { get; set; } = string.Empty;
    }
}
