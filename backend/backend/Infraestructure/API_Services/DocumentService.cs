using backend.Data.DataDB;
using backend.Data.Entities;
using backend.Domain.DTOs;
using backend.Domain.Enum;
using backend.Domain.OutPutDTOs;
using backend.Infraestructure.API_Services_Interfaces;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

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
        private readonly ILogger<DocumentService> _logger;

        public DocumentService(
            AppDbContext context,
            IFileStorageService storage,
            INotificationService notifications,
            ILogger<DocumentService> logger)
        {
            _context = context;
            _storage = storage;
            _notifications = notifications;
            _logger = logger;
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

            await ValidateFileAsync(dto.File, ct);

            var existing = await _context.Documents
                .FirstOrDefaultAsync(d =>
                    d.ProviderId == provider.Id &&
                    d.DocumentType == dto.DocumentType &&
                    !d.IsDeleted, ct);

            string? oldFileUrl = null;
            if (existing != null)
            {
                existing.IsDeleted = true;
                existing.IsActive = false;
                existing.LastUpdate = DateTime.UtcNow;
                oldFileUrl = existing.FileUrl;
            }

            // 1) Guardar archivo nuevo en disco.
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

            // 2) Confirmar en BD. Si falla, compensamos borrando el archivo recién guardado
            //    para evitar archivos huérfanos en disco sin fila correspondiente.
            try
            {
                await _context.SaveChangesAsync(ct);
            }
            catch
            {
                try
                {
                    await _storage.DeleteAsync(relativePath, CancellationToken.None);
                }
                catch (Exception cleanupEx)
                {
                    _logger.LogWarning(cleanupEx,
                        "No se pudo limpiar el archivo huérfano tras fallo de BD. Path={Path}",
                        relativePath);
                }
                throw;
            }

            // 3) BD consistente. Ahora sí borramos físicamente el archivo viejo.
            //    Si este paso falla, el estado de la BD sigue siendo correcto: el registro
            //    viejo ya está marcado IsDeleted y no afecta funcionalmente. Solo queda
            //    un archivo huérfano en disco que puede limpiarse con un job de mantenimiento.
            if (!string.IsNullOrWhiteSpace(oldFileUrl))
            {
                try
                {
                    await _storage.DeleteAsync(oldFileUrl, ct);
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex,
                        "No se pudo borrar archivo viejo tras reemplazo. Path={Path}",
                        oldFileUrl);
                }
            }

            await CheckCompletionAndNotifyAsync(provider, ct);

            return ToOutputDTO(document);
        }

        private enum DetectedFileSignature
        {
            Unknown,
            Pdf,
            Jpeg,
            Png
        }

        private static async Task ValidateFileAsync(IFormFile file, CancellationToken ct)
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

            // Validación por magic numbers: garantiza que el contenido del archivo
            // realmente corresponde al formato declarado por la extensión/content-type.
            // Defiende contra MIME spoofing (ej. .exe renombrado a .png).
            var detected = await DetectSignatureAsync(file, ct);
            var expected = ExpectedSignatureFor(extension);

            if (detected == DetectedFileSignature.Unknown || detected != expected)
                throw new InvalidOperationException(
                    "El contenido del archivo no corresponde a un PDF, JPG o PNG válido o no coincide con su extensión.");
        }

        private static async Task<DetectedFileSignature> DetectSignatureAsync(IFormFile file, CancellationToken ct)
        {
            await using var stream = file.OpenReadStream();
            var header = new byte[8];
            var read = await stream.ReadAsync(header.AsMemory(0, 8), ct);

            if (read >= 4 &&
                header[0] == 0x25 && header[1] == 0x50 && header[2] == 0x44 && header[3] == 0x46)
                return DetectedFileSignature.Pdf;

            if (read >= 3 &&
                header[0] == 0xFF && header[1] == 0xD8 && header[2] == 0xFF)
                return DetectedFileSignature.Jpeg;

            if (read >= 8 &&
                header[0] == 0x89 && header[1] == 0x50 && header[2] == 0x4E && header[3] == 0x47 &&
                header[4] == 0x0D && header[5] == 0x0A && header[6] == 0x1A && header[7] == 0x0A)
                return DetectedFileSignature.Png;

            return DetectedFileSignature.Unknown;
        }

        private static DetectedFileSignature ExpectedSignatureFor(string extension) => extension.ToLowerInvariant() switch
        {
            ".pdf" => DetectedFileSignature.Pdf,
            ".jpg" => DetectedFileSignature.Jpeg,
            ".jpeg" => DetectedFileSignature.Jpeg,
            ".png" => DetectedFileSignature.Png,
            _ => DetectedFileSignature.Unknown
        };

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
