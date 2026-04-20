using System.ComponentModel.DataAnnotations;

namespace backend.Domain.DTOs.Cotizacion
{
    public class SubmitCotizacionDTO
    {
        [Required]
        [Range(0.01, double.MaxValue, ErrorMessage = "Amount must be greater than 0.")]
        public decimal Amount { get; set; }

        [MaxLength(3)]
        public string Currency { get; set; } = "MXN";

        [MaxLength(1000)]
        public string? Description { get; set; }

        [Range(1, 9999)]
        public int? EstimatedHours { get; set; }

        public DateTime? ProposedDate { get; set; }
    }
}
