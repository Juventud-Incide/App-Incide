using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using backend.Data.Entities;
using backend.Infraestructure.API_Services_Interfaces;
using Microsoft.IdentityModel.Tokens;

namespace backend.Infraestructure.API_Services
{
    public class JwtService : IJwtService
    {
        private readonly IConfiguration _configuration;

        public JwtService(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        public string GenerateToken(User user)
        {
            var jwtConfig = _configuration.GetSection("Jwt");

            var key = new SymmetricSecurityKey(System.Text.Encoding.UTF8.GetBytes(jwtConfig["Key"]!));
            var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var claims = new[]
            {
                new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
                new Claim(JwtRegisteredClaimNames.Email, user.Email),
                new Claim(ClaimTypes.Role, user.UserRole.ToString()),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
            };

            var expiration = int.Parse(jwtConfig["ExpirationMinutes"]!);

            var token = new JwtSecurityToken(
                issuer: jwtConfig["Issuer"],
                audience: jwtConfig["Audience"],
                claims: claims,
                expires: DateTime.UtcNow.AddMinutes(expiration),
                signingCredentials: credentials
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
}
