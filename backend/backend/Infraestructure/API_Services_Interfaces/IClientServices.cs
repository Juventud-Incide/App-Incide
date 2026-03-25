using backend.Domain.DTOs;
using backend.Domain.OutPutDTOs;

namespace backend.Infraestructure.API_Services_Interfaces
{
    public interface IClientServices
    {

        Task<ClientOutPutDTO> CreateAsync(ClientDTO dto);
        Task<ClientOutPutDTO?> GetByIdAsync(int id);
        Task<List<ClientOutPutDTO>> GetAllAsync();
        Task<ClientOutPutDTO?> UpdateAsync(int id, ClientDTO dto);
        Task<bool> DeleteAsync(int id);
    }
}
