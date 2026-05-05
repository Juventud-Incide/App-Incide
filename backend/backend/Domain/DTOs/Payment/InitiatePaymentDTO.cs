using System.ComponentModel.DataAnnotations;

namespace backend.Domain.DTOs.Payment
{
    public class InitiatePaymentDTO
    {
        [Required]
        [Range(1, int.MaxValue, ErrorMessage = "CotizacionId must be a positive integer.")]
        public int CotizacionId { get; set; }
    }
}
