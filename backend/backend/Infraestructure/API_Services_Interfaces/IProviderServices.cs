using backend.Domain.DTOs;
using backend.Domain.OutPutDTOs;

namespace backend.Infraestructure.API_Services_Interfaces
{
    public interface IProviderServices
    {
        Task<ProviderOutPutDTO> CreateAsync(ProviderDTO dto);
        Task<ProviderOutPutDTO?> GetByIdAsync(int id);
        Task<List<ProviderOutPutDTO>> GetAllAsync();
        Task<ProviderOutPutDTO?> UpdateAsync(int id, ProviderDTO dto);
        Task<bool> DeleteAsync(int id);
    }
}
