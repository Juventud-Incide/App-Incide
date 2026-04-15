using System.ComponentModel.DataAnnotations;

namespace backend.Domain.DTOs.Cotizacion
{
    public class CotizacionesMapQueryDTO
    {
        [Required]
        [Range(-90.0, 90.0)]
        public decimal Lat { get; set; }

        [Required]
        [Range(-180.0, 180.0)]
        public decimal Lng { get; set; }

        [Range(1, 100)]
        public double MaxDistanceKm { get; set; } = 15;

        // Optional filter by category
        public int? CategoryId { get; set; }
    }
}
