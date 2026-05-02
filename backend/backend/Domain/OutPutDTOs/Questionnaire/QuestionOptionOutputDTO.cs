namespace backend.Domain.OutPutDTOs.Questionnaire
{
    public class QuestionOptionOutputDTO
    {
        public int Id { get; set; }
        public string Text { get; set; } = string.Empty;
        public int Order { get; set; }
    }
}
