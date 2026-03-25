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

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            try
            {
                var providers = await _providerService.GetAllAsync();
                return Ok(providers);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            try
            {
                var provider = await _providerService.GetByIdAsync(id);
                if (provider == null)
                    return NotFound(new { message = "Proveedor no encontrado." });

                return Ok(provider);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] ProviderDTO dto)
        {
            try
            {
                var provider = await _providerService.CreateAsync(dto);
                return CreatedAtAction(nameof(GetById), new { id = provider.Id }, provider);
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

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] ProviderDTO dto)
        {
            try
            {
                var provider = await _providerService.UpdateAsync(id, dto);
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
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error interno del servidor.", details = ex.Message });
            }
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            try
            {
                var deleted = await _providerService.DeleteAsync(id);
                if (!deleted)
                    return NotFound(new { message = "Proveedor no encontrado." });

                return Ok(new { message = "Proveedor eliminado exitosamente." });
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
