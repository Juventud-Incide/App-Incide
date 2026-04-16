namespace backend.Domain.OutPutDTOs
{
    public class ServiceItemOutputDTO
    {
        public int    Id           { get; set; }
        public string Name         { get; set; } = string.Empty;
        public string Description  { get; set; } = string.Empty;
        public string Icon         { get; set; } = string.Empty;
        public int    CategoryId   { get; set; }
        public string CategoryName { get; set; } = string.Empty;
        public bool   IsActive     { get; set; }
    }
}
