using System.ComponentModel.DataAnnotations;

namespace backend.Domain.DTOs
{
    public class ClientDTO
    {
        [Required(ErrorMessage = "Los datos del usuario son obligatorios.")]
        public UserDTO User { get; set; } = new();

        //Mas informacion requerida de Clientes
    }
}
