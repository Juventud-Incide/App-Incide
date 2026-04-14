using backend.Data.DataDB;
using backend.Data.Entities;
using backend.Domain.DTOs;
using backend.Domain.Enum;
using backend.Domain.OutPutDTOs;
using backend.Infraestructure.API_Services_Interfaces;
using Microsoft.EntityFrameworkCore;

namespace backend.Infraestructure.API_Services
{
    public class CategoryService : ICategoryService
    {
        private readonly AppDbContext _context;

        public CategoryService(AppDbContext context)
        {
            _context = context;
        }

        private static CategoryOutputDTO ToDTO(Category c) => new()
        {
            Id                  = c.Id,
            Name                = c.Name,
            Icon                = c.Icon,
            ActiveProviderCount = c.Providers
                .Count(pc => pc.Provider.IsActive && pc.Provider.Status == ProviderStatus.Affiliated)
        };

        public async Task<List<CategoryOutputDTO>> GetAllAsync(CancellationToken ct)
        {
            return await _context.Categories
                .Where(c => !c.IsDeleted)
                .Include(c => c.Providers).ThenInclude(pc => pc.Provider)
                .OrderBy(c => c.Name)
                .Select(c => new CategoryOutputDTO
                {
                    Id                  = c.Id,
                    Name                = c.Name,
                    Icon                = c.Icon,
                    ActiveProviderCount = c.Providers
                        .Count(pc => pc.Provider.IsActive && pc.Provider.Status == ProviderStatus.Affiliated)
                })
                .ToListAsync(ct);
        }

        public async Task<CategoryOutputDTO?> GetByIdAsync(int id, CancellationToken ct)
        {
            var category = await _context.Categories
                .Where(c => c.Id == id && !c.IsDeleted)
                .Include(c => c.Providers).ThenInclude(pc => pc.Provider)
                .FirstOrDefaultAsync(ct);

            return category == null ? null : ToDTO(category);
        }

        public async Task<CategoryOutputDTO> CreateAsync(CategoryDTO dto, CancellationToken ct)
        {
            var category = new Category
            {
                Name         = dto.Name,
                Icon         = dto.Icon,
                IsActive     = true,
                CreationDate = DateTime.UtcNow,
                LastUpdate   = DateTime.UtcNow
            };

            _context.Categories.Add(category);
            await _context.SaveChangesAsync(ct);

            return ToDTO(category);
        }

        public async Task<CategoryOutputDTO?> UpdateAsync(int id, CategoryDTO dto, CancellationToken ct)
        {
            var category = await _context.Categories
                .Include(c => c.Providers).ThenInclude(pc => pc.Provider)
                .FirstOrDefaultAsync(c => c.Id == id && !c.IsDeleted, ct);

            if (category == null) return null;

            category.Name       = dto.Name;
            category.Icon       = dto.Icon;
            category.LastUpdate = DateTime.UtcNow;

            await _context.SaveChangesAsync(ct);

            return ToDTO(category);
        }

        public async Task<bool> DeleteAsync(int id, CancellationToken ct)
        {
            var category = await _context.Categories
                .FirstOrDefaultAsync(c => c.Id == id && !c.IsDeleted, ct);

            if (category == null) return false;

            category.IsDeleted  = true;
            category.IsActive   = false;
            category.LastUpdate = DateTime.UtcNow;

            await _context.SaveChangesAsync(ct);

            return true;
        }
    }
}
