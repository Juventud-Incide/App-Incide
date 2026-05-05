using backend.Domain.Enum;

namespace backend.Data.Entities
{
    public class Payment : Entity
    {
        public int        CotizacionId { get; set; }
        public Cotizacion Cotizacion   { get; set; } = null!;

        public int    ClientId { get; set; }
        public Client Client   { get; set; } = null!;

        public int      ProviderId { get; set; }
        public Provider Provider   { get; set; } = null!;

        public decimal Amount   { get; set; }
        public string  Currency { get; set; } = "MXN";

        public PaymentStatus Status { get; set; } = PaymentStatus.Pending;

        public string? StripePaymentIntentId { get; set; }
        public string? StripeClientSecret    { get; set; }
        public string? StripeChargeId        { get; set; }
        public string? StripeLastEventId     { get; set; }

        public DateTime? PaidAt        { get; set; }
        public DateTime? ReleasedAt    { get; set; }
        public string?   FailureReason { get; set; }
    }
}
