namespace backend.Data.Entities
{
    public class QuestionOption : Entity
    {
        public int QuestionId { get; set; }
        public Question Question { get; set; } = default!;

        public string Text { get; set; } = string.Empty;
        public int Order { get; set; }
    }
}
