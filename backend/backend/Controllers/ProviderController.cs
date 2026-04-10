using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using backend.Infraestructure.API_Services_Interfaces;
using backend.Domain.DTOs;

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
    }
}
