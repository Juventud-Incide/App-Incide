using backend.Domain.Enum;

namespace backend.Domain.DTOs
{
    public class ProviderDTO
    {
        public UserDTO User { get; set; }
        public ProviderStatus InterviewStatus { get; set; }
        public DateTime? InterviewDate { get; set; }

        //Mas Informacion requerida sobre el Proveedor
    }
}
