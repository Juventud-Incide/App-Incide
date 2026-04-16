using backend.Domain.DTOs;
using backend.Infraestructure.API_Services_Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers
{
    [Route("api/categorias")]
    [ApiController]
    public class CategoriasController : ControllerBase
    {
        private readonly ICategoryService _service;

        public CategoriasController(ICategoryService service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll(CancellationToken ct)
        {
            try
            {
                return Ok(await _service.GetAllAsync(ct));
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error interno del servidor.", details = ex.Message });
            }
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id, CancellationToken ct)
        {
            try
            {
                var result = await _service.GetByIdAsync(id, ct);
                if (result == null)
                    return NotFound(new { message = "Categoría no encontrada." });

                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error interno del servidor.", details = ex.Message });
            }
        }

        [Authorize(Roles = "Admin")]
        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CategoryDTO dto, CancellationToken ct)
        {
            try
            {
                var result = await _service.CreateAsync(dto, ct);
                return CreatedAtAction(nameof(GetById), new { id = result.Id }, result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error interno del servidor.", details = ex.Message });
            }
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] CategoryDTO dto, CancellationToken ct)
        {
            try
            {
                var result = await _service.UpdateAsync(id, dto, ct);
                if (result == null)
                    return NotFound(new { message = "Categoría no encontrada." });

                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error interno del servidor.", details = ex.Message });
            }
        }

        [Authorize(Roles = "Admin")]
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id, CancellationToken ct)
        {
            try
            {
                var deleted = await _service.DeleteAsync(id, ct);
                if (!deleted)
                    return NotFound(new { message = "Categoría no encontrada." });

                return NoContent();
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error interno del servidor.", details = ex.Message });
            }
        }
    }
}
