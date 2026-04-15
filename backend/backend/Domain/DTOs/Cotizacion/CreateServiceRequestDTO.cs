using System.ComponentModel.DataAnnotations;
using backend.Domain.Enum;

namespace backend.Domain.DTOs.Cotizacion
{
    public class CreateServiceRequestDTO
    {
        [Required]
        public int ServiceItemId { get; set; }

        [MaxLength(1000)]
        public string? Description { get; set; }

        [Range(0, double.MaxValue)]
        public decimal? EstimatedBudget { get; set; }

        public DateTime? PreferredDate { get; set; }

        [Required]
        [Range(-90.0, 90.0)]
        public decimal Lat { get; set; }

        [Required]
        [Range(-180.0, 180.0)]
        public decimal Lng { get; set; }

        public CotizacionType Type { get; set; } = CotizacionType.Public;

        // Required only when Type = Targeted
        public int? TargetProviderId { get; set; }
    }
}
