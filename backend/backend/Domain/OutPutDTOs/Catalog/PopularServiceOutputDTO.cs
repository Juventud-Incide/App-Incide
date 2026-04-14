namespace backend.Domain.OutPutDTOs
{
    public class PopularServiceOutputDTO
    {
        public int    Id           { get; set; }
        public string Name         { get; set; } = string.Empty;
        public string Icon         { get; set; } = string.Empty;
        public int    CategoryId   { get; set; }
        public string CategoryName { get; set; } = string.Empty;
        public int    RequestCount { get; set; }
    }
}
