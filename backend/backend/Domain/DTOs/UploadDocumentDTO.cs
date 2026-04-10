using System.ComponentModel.DataAnnotations;
using backend.Domain.Enum;

namespace backend.Domain.DTOs
{
    public class UploadDocumentDTO
    {
        [Required]
        public DocumentType DocumentType { get; set; }

        [Required]
        public IFormFile File { get; set; } = null!;
    }
}
