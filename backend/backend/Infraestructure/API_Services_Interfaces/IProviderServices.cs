using backend.Domain.DTOs;
using backend.Domain.OutPutDTOs;

namespace backend.Infraestructure.API_Services_Interfaces
{
    public interface IProviderServices
    {
        Task<ProviderOutPutDTO?> ScheduleInterviewAsync(int id, ScheduleInterviewDTO dto);
        Task<ProviderOutPutDTO?> ApproveInterviewAsync(int id);
        Task<ProviderOutPutDTO?> RejectInterviewAsync(int id, RejectInterviewDTO dto);

        Task<List<ProviderReviewOutputDTO>> GetPendingAffiliationsAsync(CancellationToken ct);
        Task<ProviderOutPutDTO?> ApproveAffiliationAsync(int id, CancellationToken ct);
        Task<ProviderOutPutDTO?> RejectAffiliationAsync(int id, RejectAffiliationDTO dto, CancellationToken ct);

        Task<List<ProviderCategoryOutputDTO>> GetCategoriesAsync(int providerId, CancellationToken ct);
        Task<ProviderCategoryOutputDTO>       AssignCategoryAsync(int providerId, int categoryId, CancellationToken ct);
        Task<bool>                            RemoveCategoryAsync(int providerId, int categoryId, CancellationToken ct);
    }
}
