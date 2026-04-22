using System.IdentityModel.Tokens.Jwt;
using backend.Infraestructure.API_Services_Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class ChatController : ControllerBase
    {
        private readonly IChatService _chatService;

        public ChatController(IChatService chatService)
        {
            _chatService = chatService;
        }

        // ── Helpers ───────────────────────────────────────────────────────────

        private int GetUserId() =>
            int.Parse(User.FindFirst(JwtRegisteredClaimNames.Sub)!.Value);

        // ── Endpoints ─────────────────────────────────────────────────────────

        /// <summary>GET /api/chat/rooms — Lista las salas del usuario (cliente o proveedor).</summary>
        [HttpGet("rooms")]
        public async Task<IActionResult> GetMyRooms(CancellationToken ct)
        {
            try
            {
                var rooms = await _chatService.GetMyRoomsAsync(GetUserId(), ct);
                return Ok(rooms);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = ex.Message });
            }
        }

        /// <summary>GET /api/chat/rooms/{id}/messages?limit=50 — Historial de mensajes de una sala.</summary>
        [HttpGet("rooms/{id}/messages")]
        public async Task<IActionResult> GetHistory(int id, [FromQuery] int limit = 50, CancellationToken ct = default)
        {
            try
            {
                var messages = await _chatService.GetHistoryAsync(id, GetUserId(), limit, ct);
                return Ok(messages);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (UnauthorizedAccessException)
            {
                return Forbid();
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = ex.Message });
            }
        }
    }
}
