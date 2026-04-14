using backend.Data.DataDB;
using backend.Data.Entities;
using backend.Domain.DTOs;
using backend.Domain.Enum;
using backend.Domain.OutPutDTOs;
using backend.Infraestructure.API_Services_Interfaces;
using Microsoft.EntityFrameworkCore;

namespace backend.Infraestructure.API_Services
{
    public class ProviderServices : IProviderServices
    {
        private readonly AppDbContext _context;
        private readonly INotificationService _notifications;

        public ProviderServices(AppDbContext context, INotificationService notifications)
        {
            _context = context;
            _notifications = notifications;
        }

        private static ProviderOutPutDTO ToOutputDTO(Provider provider) => new()
        {
            Id = provider.Id,
            FullName = $"{provider.User.FirstName} {provider.User.LastName}",
            Email = provider.User.Email,
            PhoneNumber = provider.User.PhoneNumber,
            UserRole = provider.User.UserRole.ToString(),
            Status = provider.Status.ToString(),
            InterviewDate = provider.InterviewDate,
            Token = string.Empty
        };

        public async Task<ProviderOutPutDTO?> ScheduleInterviewAsync(int id, ScheduleInterviewDTO dto)
        {
            var provider = await _context.Providers
                .Include(p => p.User)
                .FirstOrDefaultAsync(p => p.Id == id);

            if (provider == null) return null;

            if (provider.Status != ProviderStatus.Registered)
                throw new InvalidOperationException(
                    $"No se puede agendar entrevista: el proveedor está en estado '{provider.Status}'. Solo se permite desde 'Registered'.");

            if (dto.InterviewDate <= DateTime.UtcNow)
                throw new InvalidOperationException("La fecha de la entrevista debe ser en el futuro.");

            provider.InterviewDate = dto.InterviewDate;
            provider.Status = ProviderStatus.InterviewPending;
            provider.LastUpdate = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return ToOutputDTO(provider);
        }

        public async Task<ProviderOutPutDTO?> ApproveInterviewAsync(int id)
        {
            var provider = await _context.Providers
                .Include(p => p.User)
                .FirstOrDefaultAsync(p => p.Id == id);

            if (provider == null) return null;

            if (provider.Status != ProviderStatus.InterviewPending)
                throw new InvalidOperationException(
                    $"No se puede aprobar la entrevista: el proveedor está en estado '{provider.Status}'. Solo se permite desde 'InterviewPending'.");

            provider.Status = ProviderStatus.InterviewApproved;
            provider.InterviewRejectionReason = null;
            provider.LastUpdate = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return ToOutputDTO(provider);
        }

        public async Task<ProviderOutPutDTO?> RejectInterviewAsync(int id, RejectInterviewDTO dto)
        {
            var provider = await _context.Providers
                .Include(p => p.User)
                .FirstOrDefaultAsync(p => p.Id == id);

            if (provider == null) return null;

            if (provider.Status != ProviderStatus.InterviewPending)
                throw new InvalidOperationException(
                    $"No se puede rechazar la entrevista: el proveedor está en estado '{provider.Status}'. Solo se permite desde 'InterviewPending'.");

            provider.Status = ProviderStatus.Rejected;
            provider.InterviewRejectionReason = dto.Reason;
            provider.LastUpdate = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return ToOutputDTO(provider);
        }

        public async Task<List<ProviderReviewOutputDTO>> GetPendingAffiliationsAsync(CancellationToken ct)
        {
            var providers = await _context.Providers
                .Include(p => p.User)
                .Where(p => p.Status == ProviderStatus.AffiliationPending)
                .ToListAsync(ct);

            var providerIds = providers.Select(p => p.Id).ToList();
            var docs = await _context.Documents
                .Where(d => providerIds.Contains(d.ProviderId) && !d.IsDeleted)
                .ToListAsync(ct);

            return providers.Select(p => new ProviderReviewOutputDTO
            {
                Id = p.Id,
                FullName = $"{p.User.FirstName} {p.User.LastName}",
                Email = p.User.Email,
                PhoneNumber = p.User.PhoneNumber ?? string.Empty,
                Status = p.Status.ToString(),
                InterviewDate = p.InterviewDate,
                Documents = docs
                    .Where(d => d.ProviderId == p.Id)
                    .Select(ToDocumentDTO)
                    .ToList()
            }).ToList();
        }

        public async Task<ProviderOutPutDTO?> ApproveAffiliationAsync(int id, CancellationToken ct)
        {
            var provider = await _context.Providers
                .Include(p => p.User)
                .FirstOrDefaultAsync(p => p.Id == id, ct);

            if (provider == null) return null;

            if (provider.Status != ProviderStatus.AffiliationPending)
                throw new InvalidOperationException(
                    $"No se puede aprobar la afiliación: el proveedor está en estado '{provider.Status}'. Solo se permite desde 'AffiliationPending'.");

            provider.Status = ProviderStatus.Affiliated;
            provider.AffiliationRejectionReason = null;
            provider.LastUpdate = DateTime.UtcNow;

            await _context.SaveChangesAsync(ct);
            await _notifications.NotifyProviderAffiliationApprovedAsync(provider, ct);

            return ToOutputDTO(provider);
        }

        public async Task<ProviderOutPutDTO?> RejectAffiliationAsync(int id, RejectAffiliationDTO dto, CancellationToken ct)
        {
            var provider = await _context.Providers
                .Include(p => p.User)
                .FirstOrDefaultAsync(p => p.Id == id, ct);

            if (provider == null) return null;

            if (provider.Status != ProviderStatus.AffiliationPending)
                throw new InvalidOperationException(
                    $"No se puede rechazar la afiliación: el proveedor está en estado '{provider.Status}'. Solo se permite desde 'AffiliationPending'.");

            provider.Status = ProviderStatus.Rejected;
            provider.AffiliationRejectionReason = dto.Reason;
            provider.LastUpdate = DateTime.UtcNow;

            await _context.SaveChangesAsync(ct);
            await _notifications.NotifyProviderAffiliationRejectedAsync(provider, dto.Reason, ct);

            return ToOutputDTO(provider);
        }

        private static DocumentOutputDTO ToDocumentDTO(Document d) => new()
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

        private static ProviderCategoryOutputDTO ToCategoryDTO(ProviderCategory pc) => new()
        {
            CategoryId   = pc.CategoryId,
            CategoryName = pc.Category.Name,
            CategoryIcon = pc.Category.Icon
        };

        public async Task<List<ProviderCategoryOutputDTO>> GetCategoriesAsync(int providerId, CancellationToken ct)
        {
            return await _context.ProviderCategories
                .Where(pc => pc.ProviderId == providerId)
                .Include(pc => pc.Category)
                .Select(pc => new ProviderCategoryOutputDTO
                {
                    CategoryId   = pc.CategoryId,
                    CategoryName = pc.Category.Name,
                    CategoryIcon = pc.Category.Icon
                })
                .ToListAsync(ct);
        }

        public async Task<ProviderCategoryOutputDTO> AssignCategoryAsync(int providerId, int categoryId, CancellationToken ct)
        {
            var provider = await _context.Providers
                .FirstOrDefaultAsync(p => p.Id == providerId && !p.IsDeleted, ct);

            if (provider == null)
                throw new KeyNotFoundException($"Proveedor con id {providerId} no encontrado.");

            var category = await _context.Categories
                .FirstOrDefaultAsync(c => c.Id == categoryId && !c.IsDeleted, ct);

            if (category == null)
                throw new KeyNotFoundException($"Categoría con id {categoryId} no encontrada.");

            var alreadyAssigned = await _context.ProviderCategories
                .AnyAsync(pc => pc.ProviderId == providerId && pc.CategoryId == categoryId, ct);

            if (alreadyAssigned)
                throw new InvalidOperationException("El proveedor ya tiene asignada esta categoría.");

            var relation = new ProviderCategory
            {
                ProviderId = providerId,
                CategoryId = categoryId
            };

            _context.ProviderCategories.Add(relation);
            await _context.SaveChangesAsync(ct);

            relation.Category = category;

            return ToCategoryDTO(relation);
        }

        public async Task<bool> RemoveCategoryAsync(int providerId, int categoryId, CancellationToken ct)
        {
            var relation = await _context.ProviderCategories
                .FirstOrDefaultAsync(pc => pc.ProviderId == providerId && pc.CategoryId == categoryId, ct);

            if (relation == null) return false;

            _context.ProviderCategories.Remove(relation);
            await _context.SaveChangesAsync(ct);

            return true;
        }
    }
}
