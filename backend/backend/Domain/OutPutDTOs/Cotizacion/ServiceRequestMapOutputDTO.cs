namespace backend.Domain.OutPutDTOs.Cotizacion
{
    public class ServiceRequestMapOutputDTO
    {
        public int    Id              { get; set; }
        public int    ServiceItemId   { get; set; }
        public string ServiceItemName { get; set; } = string.Empty;
        public string CategoryName    { get; set; } = string.Empty;

        public string?   Description     { get; set; }
        public decimal?  EstimatedBudget { get; set; }
        public DateTime? PreferredDate   { get; set; }

        public decimal Lat        { get; set; }
        public decimal Lng        { get; set; }
        public decimal DistanceKm { get; set; }

        public string   Type        { get; set; } = string.Empty;
        public DateTime CreationDate { get; set; }
    }
}
