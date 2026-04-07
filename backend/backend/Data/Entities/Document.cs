using backend.Domain.Enum;

namespace backend.Data.Entities
{
    public class Document : Entity
    {
        public int ProviderId { get; set; }
        public Provider Provider { get; set; }

        public DocumentType DocumentType { get; set; }
        public string FileUrl { get; set; } = string.Empty;
        public DocumentStatus DocumentStatus { get; set; }

        public string OriginalFileName { get; set; } = string.Empty;
        public string ContentType { get; set; } = string.Empty;
        public long SizeBytes { get; set; }
    }
}
