using System.IdentityModel.Tokens.Jwt;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using backend.Domain.DTOs.Payment;
using backend.Infraestructure.API_Services_Interfaces;

namespace backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class PaymentsController : ControllerBase
    {
        private readonly IPaymentService _paymentService;

        public PaymentsController(IPaymentService paymentService)
        {
            _paymentService = paymentService;
        }

        /// <summary>POST /api/payments/webhook — Stripe sends payment event notifications here.</summary>
        [AllowAnonymous]
        [HttpPost("webhook")]
        public async Task<IActionResult> Webhook(CancellationToken ct)
        {
            // Raw body required: Stripe validates signature against the exact bytes received.
            // Model binding would consume the stream and break the signature check.
            using var reader  = new StreamReader(Request.Body, System.Text.Encoding.UTF8);
            var payload       = await reader.ReadToEndAsync(ct);
            var stripeSignature = Request.Headers["Stripe-Signature"].FirstOrDefault() ?? string.Empty;

            try
            {
                await _paymentService.HandleWebhookAsync(payload, stripeSignature, ct);
                return Ok();
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

        /// <summary>POST /api/payments/initiate — Client initiates a payment for an accepted cotizacion.</summary>
        [Authorize(Roles = "Client")]
        [HttpPost("initiate")]
        public async Task<IActionResult> Initiate([FromBody] InitiatePaymentDTO dto, CancellationToken ct)
        {
            try
            {
                var userId = int.Parse(User.FindFirst(JwtRegisteredClaimNames.Sub)!.Value);
                var result = await _paymentService.InitiateAsync(userId, dto, ct);
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
    }
}
