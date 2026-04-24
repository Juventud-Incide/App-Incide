using backend.Domain.DTOs.Questionnaire;
using backend.Domain.OutPutDTOs.Questionnaire;

namespace backend.Infraestructure.API_Services_Interfaces
{
    public interface IQuestionnaireService
    {
        Task<List<QuestionOutputDTO>> GetByCategoryAsync(int categoryId, CancellationToken ct);
        Task<QuestionOutputDTO>       CreateAsync(int categoryId, QuestionDTO dto, CancellationToken ct);
        Task<QuestionOutputDTO?>      UpdateAsync(int id, QuestionDTO dto, CancellationToken ct);
        Task<bool>                    DeleteAsync(int id, CancellationToken ct);
    }
}
