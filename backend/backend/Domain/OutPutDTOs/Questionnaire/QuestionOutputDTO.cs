namespace backend.Domain.OutPutDTOs.Questionnaire
{
    public class QuestionOutputDTO
    {
        public int Id { get; set; }
        public int CategoryId { get; set; }
        public string Text { get; set; } = string.Empty;
        public string Type { get; set; } = string.Empty;
        public bool IsRequired { get; set; }
        public int Order { get; set; }
        public List<QuestionOptionOutputDTO> Options { get; set; } = [];
    }
}
