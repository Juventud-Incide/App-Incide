using backend.Data.DataDB;
using backend.Data.Entities;
using backend.Domain.DTOs;
using backend.Domain.Enum;
using backend.Domain.OutPutDTOs;
using backend.Infraestructure.API_Services_Interfaces;
using Microsoft.EntityFrameworkCore;
using System.Security.Cryptography;
using System.Text;


namespace backend.Infraestructure.API_Services
{
    public class UserService : IUserService
    {
        private readonly AppDbContext _context;

        public UserService(AppDbContext context)
        {
            _context = context;
        }

        private static string HashPassword(string password)
        {
            var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(password));
            return Convert.ToBase64String(bytes);
        }
        private static UserOutPutDTO ToOutputDTO(User user) => new()
        {
            Id = user.Id,
            FullName = $"{user.FirstName} {user.LastName}",
            Email = user.Email,
            PhoneNumber = user.PhoneNumber,
            UserRole = user.UserRole.ToString(),
        };

        public async Task<User> CreateAsync(UserDTO dto)
        {
            var existingUser = await _context.Users.FirstOrDefaultAsync(u => u.Email == dto.Email);
            if (existingUser != null)
                throw new InvalidOperationException("El correo ya está registrado.");

            var user = new User
            {
                FirstName = dto.FirstName,
                LastName = dto.LastName,
                Email = dto.Email,
                PasswordHash = HashPassword(dto.Password),
                PhoneNumber = dto.PhoneNumber,
                UserRole = dto.UserRole,
                IsActive = true,
                CreationDate = DateTime.UtcNow,
                LastUpdate = DateTime.UtcNow
            };

            _context.Users.Add(user);

            if (dto.UserRole == UserRole.Client)
            {
                var client = new Client
                {
                    User = user,
                    IsActive = true,
                    CreationDate = DateTime.UtcNow,
                    LastUpdate = DateTime.UtcNow
                };
                _context.Clients.Add(client);
            }
            else if (dto.UserRole == UserRole.Provider)
            {
                var provider = new Provider
                {
                    User = user,
                    Status = ProviderStatus.Registered,
                    IsActive = true,
                    CreationDate = DateTime.UtcNow,
                    LastUpdate = DateTime.UtcNow
                };
                _context.Providers.Add(provider);
            }

            await _context.SaveChangesAsync();
            return user;
        }

        public async Task<UserOutPutDTO?> GetByIdAsync(int id)
        {
            var user = await _context.Users
                .Include(u => u.Provider)
                .FirstOrDefaultAsync(u => u.Id == id);
            if (user == null) return null;

            return ToOutputDTO(user);
        }

        public async Task<List<UserOutPutDTO>> GetAllAsync()
        {
            var users = await _context.Users
                .Include(u => u.Provider)
                .ToListAsync();

            return users.Select(ToOutputDTO).ToList();
        }

        public async Task<UserOutPutDTO?> UpdateAsync(int id, UserDTO dto)
        {
            var user = await _context.Users
                .Include(u => u.Provider)
                .FirstOrDefaultAsync(u => u.Id == id);
            if (user == null) return null;

            user.FirstName = dto.FirstName;
            user.LastName = dto.LastName;
            user.Email = dto.Email;
            user.PasswordHash = HashPassword(dto.Password);
            user.PhoneNumber = dto.PhoneNumber;
            user.LastUpdate = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return ToOutputDTO(user);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null) return false;

            _context.Users.Remove(user);
            await _context.SaveChangesAsync();
            return true;
        }

    }
}
