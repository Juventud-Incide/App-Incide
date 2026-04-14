using backend.Domain.OutPutDTOs;

namespace backend.Infraestructure.API_Services_Interfaces
{
    public interface ICatalogService
    {
        Task<List<CategoryOutputDTO>>       GetCategoriesAsync(CancellationToken ct);
        Task<List<PopularServiceOutputDTO>> GetPopularAsync(CancellationToken ct);
    }
}
