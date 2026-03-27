using backend.Domain.DTOs;
using backend.Domain.OutPutDTOs;

namespace backend.Infraestructure.API_Services_Interfaces
{
    public interface IUserService
    {
        Task<UserOutPutDTO> CreateAsync(UserDTO dto);
        Task<UserOutPutDTO?> GetByIdAsync(int id);
        Task<List<UserOutPutDTO>> GetAllAsync();
        Task<UserOutPutDTO?> UpdateAsync(int id, UserDTO dto);
        Task<bool> DeleteAsync(int id);

    }
}
