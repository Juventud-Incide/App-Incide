using backend.Domain.DTOs;
using backend.Domain.OutPutDTOs;

namespace backend.Infraestructure.API_Services_Interfaces
{
    public interface ICategoryService
    {
        Task<List<CategoryOutputDTO>> GetAllAsync(CancellationToken ct);
        Task<CategoryOutputDTO?>      GetByIdAsync(int id, CancellationToken ct);
        Task<CategoryOutputDTO>       CreateAsync(CategoryDTO dto, CancellationToken ct);
        Task<CategoryOutputDTO?>      UpdateAsync(int id, CategoryDTO dto, CancellationToken ct);
        Task<bool>                    DeleteAsync(int id, CancellationToken ct);
    }
}
