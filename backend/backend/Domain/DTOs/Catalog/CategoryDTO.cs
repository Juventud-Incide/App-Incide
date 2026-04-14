using System.ComponentModel.DataAnnotations;

namespace backend.Domain.DTOs
{
    public class CategoryDTO
    {
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        [Required]
        [MaxLength(255)]
        public string Icon { get; set; } = string.Empty;
    }
}
