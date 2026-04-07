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
    }
}
