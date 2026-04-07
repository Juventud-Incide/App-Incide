using backend.Domain.Enum;

namespace backend.Data.Entities
{
    public class Provider : Entity
    {
        public int UserId { get; set; }
        public User User { get; set; }

        public ProviderStatus Status { get; set; } = ProviderStatus.Registered;
        public DateTime? InterviewDate { get; set; }
        public string? InterviewRejectionReason { get; set; }
    }
}
