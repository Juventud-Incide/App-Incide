using backend.Domain.DTOs;
using backend.Domain.OutPutDTOs;

namespace backend.Infraestructure.API_Services_Interfaces
{
    public interface ICatalogService
    {
        Task<List<CategoryOutputDTO>>       GetCategoriesAsync(CancellationToken ct);
        Task<List<PopularServiceOutputDTO>> GetPopularAsync(CancellationToken ct);

        Task<List<ServiceItemOutputDTO>> GetAllServicesAsync(CancellationToken ct);
        Task<ServiceItemOutputDTO?>      GetServiceByIdAsync(int id, CancellationToken ct);
        Task<ServiceItemOutputDTO>       CreateServiceAsync(ServiceItemDTO dto, CancellationToken ct);
        Task<ServiceItemOutputDTO?>      UpdateServiceAsync(int id, ServiceItemDTO dto, CancellationToken ct);
        Task<bool>                       DeleteServiceAsync(int id, CancellationToken ct);
        Task<ServiceRequestOutputDTO> RequestServiceAsync(int serviceItemId, int userId, CancellationToken ct);
    }
}
