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
        private readonly IUserService _userService;

        public AuthService(AppDbContext context, IJwtService jwtService, IUserService userService)
        {
            _context = context;
            _jwtService = jwtService;
            _userService = userService;
        }

        public async Task<AuthOutPutDTO> RegisterAsync(RegisterDTO dto)
        {
            if (dto.Password != dto.ConfirmPassword)
                throw new InvalidOperationException("Las contraseñas no coinciden.");

            var userDto = new UserDTO
            {
                FirstName = dto.FirstName,
                LastName = dto.LastName,
                Email = dto.Email,
                Password = dto.Password,
                PhoneNumber = dto.PhoneNumber,
                UserRole = dto.UserRole
            };

            var user = await _userService.CreateAsync(userDto);
            var token = _jwtService.GenerateToken(user);

            return new AuthOutPutDTO
            {
                User = new UserOutPutDTO
                {
                    Id = user.Id,
                    FullName = $"{user.FirstName} {user.LastName}",
                    Email = user.Email,
                    PhoneNumber = user.PhoneNumber,
                    UserRole = user.UserRole.ToString()
                },
                Token = token
            };
        }

        public async Task<AuthOutPutDTO?> LoginAsync(LoginDTO dto)
        {
            var passwordHash = HashPassword(dto.Password);

            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Email == dto.Email && u.PasswordHash == passwordHash);

            if (user == null) return null;

            var token = _jwtService.GenerateToken(user);

            return new AuthOutPutDTO
            {
                User = new UserOutPutDTO
                {
                    Id = user.Id,
                    FullName = $"{user.FirstName} {user.LastName}",
                    Email = user.Email,
                    PhoneNumber = user.PhoneNumber,
                    UserRole = user.UserRole.ToString()
                },
                Token = token
            };
        }

        private static string HashPassword(string password)
        {
            var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(password));
            return Convert.ToBase64String(bytes);
        }
    }
}
