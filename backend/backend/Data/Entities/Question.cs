using backend.Domain.Enum;

namespace backend.Data.Entities
{
    public class Question : Entity
    {
        public int CategoryId { get; set; }
        public Category Category { get; set; } = default!;

        public string Text { get; set; } = string.Empty;
        public QuestionType Type { get; set; }
        public bool IsRequired { get; set; } = true;
        public int Order { get; set; }

        public ICollection<QuestionOption> Options { get; set; } = [];
    }
}
