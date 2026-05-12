using System.ComponentModel.DataAnnotations;

namespace backend.Domain.DTOs
{
    public class SendOtpDTO
    {
        [Required(ErrorMessage = "El número de teléfono es obligatorio.")]
        [Phone(ErrorMessage = "Formato de teléfono inválido.")]
        [StringLength(20, MinimumLength = 10, ErrorMessage = "El teléfono debe tener entre 10 y 20 caracteres.")]
        public string PhoneNumber { get; set; } = string.Empty;
    }
}
