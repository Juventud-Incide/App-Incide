namespace backend.Domain.OutPutDTOs.Payment
{
    public class PaymentOutPutDTO
    {
        public int      Id           { get; set; }
        public string   Folio        { get; set; } = string.Empty;
        public int      CotizacionId { get; set; }
        public string   Status       { get; set; } = string.Empty;
        public decimal  Amount       { get; set; }
        public string   Currency     { get; set; } = string.Empty;
        public string   ProviderName { get; set; } = string.Empty;
        public string?  FailureReason { get; set; }
        public DateTime  CreationDate { get; set; }
        public DateTime? PaidAt       { get; set; }
        public DateTime? ReleasedAt   { get; set; }
    }
}
