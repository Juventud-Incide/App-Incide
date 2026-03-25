using backend.Data.DataDB;
using backend.Data.Entities;
using backend.Domain.DTOs;
using backend.Domain.OutPutDTOs;
using backend.Infraestructure.API_Services_Interfaces;
using System.Security.Cryptography;
using System.Text;
using Microsoft.EntityFrameworkCore;

namespace backend.Infraestructure.API_Services
{
    public class ProviderServices : IProviderServices
    {
        private readonly AppDbContext _context;

        public ProviderServices(AppDbContext context)
        {
            _context = context;
        }

        private static string HashPassword(string password)
        {
            var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(password));
            return Convert.ToBase64String(bytes);
        }

        private static ProviderOutPutDTO ToOutputDTO(Provider entity) => new()
        {
            Id = entity.Id,
            FullName = $"{entity.FirstName} {entity.LastName}",
            Email = entity.Email,
            PhoneNumber = entity.PhoneNumber,
            UserRole = entity.UserRoles.ToString(),
            Token = string.Empty
        };

        public async Task<ProviderOutPutDTO> CreateAsync(ProviderDTO dto)
        {
            var entity = new Provider
            {
                FirstName = dto.FirstName,
                LastName = dto.LastName,
                Email = dto.Email,
                PasswordHash = HashPassword(dto.Password),
                PhoneNumber = dto.PhoneNumber,
                IsActive = true,
                CreationDate = DateTime.UtcNow,
                LastUpdate = DateTime.UtcNow
            };

            _context.Providers.Add(entity);
            await _context.SaveChangesAsync();

            return ToOutputDTO(entity);
        }

        public async Task<ProviderOutPutDTO?> GetByIdAsync(int id)
        {
            var entity = await _context.Providers.FindAsync(id);
            if (entity == null) return null;

            return ToOutputDTO(entity);
        }

        public async Task<List<ProviderOutPutDTO>> GetAllAsync()
        {
            var providers = await _context.Providers.ToListAsync();
            return providers.Select(ToOutputDTO).ToList();
        }

        public async Task<ProviderOutPutDTO?> UpdateAsync(int id, ProviderDTO dto)
        {
            var entity = await _context.Providers.FindAsync(id);
            if (entity == null) return null;

            entity.FirstName = dto.FirstName;
            entity.LastName = dto.LastName;
            entity.Email = dto.Email;
            entity.PasswordHash = HashPassword(dto.Password);
            entity.PhoneNumber = dto.PhoneNumber;
            entity.LastUpdate = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return ToOutputDTO(entity);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var entity = await _context.Providers.FindAsync(id);
            if (entity == null) return false;

            _context.Providers.Remove(entity);
            await _context.SaveChangesAsync();
            return true;
        }
    }
}
