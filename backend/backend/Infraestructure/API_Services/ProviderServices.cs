using backend.Data.DataDB;
using backend.Data.Entities;
using backend.Domain.DTOs;
using backend.Domain.Enum;
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
        private readonly IJwtService _jwtService;

        public ProviderServices(AppDbContext context, IJwtService jwtService)
        {
            _context = context;
            _jwtService = jwtService;
        }

        private static string HashPassword(string password)
        {
            var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(password));
            return Convert.ToBase64String(bytes);
        }

        private static ProviderOutPutDTO ToOutputDTO(Provider entity, string token = "") => new()
        {
            Id = entity.Id,
            FullName = $"{entity.User.FirstName} {entity.User.LastName}",
            Email = entity.User.Email,
            PhoneNumber = entity.User.PhoneNumber,
            UserRole = entity.User.UserRole.ToString(),
            Status = entity.Status.ToString(),
            InterviewDate = entity.InterviewDate,
            Token = token
        };

        public async Task<ProviderOutPutDTO> CreateAsync(ProviderDTO dto)
        {
            var user = new User
            {
                FirstName = dto.FirstName,
                LastName = dto.LastName,
                Email = dto.Email,
                PasswordHash = HashPassword(dto.Password),
                PhoneNumber = dto.PhoneNumber,
                UserRole = UserRole.Provider,
                IsActive = true,
                CreationDate = DateTime.UtcNow,
                LastUpdate = DateTime.UtcNow
            };

            var entity = new Provider
            {
                User = user,
                Status = ProviderStatus.Registered,
                IsActive = true,
                CreationDate = DateTime.UtcNow,
                LastUpdate = DateTime.UtcNow
            };

            _context.Providers.Add(entity);
            await _context.SaveChangesAsync();

            return ToOutputDTO(entity, _jwtService.GenerateToken(user));
        }

        public async Task<ProviderOutPutDTO?> GetByIdAsync(int id)
        {
            var entity = await _context.Providers
                .Include(p => p.User)
                .FirstOrDefaultAsync(p => p.Id == id);
            if (entity == null) return null;

            return ToOutputDTO(entity);
        }

        public async Task<List<ProviderOutPutDTO>> GetAllAsync()
        {
            var providers = await _context.Providers
                .Include(p => p.User)
                .ToListAsync();
            return providers.Select(p => ToOutputDTO(p)).ToList();
        }

        public async Task<ProviderOutPutDTO?> UpdateAsync(int id, ProviderDTO dto)
        {
            var entity = await _context.Providers
                .Include(p => p.User)
                .FirstOrDefaultAsync(p => p.Id == id);
            if (entity == null) return null;

            entity.User.FirstName = dto.FirstName;
            entity.User.LastName = dto.LastName;
            entity.User.Email = dto.Email;
            entity.User.PasswordHash = HashPassword(dto.Password);
            entity.User.PhoneNumber = dto.PhoneNumber;
            entity.User.LastUpdate = DateTime.UtcNow;
            entity.LastUpdate = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return ToOutputDTO(entity);
        }

        public async Task<ProviderOutPutDTO?> ScheduleInterviewAsync(int id, ScheduleInterviewDTO dto)
        {
            var entity = await _context.Providers
                .Include(p => p.User)
                .FirstOrDefaultAsync(p => p.Id == id);
            if (entity == null) return null;

            entity.InterviewDate = dto.InterviewDate;
            entity.Status = ProviderStatus.InterviewPending;
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
