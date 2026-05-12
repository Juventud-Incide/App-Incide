using backend.Domain.Enum;

namespace backend.Data.Entities
{
    public class Provider : Entity
    {
        public int  UserId { get; set; }
        public User User   { get; set; } = null!;

        public ProviderStatus Status                    { get; set; } = ProviderStatus.Registered;
        public DateTime?      InterviewDate             { get; set; }
        public string?        InterviewRejectionReason  { get; set; }
        public string?        AffiliationRejectionReason { get; set; }

        public bool      Available          { get; set; } = false;
        public DateTime? AvailableUpdatedAt { get; set; }

        public string? Curp               { get; set; }
        public string? Rfc                { get; set; }
        public int?    YearsOfExperience  { get; set; }
        public string? ProfessionalLicense { get; set; }
        public string? Description        { get; set; }

        public ICollection<ProviderCategory>   Categories   { get; set; } = [];
        public ICollection<ProviderServiceItem> ServiceItems { get; set; } = [];
        public ICollection<Cotizacion>         Cotizaciones { get; set; } = [];
    }
}
