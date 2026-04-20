using backend.Domain.Enum;

namespace backend.Data.Entities
{
    public class Cotizacion : Entity
    {
        public int            ServiceRequestId { get; set; }
        public ServiceRequest ServiceRequest   { get; set; } = null!;

        public int      ProviderId { get; set; }
        public Provider Provider   { get; set; } = null!;

        public decimal   Amount               { get; set; }
        public string    Currency             { get; set; } = "MXN";
        public string?   Description          { get; set; }
        public int?      EstimatedHours       { get; set; }
        public DateTime? ProposedDate         { get; set; }

        public CotizacionStatus Status       { get; set; } = CotizacionStatus.Submitted;
        public DateTime?        AcceptedAt   { get; set; }
        public DateTime?        RejectedAt   { get; set; }
        public string?          RejectReason { get; set; }
    }
}
