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
            FullName = $"{entity.FirstName} {entity.LastName}",
            Email = entity.Email,
            PhoneNumber = entity.PhoneNumber,
            UserRole = entity.UserRoles.ToString(),
            Token = string.Empty
        };

        public async Task<ClientOutPutDTO> CreateAsync(ClientDTO dto)
        {
            var entity = new Client
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

            _context.Clients.Add(entity);
            await _context.SaveChangesAsync();

            return ToOutputDTO(entity);
        }

        public async Task<ClientOutPutDTO?> GetByIdAsync(int id)
        {
            var entity = await _context.Clients.FindAsync(id);
            if (entity == null) return null;

            return ToOutputDTO(entity);
        }

        public async Task<List<ClientOutPutDTO>> GetAllAsync()
        {
            var clients = await _context.Clients.ToListAsync();
            return clients.Select(ToOutputDTO).ToList();
        }

        public async Task<ClientOutPutDTO?> UpdateAsync(int id, ClientDTO dto)
        {
            var entity = await _context.Clients.FindAsync(id);
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
            var entity = await _context.Clients.FindAsync(id);
            if (entity == null) return false;

            _context.Clients.Remove(entity);
            await _context.SaveChangesAsync();
            return true;
        }
    }
}
