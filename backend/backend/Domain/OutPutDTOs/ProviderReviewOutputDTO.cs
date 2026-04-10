namespace backend.Domain.OutPutDTOs
{
    public class ProviderReviewOutputDTO
    {
        public int Id { get; set; }
        public string FullName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string PhoneNumber { get; set; } = string.Empty;
        public string Status { get; set; } = string.Empty;
        public DateTime? InterviewDate { get; set; }
        public List<DocumentOutputDTO> Documents { get; set; } = new();
    }
}
