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

        private readonly IAuthService          _authService;
        private readonly ITokenRevocationStore _revocationStore;
        private readonly IOtpService           _otpService;

        public AuthController(
            IAuthService authService,
            ITokenRevocationStore revocationStore,
            IOtpService otpService)
        {
            _authService     = authService;
            _revocationStore = revocationStore;
            _otpService      = otpService;
        }

        [HttpPost("send-otp")]
        public async Task<IActionResult> SendOtp([FromBody] SendOtpDTO dto, CancellationToken ct)
        {
            await _otpService.SendOtpAsync(dto.PhoneNumber, ct);
            return Ok(new { message = "Código enviado correctamente." });
        }

        [HttpPost("verify-otp")]
        public async Task<IActionResult> VerifyOtp([FromBody] VerifyOtpDTO dto, CancellationToken ct)
        {
            var valid = await _otpService.VerifyOtpAsync(dto.PhoneNumber, dto.Code, ct);
            if (!valid)
                return BadRequest(new { message = "Código inválido, expirado o máximo de intentos alcanzado." });

            return Ok(new { message = "Teléfono verificado correctamente." });
        }

        [HttpPost("register/provider")]
        public async Task<IActionResult> RegisterProvider([FromBody] RegisterProviderDTO dto, CancellationToken ct)
        {
            try
            {
                var result = await _authService.RegisterProviderAsync(dto);
                return StatusCode(StatusCodes.Status201Created, result);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Microsoft.EntityFrameworkCore.DbUpdateException)
            {
                return Conflict(new { message = "Ya existe un proveedor registrado con ese CURP, RFC o correo." });
            }
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
