using System.ComponentModel.DataAnnotations;

namespace backend.Domain.DTOs
{
    public class ServiceItemDTO
    {
        [Required]
        [MaxLength(150)]
        public string Name { get; set; } = string.Empty;

        [MaxLength(500)]
        public string Description { get; set; } = string.Empty;

        [MaxLength(255)]
        public string Icon { get; set; } = string.Empty;

        [Required]
        public int CategoryId { get; set; }
    }
}
