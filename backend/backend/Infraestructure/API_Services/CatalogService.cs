using backend.Data.DataDB;
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
    }
}
