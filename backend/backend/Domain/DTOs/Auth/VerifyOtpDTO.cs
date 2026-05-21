using System.ComponentModel.DataAnnotations;

namespace backend.Domain.DTOs
{
    public class VerifyOtpDTO
    {
        [Required(ErrorMessage = "El número de teléfono es obligatorio.")]
        [Phone(ErrorMessage = "Formato de teléfono inválido.")]
        [StringLength(20, MinimumLength = 10, ErrorMessage = "El teléfono debe tener entre 10 y 20 caracteres.")]
        public string PhoneNumber { get; set; } = string.Empty;

        [Required(ErrorMessage = "El código es obligatorio.")]
        [StringLength(6, MinimumLength = 6, ErrorMessage = "El código debe ser de exactamente 6 dígitos.")]
        [RegularExpression(@"^\d{6}$", ErrorMessage = "El código debe ser numérico de 6 dígitos.")]
        public string Code { get; set; } = string.Empty;
    }
}
