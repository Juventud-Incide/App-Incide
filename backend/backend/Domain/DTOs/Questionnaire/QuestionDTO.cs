using backend.Domain.Enum;
using System.ComponentModel.DataAnnotations;

namespace backend.Domain.DTOs.Questionnaire
{
    public class QuestionDTO
    {
        [Required]
        [MaxLength(500)]
        public string Text { get; set; } = string.Empty;

        public QuestionType Type { get; set; }

        public bool IsRequired { get; set; } = true;

        public int Order { get; set; }

        public List<QuestionOptionDTO> Options { get; set; } = [];
    }
}
