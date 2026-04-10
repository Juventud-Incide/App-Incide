using backend.Data.DataDB;
using backend.Data.Entities;
using backend.Domain.DTOs;
using backend.Domain.OutPutDTOs;
using backend.Infraestructure.API_Services_Interfaces;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace backend.Infraestructure.API_Services
{
    public class AuthService : IAuthService
    {
        private readonly AppDbContext _context;
        private readonly IJwtService _jwtService;
        private readonly IUserService _userService;
        private readonly IPasswordHasher<User> _passwordHasher;

        public AuthService(
            AppDbContext context,
            IJwtService jwtService,
            IUserService userService,
            IPasswordHasher<User> passwordHasher)
        {
            _context = context;
            _jwtService = jwtService;
            _userService = userService;
            _passwordHasher = passwordHasher;
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
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Email == dto.Email);

            if (user == null) return null;

            var result = _passwordHasher.VerifyHashedPassword(user, user.PasswordHash, dto.Password);
            if (result == PasswordVerificationResult.Failed) return null;

            if (result == PasswordVerificationResult.SuccessRehashNeeded)
            {
                user.PasswordHash = _passwordHasher.HashPassword(user, dto.Password);
                await _context.SaveChangesAsync();
            }

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
    }
}
