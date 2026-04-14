using System.ComponentModel.DataAnnotations;
using backend.Domain.Enum;

namespace backend.Domain.DTOs
{
    public class ProviderDTO
    {
        [Required(ErrorMessage = "Los datos del usuario son obligatorios.")]
        public UserDTO User { get; set; } = new();

        public ProviderStatus InterviewStatus { get; set; }

        public DateTime? InterviewDate { get; set; }

        //Mas Informacion requerida sobre el Proveedor
    }
}
