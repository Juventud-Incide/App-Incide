using System.IdentityModel.Tokens.Jwt;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using backend.Domain.DTOs.Cotizacion;
using backend.Domain.Enum;
using backend.Infraestructure.API_Services_Interfaces;

namespace backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CotizacionesController : ControllerBase
    {
        private readonly ICotizacionService _cotizacionService;

        public CotizacionesController(ICotizacionService cotizacionService)
        {
            _cotizacionService = cotizacionService;
        }

        // ── Client endpoints ─────────────────────────────────────────────────

        /// <summary>POST /api/cotizaciones/solicitudes — Client creates a service request.</summary>
        [Authorize(Roles = "Client")]
        [HttpPost("solicitudes")]
        public async Task<IActionResult> CreateServiceRequest(
            [FromBody] CreateServiceRequestDTO dto, CancellationToken ct)
        {
            try
            {
                var userId = int.Parse(User.FindFirst(JwtRegisteredClaimNames.Sub)!.Value);
                var result = await _cotizacionService.CreateServiceRequestAsync(userId, dto, ct);
                return CreatedAtAction(nameof(GetRequestById), new { id = result.Id }, result);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error interno del servidor.", details = ex.Message });
            }
        }

        /// <summary>GET /api/cotizaciones/solicitudes/mias — Client lists their own service requests.</summary>
        /// <param name="status">Optional filter: 0=Active, 1=Assigned, 2=Completed, 3=Cancelled</param>
        [Authorize(Roles = "Client")]
        [HttpGet("solicitudes/mias")]
        public async Task<IActionResult> GetMyRequests([FromQuery] CotizacionRequestStatus? status, CancellationToken ct)
        {
            try
            {
                var userId = int.Parse(User.FindFirst(JwtRegisteredClaimNames.Sub)!.Value);
                var result = await _cotizacionService.GetMyRequestsAsync(userId, status, ct);
                return Ok(result);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error interno del servidor.", details = ex.Message });
            }
        }

        /// <summary>GET /api/cotizaciones/solicitudes/{id} — Get a service request by id.</summary>
        [Authorize(Roles = "Client,Provider")]
        [HttpGet("solicitudes/{id}")]
        public async Task<IActionResult> GetRequestById(int id, CancellationToken ct)
        {
            try
            {
                var userId = int.Parse(User.FindFirst(JwtRegisteredClaimNames.Sub)!.Value);
                var result = await _cotizacionService.GetRequestByIdAsync(id, userId, ct);
                if (result == null)
                    return NotFound(new { message = "Service request not found." });
                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error interno del servidor.", details = ex.Message });
            }
        }

        /// <summary>POST /api/cotizaciones/{id}/accept — Client accepts a cotizacion.</summary>
        [Authorize(Roles = "Client")]
        [HttpPost("{id}/accept")]
        public async Task<IActionResult> AcceptCotizacion(int id, CancellationToken ct)
        {
            try
            {
                var userId = int.Parse(User.FindFirst(JwtRegisteredClaimNames.Sub)!.Value);
                var result = await _cotizacionService.AcceptCotizacionAsync(id, userId, ct);
                return Ok(result);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error interno del servidor.", details = ex.Message });
            }
        }

        /// <summary>POST /api/cotizaciones/{id}/reject — Client rejects a cotizacion.</summary>
        [Authorize(Roles = "Client")]
        [HttpPost("{id}/reject")]
        public async Task<IActionResult> RejectCotizacion(
            int id, [FromBody] RejectCotizacionDTO dto, CancellationToken ct)
        {
            try
            {
                var userId = int.Parse(User.FindFirst(JwtRegisteredClaimNames.Sub)!.Value);
                var result = await _cotizacionService.RejectCotizacionAsync(id, userId, dto, ct);
                return Ok(result);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error interno del servidor.", details = ex.Message });
            }
        }

        // ── Provider endpoints ───────────────────────────────────────────────

        /// <summary>GET /api/cotizaciones/mapa — Provider gets nearby active service requests.</summary>
        [Authorize(Roles = "Provider")]
        [HttpGet("mapa")]
        public async Task<IActionResult> GetMap([FromQuery] CotizacionesMapQueryDTO query, CancellationToken ct)
        {
            try
            {
                var userId = int.Parse(User.FindFirst(JwtRegisteredClaimNames.Sub)!.Value);
                var result = await _cotizacionService.GetMapAsync(userId, query, ct);
                return Ok(result);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error interno del servidor.", details = ex.Message });
            }
        }

        /// <summary>POST /api/cotizaciones/solicitudes/{id}/cotizar — Provider submits a cotizacion.</summary>
        [Authorize(Roles = "Provider")]
        [HttpPost("solicitudes/{id}/cotizar")]
        public async Task<IActionResult> SubmitCotizacion(
            int id, [FromBody] SubmitCotizacionDTO dto, CancellationToken ct)
        {
            try
            {
                var userId = int.Parse(User.FindFirst(JwtRegisteredClaimNames.Sub)!.Value);
                var result = await _cotizacionService.SubmitCotizacionAsync(id, userId, dto, ct);
                return CreatedAtAction(nameof(GetRequestById), new { id = result.ServiceRequestId }, result);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error interno del servidor.", details = ex.Message });
            }
        }

        /// <summary>GET /api/cotizaciones/mias — Provider lists their submitted cotizaciones.</summary>
        [Authorize(Roles = "Provider")]
        [HttpGet("mias")]
        public async Task<IActionResult> GetMyCotizaciones(CancellationToken ct)
        {
            try
            {
                var userId = int.Parse(User.FindFirst(JwtRegisteredClaimNames.Sub)!.Value);
                var result = await _cotizacionService.GetMyCotizacionesAsync(userId, ct);
                return Ok(result);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error interno del servidor.", details = ex.Message });
            }
        }

        /// <summary>DELETE /api/cotizaciones/{id} — Provider withdraws a cotizacion.</summary>
        [Authorize(Roles = "Provider")]
        [HttpDelete("{id}")]
        public async Task<IActionResult> WithdrawCotizacion(int id, CancellationToken ct)
        {
            try
            {
                var userId = int.Parse(User.FindFirst(JwtRegisteredClaimNames.Sub)!.Value);
                var withdrawn = await _cotizacionService.WithdrawCotizacionAsync(id, userId, ct);
                if (!withdrawn)
                    return NotFound(new { message = "Cotizacion not found." });
                return NoContent();
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error interno del servidor.", details = ex.Message });
            }
        }
    }
}
