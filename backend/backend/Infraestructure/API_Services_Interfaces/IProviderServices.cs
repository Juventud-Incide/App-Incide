using backend.Domain.DTOs;
using backend.Domain.OutPutDTOs;

namespace backend.Infraestructure.API_Services_Interfaces
{
    public interface IProviderServices
    {
        Task<ProviderOutPutDTO?> ScheduleInterviewAsync(int id, ScheduleInterviewDTO dto);
        Task<ProviderOutPutDTO?> ApproveInterviewAsync(int id);
        Task<ProviderOutPutDTO?> RejectInterviewAsync(int id, RejectInterviewDTO dto);
    }
}
