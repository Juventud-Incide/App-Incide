using Microsoft.AspNetCore.Mvc;
using backend.Infraestructure.API_Services_Interfaces;
using backend.Domain.DTOs;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ClientController : ControllerBase
    {
        private readonly IClientServices _clientService;

        public ClientController(IClientServices clientService)
        {
            _clientService = clientService;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            try
            {
                var Clients = await _clientService.GetAllAsync();
                return Ok(Clients);
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
                var Client = await _clientService.GetByIdAsync(id);
                if (Client == null)
                    return NotFound(new { message = "Cliente no encontrado." });

                return Ok(Client);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] ClientDTO dto)
        {
            try
            {
                var Client = await _clientService.CreateAsync(dto);
                return CreatedAtAction(nameof(GetById), new { id = Client.Id }, Client);
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
        public async Task<IActionResult> Update(int id, [FromBody] ClientDTO dto)
        {
            try
            {
                var Client = await _clientService.UpdateAsync(id, dto);
                if (Client == null)
                    return NotFound(new { message = "Cliente no encontrado." });

                return Ok(Client);
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

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            try
            {
                var deleted = await _clientService.DeleteAsync(id);
                if (!deleted)
                    return NotFound(new { message = "Cliente no encontrado." });

                return Ok(new { message = "Cliente eliminado exitosamente." });
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
