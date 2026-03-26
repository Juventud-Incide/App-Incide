using backend.Domain.DTOs;
using backend.Domain.OutPutDTOs;

namespace backend.Infraestructure.API_Services_Interfaces
{
    public class IAuthService
    {
        Task<AuthOutPutDTO> LoginAsync(LoginDTO dto);
    }
}
