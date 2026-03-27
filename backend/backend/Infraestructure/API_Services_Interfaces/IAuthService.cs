using backend.Domain.DTOs;
using backend.Domain.OutPutDTOs;

namespace backend.Infraestructure.API_Services_Interfaces
{
    public interface IAuthService
    {
        Task<AuthOutPutDTO> RegisterAsync(RegisterDTO dto);
        Task<AuthOutPutDTO?> LoginAsync(LoginDTO dto);
    }
}