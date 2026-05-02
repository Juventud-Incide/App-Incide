using backend.Domain.DTOs.Questionnaire;
using backend.Infraestructure.API_Services_Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers
{
    [Route("api/cuestionario")]
    [ApiController]
    public class QuestionnaireController : ControllerBase
    {
        private readonly IQuestionnaireService _questionnaire;

        public QuestionnaireController(IQuestionnaireService questionnaire)
        {
            _questionnaire = questionnaire;
        }

        [HttpGet("{categoriaId}")]
        public async Task<IActionResult> GetByCategory(int categoriaId, CancellationToken ct)
        {
            try
            {
                return Ok(await _questionnaire.GetByCategoryAsync(categoriaId, ct));
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error interno del servidor.", details = ex.Message });
            }
        }

        [Authorize(Roles = "Admin")]
        [HttpPost("{categoriaId}")]
        public async Task<IActionResult> Create(int categoriaId, [FromBody] QuestionDTO dto, CancellationToken ct)
        {
            try
            {
                var result = await _questionnaire.CreateAsync(categoriaId, dto, ct);
                return CreatedAtAction(nameof(GetByCategory), new { categoriaId = result.CategoryId }, result);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (ArgumentException ex)
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
        public async Task<IActionResult> Update(int id, [FromBody] QuestionDTO dto, CancellationToken ct)
        {
            try
            {
                var result = await _questionnaire.UpdateAsync(id, dto, ct);
                if (result == null)
                    return NotFound(new { message = "Pregunta no encontrada." });

                return Ok(result);
            }
            catch (ArgumentException ex)
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
                var deleted = await _questionnaire.DeleteAsync(id, ct);
                if (!deleted)
                    return NotFound(new { message = "Pregunta no encontrada." });

                return NoContent();
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error interno del servidor.", details = ex.Message });
            }
        }
    }
}
