using backend.Domain.Enum;
using NetTopologySuite.Geometries;

namespace backend.Data.Entities
{
    public class ServiceRequest : Entity
    {
        public int         ServiceItemId { get; set; }
        public ServiceItem ServiceItem   { get; set; } = null!;
        public int         ClientId      { get; set; }
        public Client      Client        { get; set; } = null!;

        // Request details
        public string?   Description       { get; set; }
        public decimal?  EstimatedBudget   { get; set; }
        public DateTime? PreferredDate     { get; set; }

        // Service location (snapshot at creation time)
        public decimal Lat      { get; set; }
        public decimal Lng      { get; set; }
        public Point   Location { get; set; } = null!;

        // Visibility and targeting
        public CotizacionType Type             { get; set; } = CotizacionType.Public;
        public int?           TargetProviderId { get; set; }
        public Provider?      TargetProvider   { get; set; }

        // Lifecycle status
        public CotizacionRequestStatus Status { get; set; } = CotizacionRequestStatus.Active;

        public ICollection<Cotizacion> Cotizaciones { get; set; } = [];
        public ICollection<ChatRoom>   ChatRooms    { get; set; } = [];
    }
}
