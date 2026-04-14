namespace backend.Domain.OutPutDTOs
{
    public class ServiceRequestOutputDTO
    {
        public int      Id              { get; set; }
        public int      ServiceItemId   { get; set; }
        public string   ServiceItemName { get; set; } = string.Empty;
        public int      ClientId        { get; set; }
        public DateTime CreationDate    { get; set; }
    }
}
