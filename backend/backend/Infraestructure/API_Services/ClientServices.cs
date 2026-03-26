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
    public class ClientServices : IClientServices
    {
        private readonly AppDbContext _context;

        public ClientServices(AppDbContext context)
        {
            _context = context;
        }

        private static string HashPassword(string password)
        {
            var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(password));
            return Convert.ToBase64String(bytes);
        }

        private static ClientOutPutDTO ToOutputDTO(Client entity) => new()
        {
            Id = entity.Id,
            FullName = $"{entity.User.FirstName} {entity.User.LastName}",
            Email = entity.User.Email,
            PhoneNumber = entity.User.PhoneNumber,
            UserRole = entity.User.UserRole.ToString(),
            Token = string.Empty
        };

        public async Task<ClientOutPutDTO> CreateAsync(ClientDTO dto)
        {
            var user = new User
            {
                FirstName = dto.FirstName,
                LastName = dto.LastName,
                Email = dto.Email,
                PasswordHash = HashPassword(dto.Password),
                PhoneNumber = dto.PhoneNumber,
                UserRole = UserRole.Client,
                IsActive = true,
                CreationDate = DateTime.UtcNow,
                LastUpdate = DateTime.UtcNow
            };

            var entity = new Client
            {
                User = user,
                IsActive = true,
                CreationDate = DateTime.UtcNow,
                LastUpdate = DateTime.UtcNow
            };

            _context.Clients.Add(entity);
            await _context.SaveChangesAsync();

            return ToOutputDTO(entity);
        }

        public async Task<ClientOutPutDTO?> GetByIdAsync(int id)
        {
            var entity = await _context.Clients
                .Include(c => c.User)
                .FirstOrDefaultAsync(c => c.Id == id);
            if (entity == null) return null;

            return ToOutputDTO(entity);
        }

        public async Task<List<ClientOutPutDTO>> GetAllAsync()
        {
            var clients = await _context.Clients
                .Include(c => c.User)
                .ToListAsync();
            return clients.Select(ToOutputDTO).ToList();
        }

        public async Task<ClientOutPutDTO?> UpdateAsync(int id, ClientDTO dto)
        {
            var entity = await _context.Clients
                .Include(c => c.User)
                .FirstOrDefaultAsync(c => c.Id == id);
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

        public async Task<bool> DeleteAsync(int id)
        {
            var entity = await _context.Clients.FindAsync(id);
            if (entity == null) return false;

            _context.Clients.Remove(entity);
            await _context.SaveChangesAsync();
            return true;
        }
    }
}
