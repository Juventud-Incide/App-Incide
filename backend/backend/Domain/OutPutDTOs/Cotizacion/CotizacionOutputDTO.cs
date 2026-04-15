namespace backend.Domain.OutPutDTOs.Cotizacion
{
    public class CotizacionOutputDTO
    {
        public int    Id               { get; set; }
        public int    ServiceRequestId { get; set; }
        public int    ProviderId       { get; set; }
        public string ProviderName     { get; set; } = string.Empty;

        public decimal   Amount        { get; set; }
        public string    Currency      { get; set; } = string.Empty;
        public string?   Description   { get; set; }
        public int?      EstimatedHours { get; set; }
        public DateTime? ProposedDate  { get; set; }

        public string    Status       { get; set; } = string.Empty;
        public DateTime? AcceptedAt   { get; set; }
        public DateTime? RejectedAt   { get; set; }
        public string?   RejectReason { get; set; }
        public DateTime  CreationDate { get; set; }
    }
}
