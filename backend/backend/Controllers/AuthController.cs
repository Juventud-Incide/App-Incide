using System.IdentityModel.Tokens.Jwt;
using backend.Domain.DTOs;
using backend.Infraestructure.API_Services_Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;

namespace backend.Controllers
{

    [ApiController]
    [Route("api/[controller]")]
    [EnableRateLimiting("auth")]
    public class AuthController : Controller
    {

        private readonly IAuthService _authService;
        private readonly ITokenRevocationStore _revocationStore;

        public AuthController(IAuthService authService, ITokenRevocationStore revocationStore)
        {
            _authService = authService;
            _revocationStore = revocationStore;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterDTO dto)
        {
            var result = await _authService.RegisterAsync(dto);
            return Ok(result);
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginDTO dto)
        {
            var result = await _authService.LoginAsync(dto);
            if (result == null) return Unauthorized("Credenciales Invalidas.");
            return Ok(result);
        }

        [Authorize]
        [HttpPost("logout")]
        public async Task<IActionResult> Logout(CancellationToken ct)
        {
            try
            {
                var jti = User.FindFirst(JwtRegisteredClaimNames.Jti)?.Value;
                if (string.IsNullOrWhiteSpace(jti))
                    return Unauthorized(new { message = "Token inválido." });

                var expClaim = User.FindFirst(JwtRegisteredClaimNames.Exp)?.Value;
                DateTime expiresAt;
                if (long.TryParse(expClaim, out var expUnix))
                    expiresAt = DateTimeOffset.FromUnixTimeSeconds(expUnix).UtcDateTime;
                else
                    expiresAt = DateTime.UtcNow.AddDays(1);

                await _revocationStore.RevokeAsync(jti, expiresAt, ct);

                return Ok(new { message = "Sesión cerrada correctamente." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error interno del servidor.", details = ex.Message });
            }
        }

    }
}
