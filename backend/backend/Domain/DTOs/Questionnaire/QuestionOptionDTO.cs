using System.ComponentModel.DataAnnotations;

namespace backend.Domain.DTOs.Questionnaire
{
    public class QuestionOptionDTO
    {
        [Required]
        [MaxLength(200)]
        public string Text { get; set; } = string.Empty;

        public int Order { get; set; }
    }
}
