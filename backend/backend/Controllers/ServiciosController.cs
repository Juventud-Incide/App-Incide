using backend.Infraestructure.API_Services_Interfaces;
using Microsoft.AspNetCore.Mvc;

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
    }
}
