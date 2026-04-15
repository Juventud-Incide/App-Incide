namespace backend.Domain.OutPutDTOs.Cotizacion
{
    public class ServiceRequestOutputDTO
    {
        public int    Id              { get; set; }
        public int    ServiceItemId   { get; set; }
        public string ServiceItemName { get; set; } = string.Empty;
        public string CategoryName    { get; set; } = string.Empty;
        public int    ClientId        { get; set; }
        public string ClientName      { get; set; } = string.Empty;

        public string?   Description     { get; set; }
        public decimal?  EstimatedBudget { get; set; }
        public DateTime? PreferredDate   { get; set; }

        public decimal Lat { get; set; }
        public decimal Lng { get; set; }

        public string  Type             { get; set; } = string.Empty;
        public int?    TargetProviderId { get; set; }
        public string  Status           { get; set; } = string.Empty;
        public DateTime CreationDate    { get; set; }

        public List<CotizacionOutputDTO> Cotizaciones { get; set; } = [];
    }
}
