using backend.Domain.DTOs;
using backend.Domain.OutPutDTOs;

namespace backend.Infraestructure.API_Services_Interfaces
{
    public interface IProviderServices
    {
        Task<ProviderOutPutDTO?> ScheduleInterviewAsync(int id, ScheduleInterviewDTO dto);
    }
}
