using backend.Domain.DTOs;
using backend.Infraestructure.API_Services_Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.IdentityModel.Tokens.Jwt;

namespace backend.Controllers
{
    [Route("api/servicios")]
    [ApiController]
    public class ServiciosController : ControllerBase
    {
        private readonly ICatalogService _catalog;

        public ServiciosController(ICatalogService catalog)
        {
            _catalog = catalog;
        }

        [HttpGet("categorias")]
        public async Task<IActionResult> GetCategories(CancellationToken ct)
        {
            try
            {
                return Ok(await _catalog.GetCategoriesAsync(ct));
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error interno del servidor.", details = ex.Message });
            }
        }

        [HttpGet("populares")]
        public async Task<IActionResult> GetPopular(CancellationToken ct)
        {
            try
            {
                return Ok(await _catalog.GetPopularAsync(ct));
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error interno del servidor.", details = ex.Message });
            }
        }

        [HttpGet]
        public async Task<IActionResult> GetAll(CancellationToken ct)
        {
            try
            {
                return Ok(await _catalog.GetAllServicesAsync(ct));
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
                var result = await _catalog.GetServiceByIdAsync(id, ct);
                if (result == null)
                    return NotFound(new { message = "Servicio no encontrado." });

                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error interno del servidor.", details = ex.Message });
            }
        }

        [Authorize(Roles = "Admin")]
        [HttpPost]
        public async Task<IActionResult> Create([FromBody] ServiceItemDTO dto, CancellationToken ct)
        {
            try
            {
                var result = await _catalog.CreateServiceAsync(dto, ct);
                return CreatedAtAction(nameof(GetById), new { id = result.Id }, result);
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
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] ServiceItemDTO dto, CancellationToken ct)
        {
            try
            {
                var result = await _catalog.UpdateServiceAsync(id, dto, ct);
                if (result == null)
                    return NotFound(new { message = "Servicio no encontrado." });

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

        [Authorize(Roles = "Admin")]
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id, CancellationToken ct)
        {
            try
            {
                var deleted = await _catalog.DeleteServiceAsync(id, ct);
                if (!deleted)
                    return NotFound(new { message = "Servicio no encontrado." });

                return NoContent();
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error interno del servidor.", details = ex.Message });
            }
        }

        [Authorize(Roles = "Client")]
        [HttpPost("{id}/solicitar")]
        public async Task<IActionResult> RequestService(int id, CancellationToken ct)
        {
            try
            {
                var userId = int.Parse(User.FindFirst(JwtRegisteredClaimNames.Sub)!.Value);
                var result = await _catalog.RequestServiceAsync(id, userId, ct);
                return CreatedAtAction(nameof(GetById), new { id = result.ServiceItemId }, result);
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
