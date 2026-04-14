using System.ComponentModel.DataAnnotations;

namespace backend.Domain.DTOs
{
    public class RejectAffiliationDTO
    {
        [Required]
        [MinLength(3)]
        [MaxLength(500)]
        public string Reason { get; set; } = string.Empty;
    }
}
