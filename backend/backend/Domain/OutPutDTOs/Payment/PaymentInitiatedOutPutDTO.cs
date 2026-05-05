namespace backend.Domain.OutPutDTOs.Payment
{
    public class PaymentInitiatedOutPutDTO
    {
        public int     Id             { get; set; }
        public string  Folio          { get; set; } = string.Empty;
        public string  ClientSecret   { get; set; } = string.Empty;
        public string  PublishableKey { get; set; } = string.Empty;
        public decimal Amount         { get; set; }
        public string  Currency       { get; set; } = string.Empty;
    }
}
