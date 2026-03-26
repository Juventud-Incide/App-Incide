using backend.Data.DataDB;
using backend.Domain.DTOs;
using backend.Domain.OutPutDTOs;
using backend.Infraestructure.API_Services_Interfaces;
using Microsoft.EntityFrameworkCore;
using System.Security.Cryptography;
using System.Text;

namespace backend.Infraestructure.API_Services
{
    public class AuthService : IAuthService
    {
        private readonly AppDbContext _context;
        private readonly IJwtService _jwtService;

        public AuthService(AppDbContext context, IJwtService jwtService)
        {
            _context = context;
            _jwtService = jwtService;
        }

        public async Task<AuthOutPutDTO> LoginAsync(LoginDTO dto)
        {
            var passwordHash = HashPassword(dto.Password);

            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Email == dto.Email && u.PasswordHash == passwordHash);

            if (user == null) return null;

            return new AuthOutPutDTO
            {
                Id = user.Id,
                FullName = $"{user.FirstName} {user.LastName}",
                Email = user.Email,
                UserRole = user.UserRole.ToString(),
                Token = _jwtService.GenerateToken(user)
            };
        }

        private static string HashPassword(string password) 
        { 
            var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(password));
            return Convert.ToBase64String(bytes);  
        }
    }
}
