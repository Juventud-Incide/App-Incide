using System.ComponentModel.DataAnnotations;

namespace backend.Domain.DTOs.Provider
{
    public class AvailabilityDTO
    {
        [Required]
        public bool Available { get; set; }
    }
}
