namespace backend.Domain.OutPutDTOs
{
    public class DocumentOutputDTO
    {
        public int Id { get; set; }
        public int ProviderId { get; set; }
        public string DocumentType { get; set; } = string.Empty;
        public string DocumentStatus { get; set; } = string.Empty;
        public string FileUrl { get; set; } = string.Empty;
        public string OriginalFileName { get; set; } = string.Empty;
        public long SizeBytes { get; set; }
        public DateTime CreationDate { get; set; }
    }
}
