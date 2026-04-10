using System.ComponentModel.DataAnnotations;

namespace backend.Domain.DTOs
{
    public class RejectInterviewDTO
    {
        [Required(ErrorMessage = "El motivo del rechazo es obligatorio.")]
        [StringLength(500, MinimumLength = 5, ErrorMessage = "El motivo debe tener entre 5 y 500 caracteres.")]
        public string Reason { get; set; } = string.Empty;
    }
}
