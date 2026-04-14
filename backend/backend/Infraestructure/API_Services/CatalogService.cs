using backend.Data.DataDB;
using backend.Data.Entities;
using backend.Domain.DTOs;
using backend.Domain.Enum;
using backend.Domain.OutPutDTOs;
using backend.Infraestructure.API_Services_Interfaces;
using Microsoft.EntityFrameworkCore;

namespace backend.Infraestructure.API_Services
{
    public class CatalogService : ICatalogService
    {
        private readonly AppDbContext _context;

        public CatalogService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<CategoryOutputDTO>> GetCategoriesAsync(CancellationToken ct)
        {
            return await _context.Categories
                .Where(c => !c.IsDeleted && c.IsActive)
                .Select(c => new CategoryOutputDTO
                {
                    Id   = c.Id,
                    Name = c.Name,
                    Icon = c.Icon,
                    ActiveProviderCount = c.Providers
                        .Count(pc => pc.Provider.IsActive &&
                                     pc.Provider.Status == ProviderStatus.Affiliated)
                })
                .OrderBy(c => c.Name)
                .ToListAsync(ct);
        }

        public async Task<List<PopularServiceOutputDTO>> GetPopularAsync(CancellationToken ct)
        {
            var since = DateTime.UtcNow.AddDays(-30);

            return await _context.ServiceRequests
                .Where(sr => sr.CreationDate >= since && !sr.IsDeleted)
                .GroupBy(sr => new
                {
                    sr.ServiceItem.Id,
                    sr.ServiceItem.Name,
                    sr.ServiceItem.Icon,
                    sr.ServiceItem.CategoryId,
                    CategoryName = sr.ServiceItem.Category.Name
                })
                .Select(g => new PopularServiceOutputDTO
                {
                    Id           = g.Key.Id,
                    Name         = g.Key.Name,
                    Icon         = g.Key.Icon,
                    CategoryId   = g.Key.CategoryId,
                    CategoryName = g.Key.CategoryName,
                    RequestCount = g.Count()
                })
                .OrderByDescending(s => s.RequestCount)
                .Take(10)
                .ToListAsync(ct);
        }
        private static ServiceItemOutputDTO ToServiceDTO(ServiceItem s) => new()
        {
            Id           = s.Id,
            Name         = s.Name,
            Description  = s.Description,
            Icon         = s.Icon,
            CategoryId   = s.CategoryId,
            CategoryName = s.Category.Name,
            IsActive     = s.IsActive
        };

        public async Task<List<ServiceItemOutputDTO>> GetAllServicesAsync(CancellationToken ct)
        {
            return await _context.ServiceItems
                .Where(s => !s.IsDeleted)
                .Include(s => s.Category)
                .OrderBy(s => s.Name)
                .Select(s => new ServiceItemOutputDTO
                {
                    Id           = s.Id,
                    Name         = s.Name,
                    Description  = s.Description,
                    Icon         = s.Icon,
                    CategoryId   = s.CategoryId,
                    CategoryName = s.Category.Name,
                    IsActive     = s.IsActive
                })
                .ToListAsync(ct);
        }

        public async Task<ServiceItemOutputDTO?> GetServiceByIdAsync(int id, CancellationToken ct)
        {
            var item = await _context.ServiceItems
                .Include(s => s.Category)
                .FirstOrDefaultAsync(s => s.Id == id && !s.IsDeleted, ct);

            return item == null ? null : ToServiceDTO(item);
        }

        public async Task<ServiceItemOutputDTO> CreateServiceAsync(ServiceItemDTO dto, CancellationToken ct)
        {
            var categoryExists = await _context.Categories
                .AnyAsync(c => c.Id == dto.CategoryId && !c.IsDeleted, ct);

            if (!categoryExists)
                throw new InvalidOperationException($"La categoría con id {dto.CategoryId} no existe.");

            var item = new ServiceItem
            {
                Name         = dto.Name,
                Description  = dto.Description,
                Icon         = dto.Icon,
                CategoryId   = dto.CategoryId,
                IsActive     = true,
                CreationDate = DateTime.UtcNow,
                LastUpdate   = DateTime.UtcNow
            };

            _context.ServiceItems.Add(item);
            await _context.SaveChangesAsync(ct);

            await _context.Entry(item).Reference(s => s.Category).LoadAsync(ct);

            return ToServiceDTO(item);
        }

        public async Task<ServiceItemOutputDTO?> UpdateServiceAsync(int id, ServiceItemDTO dto, CancellationToken ct)
        {
            var item = await _context.ServiceItems
                .Include(s => s.Category)
                .FirstOrDefaultAsync(s => s.Id == id && !s.IsDeleted, ct);

            if (item == null) return null;

            if (item.CategoryId != dto.CategoryId)
            {
                var categoryExists = await _context.Categories
                    .AnyAsync(c => c.Id == dto.CategoryId && !c.IsDeleted, ct);

                if (!categoryExists)
                    throw new InvalidOperationException($"La categoría con id {dto.CategoryId} no existe.");
            }

            item.Name        = dto.Name;
            item.Description = dto.Description;
            item.Icon        = dto.Icon;
            item.CategoryId  = dto.CategoryId;
            item.LastUpdate  = DateTime.UtcNow;

            await _context.SaveChangesAsync(ct);

            await _context.Entry(item).Reference(s => s.Category).LoadAsync(ct);

            return ToServiceDTO(item);
        }

        public async Task<bool> DeleteServiceAsync(int id, CancellationToken ct)
        {
            var item = await _context.ServiceItems
                .FirstOrDefaultAsync(s => s.Id == id && !s.IsDeleted, ct);

            if (item == null) return false;

            item.IsDeleted  = true;
            item.IsActive   = false;
            item.LastUpdate = DateTime.UtcNow;

            await _context.SaveChangesAsync(ct);

            return true;
        }

        public async Task<ServiceRequestOutputDTO> RequestServiceAsync(int serviceItemId, int userId, CancellationToken ct)
        {
            var client = await _context.Clients
                .FirstOrDefaultAsync(c => c.UserId == userId, ct);

            if (client == null)
                throw new InvalidOperationException("No se encontró un cliente asociado a este usuario.");

            var serviceItem = await _context.ServiceItems
                .FirstOrDefaultAsync(s => s.Id == serviceItemId && !s.IsDeleted, ct);

            if (serviceItem == null)
                throw new InvalidOperationException($"El servicio con id {serviceItemId} no existe.");

            var request = new ServiceRequest
            {
                ServiceItemId = serviceItemId,
                ClientId      = client.Id,
                IsActive      = true,
                CreationDate  = DateTime.UtcNow,
                LastUpdate    = DateTime.UtcNow
            };

            _context.ServiceRequests.Add(request);
            await _context.SaveChangesAsync(ct);

            return new ServiceRequestOutputDTO
            {
                Id              = request.Id,
                ServiceItemId   = request.ServiceItemId,
                ServiceItemName = serviceItem.Name,
                ClientId        = request.ClientId,
                CreationDate    = request.CreationDate
            };
        }
    }
}
