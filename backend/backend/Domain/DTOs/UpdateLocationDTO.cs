using System.ComponentModel.DataAnnotations;

namespace backend.Domain.DTOs
{
    public class UpdateLocationDTO
    {
        [Required]
        [Range(-90.0, 90.0)]
        public decimal Lat { get; set; }

        [Required]
        [Range(-180.0, 180.0)]
        public decimal Lng { get; set; }
    }
}
