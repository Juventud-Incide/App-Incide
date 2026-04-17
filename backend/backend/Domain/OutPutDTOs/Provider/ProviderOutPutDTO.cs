namespace backend.Domain.OutPutDTOs
{
    public class ProviderOutPutDTO
    {
        public int Id { get; set; }
        public string FullName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public string UserRole { get; set; } = string.Empty;
        public string Status { get; set; } = string.Empty;
        public DateTime? InterviewDate { get; set; }
        public string Token { get; set; } = string.Empty;
    }
}
