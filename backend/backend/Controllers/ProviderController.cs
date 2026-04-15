using System.IdentityModel.Tokens.Jwt;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using backend.Infraestructure.API_Services_Interfaces;
using backend.Domain.DTOs;
using backend.Domain.DTOs.Provider;

namespace backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ProviderController : ControllerBase
    {
        private readonly IProviderServices _providerService;

        public ProviderController(IProviderServices providerService)
        {
            _providerService = providerService;
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("{id}/schedule-interview")]
        public async Task<IActionResult> ScheduleInterview(int id, [FromBody] ScheduleInterviewDTO dto)
        {
            try
            {
                var provider = await _providerService.ScheduleInterviewAsync(id, dto);
                if (provider == null)
                    return NotFound(new { message = "Proveedor no encontrado." });

                return Ok(provider);
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

        [Authorize(Roles = "Admin")]
        [HttpPut("{id}/approve-interview")]
        public async Task<IActionResult> ApproveInterview(int id)
        {
            try
            {
                var provider = await _providerService.ApproveInterviewAsync(id);
                if (provider == null)
                    return NotFound(new { message = "Proveedor no encontrado." });

                return Ok(provider);
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

        [Authorize(Roles = "Admin")]
        [HttpPut("{id}/reject-interview")]
        public async Task<IActionResult> RejectInterview(int id, [FromBody] RejectInterviewDTO dto)
        {
            try
            {
                var provider = await _providerService.RejectInterviewAsync(id, dto);
                if (provider == null)
                    return NotFound(new { message = "Proveedor no encontrado." });

                return Ok(provider);
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

        [Authorize(Roles = "Admin")]
        [HttpGet("pending-affiliations")]
        public async Task<IActionResult> GetPendingAffiliations(CancellationToken ct)
        {
            try
            {
                var providers = await _providerService.GetPendingAffiliationsAsync(ct);
                return Ok(providers);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error interno del servidor.", details = ex.Message });
            }
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("{id}/approve-affiliation")]
        public async Task<IActionResult> ApproveAffiliation(int id, CancellationToken ct)
        {
            try
            {
                var provider = await _providerService.ApproveAffiliationAsync(id, ct);
                if (provider == null)
                    return NotFound(new { message = "Proveedor no encontrado." });

                return Ok(provider);
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

        [Authorize(Roles = "Admin")]
        [HttpPut("{id}/reject-affiliation")]
        public async Task<IActionResult> RejectAffiliation(int id, [FromBody] RejectAffiliationDTO dto, CancellationToken ct)
        {
            try
            {
                var provider = await _providerService.RejectAffiliationAsync(id, dto, ct);
                if (provider == null)
                    return NotFound(new { message = "Proveedor no encontrado." });

                return Ok(provider);
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

        [Authorize(Roles = "Admin")]
        [HttpGet("{id}/categorias")]
        public async Task<IActionResult> GetCategories(int id, CancellationToken ct)
        {
            try
            {
                var result = await _providerService.GetCategoriesAsync(id, ct);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error interno del servidor.", details = ex.Message });
            }
        }

        [Authorize(Roles = "Admin")]
        [HttpPost("{id}/categorias/{categoriaId}")]
        public async Task<IActionResult> AssignCategory(int id, int categoriaId, CancellationToken ct)
        {
            try
            {
                var result = await _providerService.AssignCategoryAsync(id, categoriaId, ct);
                return Ok(result);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
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

        [Authorize(Roles = "Admin")]
        [HttpDelete("{id}/categorias/{categoriaId}")]
        public async Task<IActionResult> RemoveCategory(int id, int categoriaId, CancellationToken ct)
        {
            try
            {
                var removed = await _providerService.RemoveCategoryAsync(id, categoriaId, ct);
                if (!removed)
                    return NotFound(new { message = "Relación proveedor-categoría no encontrada." });

                return NoContent();
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error interno del servidor.", details = ex.Message });
            }
        }

        [Authorize(Roles = "Provider")]
        [HttpPatch("availability")]
        public async Task<IActionResult> UpdateAvailability([FromBody] AvailabilityDTO dto, CancellationToken ct)
        {
            try
            {
                var userId = int.Parse(User.FindFirst(JwtRegisteredClaimNames.Sub)!.Value);
                await _providerService.UpdateAvailabilityAsync(userId, dto.Available, ct);
                return Ok(new { available = dto.Available });
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
