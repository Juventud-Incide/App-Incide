using backend.Data.DataDB;
using backend.Data.Entities;
using backend.Domain.DTOs;
using backend.Domain.Enum;
using backend.Domain.OutPutDTOs;
using backend.Infraestructure.API_Services_Interfaces;
using Microsoft.EntityFrameworkCore;

namespace backend.Infraestructure.API_Services
{
    public class DocumentService : IDocumentService
    {
        private const long MaxFileSizeBytes = 5 * 1024 * 1024;

        private static readonly HashSet<string> AllowedExtensions = new(StringComparer.OrdinalIgnoreCase)
        {
            ".pdf", ".jpg", ".jpeg", ".png"
        };

        private static readonly HashSet<string> AllowedContentTypes = new(StringComparer.OrdinalIgnoreCase)
        {
            "application/pdf", "image/jpeg", "image/jpg", "image/png"
        };

        private readonly AppDbContext _context;
        private readonly IFileStorageService _storage;
        private readonly INotificationService _notifications;

        public DocumentService(
            AppDbContext context,
            IFileStorageService storage,
            INotificationService notifications)
        {
            _context = context;
            _storage = storage;
            _notifications = notifications;
        }

        public async Task<DocumentOutputDTO> UploadAsync(int userId, UploadDocumentDTO dto, CancellationToken ct)
        {
            var provider = await _context.Providers
                .Include(p => p.User)
                .FirstOrDefaultAsync(p => p.UserId == userId, ct);

            if (provider == null)
                throw new KeyNotFoundException("Proveedor no encontrado.");

            if (provider.Status != ProviderStatus.InterviewApproved)
                throw new InvalidOperationException(
                    $"No se pueden subir documentos: el proveedor está en estado '{provider.Status}'. Solo se permite desde 'InterviewApproved'.");

            if (dto.DocumentType == DocumentType.None)
                throw new InvalidOperationException("Debe especificar un tipo de documento válido.");

            ValidateFile(dto.File);

            var existing = await _context.Documents
                .FirstOrDefaultAsync(d =>
                    d.ProviderId == provider.Id &&
                    d.DocumentType == dto.DocumentType &&
                    !d.IsDeleted, ct);

            if (existing != null)
            {
                existing.IsDeleted = true;
                existing.IsActive = false;
                existing.LastUpdate = DateTime.UtcNow;
                await _storage.DeleteAsync(existing.FileUrl, ct);
            }

            var relativePath = await _storage.SaveAsync(
                dto.File,
                $"uploads/providers/{provider.Id}",
                ct);

            var document = new Document
            {
                ProviderId = provider.Id,
                DocumentType = dto.DocumentType,
                FileUrl = relativePath,
                DocumentStatus = DocumentStatus.Pending,
                OriginalFileName = Path.GetFileName(dto.File.FileName),
                ContentType = dto.File.ContentType ?? string.Empty,
                SizeBytes = dto.File.Length,
                CreationDate = DateTime.UtcNow,
                LastUpdate = DateTime.UtcNow,
                IsActive = true,
                IsDeleted = false
            };

            _context.Documents.Add(document);
            await _context.SaveChangesAsync(ct);

            await CheckCompletionAndNotifyAsync(provider, ct);

            return ToOutputDTO(document);
        }

        private static void ValidateFile(IFormFile file)
        {
            if (file == null || file.Length == 0)
                throw new InvalidOperationException("El archivo está vacío.");

            if (file.Length > MaxFileSizeBytes)
                throw new InvalidOperationException("El archivo excede el tamaño máximo permitido (5 MB).");

            var extension = Path.GetExtension(file.FileName);
            if (string.IsNullOrWhiteSpace(extension) || !AllowedExtensions.Contains(extension))
                throw new InvalidOperationException("Extensión de archivo no permitida. Solo se aceptan PDF, JPG y PNG.");

            if (string.IsNullOrWhiteSpace(file.ContentType) || !AllowedContentTypes.Contains(file.ContentType))
                throw new InvalidOperationException("Tipo de contenido no permitido. Solo se aceptan PDF, JPG y PNG.");
        }

        private async Task CheckCompletionAndNotifyAsync(Provider provider, CancellationToken ct)
        {
            if (provider.Status != ProviderStatus.InterviewApproved)
                return;

            var activeDocs = await _context.Documents
                .Where(d => d.ProviderId == provider.Id && !d.IsDeleted)
                .ToListAsync(ct);

            var presentTypes = activeDocs.Select(d => d.DocumentType).ToHashSet();
            var allRequiredPresent = RequiredProviderDocuments.All.All(t => presentTypes.Contains(t));

            if (!allRequiredPresent)
                return;

            provider.Status = ProviderStatus.AffiliationPending;
            provider.LastUpdate = DateTime.UtcNow;
            await _context.SaveChangesAsync(ct);

            await _notifications.NotifyHrDocumentsReadyAsync(provider, activeDocs, ct);
        }

        private static DocumentOutputDTO ToOutputDTO(Document d) => new()
        {
            Id = d.Id,
            ProviderId = d.ProviderId,
            DocumentType = d.DocumentType.ToString(),
            DocumentStatus = d.DocumentStatus.ToString(),
            FileUrl = d.FileUrl,
            OriginalFileName = d.OriginalFileName,
            SizeBytes = d.SizeBytes,
            CreationDate = d.CreationDate
        };
    }
}
