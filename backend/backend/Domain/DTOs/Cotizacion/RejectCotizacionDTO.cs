using System.ComponentModel.DataAnnotations;

namespace backend.Domain.DTOs.Cotizacion
{
    public class RejectCotizacionDTO
    {
        [MaxLength(500)]
        public string? RejectReason { get; set; }
    }
}
