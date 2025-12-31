using Microsoft.AspNetCore.Mvc;
using TradingViewWebhook.Models;
using TradingViewWebhook.Services;
using System.Text.Json;

namespace TradingViewWebhook.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class WebhookController : ControllerBase
    {
        private readonly ILogger<WebhookController> _logger;
        private readonly IWebhookService _webhookService;

        public WebhookController(ILogger<WebhookController> logger, IWebhookService webhookService)
        {
            _logger = logger;
            _webhookService = webhookService;
        }

        /// <summary>
        /// Main endpoint to receive TradingView webhook alerts
        /// URL: http://yourdomain.com/api/webhook/receive
        /// </summary>
        [HttpPost("receive")]
        [Consumes("application/json")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> ReceiveAlert([FromBody] TradingViewAlert? alert)
        {
            try
            {
                _logger.LogInformation("Received webhook request from IP: {IP}", HttpContext.Connection.RemoteIpAddress);

                if (alert == null)
                {
                    _logger.LogWarning("Received null or invalid alert payload");
                    return BadRequest(new WebhookResponse
                    {
                        Success = false,
                        Message = "Invalid payload - alert data is null",
                        Timestamp = DateTime.UtcNow
                    });
                }

                _logger.LogInformation("Processing TradingView Alert: {Alert}", alert.ToString());

                // Process the alert using the webhook service
                var alertId = await _webhookService.ProcessAlertAsync(alert);

                var response = new WebhookResponse
                {
                    Success = true,
                    Message = "Alert received and processed successfully",
                    Timestamp = DateTime.UtcNow,
                    AlertId = alertId
                };

                return Ok(response);
            }
            catch (JsonException jsonEx)
            {
                _logger.LogError(jsonEx, "JSON parsing error while processing webhook");
                return BadRequest(new WebhookResponse
                {
                    Success = false,
                    Message = $"JSON parsing error: {jsonEx.Message}",
                    Timestamp = DateTime.UtcNow
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing webhook alert");
                return StatusCode(500, new WebhookResponse
                {
                    Success = false,
                    Message = "Internal server error while processing alert",
                    Timestamp = DateTime.UtcNow
                });
            }
        }

        /// <summary>
        /// Alternative endpoint that accepts raw string payload
        /// URL: http://yourdomain.com/api/webhook/receive-raw
        /// </summary>
        [HttpPost("receive-raw")]
        [Consumes("text/plain", "application/json")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> ReceiveRawAlert()
        {
            try
            {
                using var reader = new StreamReader(Request.Body);
                var rawPayload = await reader.ReadToEndAsync();

                _logger.LogInformation("Received raw webhook payload from IP: {IP}", HttpContext.Connection.RemoteIpAddress);
                _logger.LogInformation("Raw payload: {Payload}", rawPayload);

                if (string.IsNullOrWhiteSpace(rawPayload))
                {
                    return BadRequest(new WebhookResponse
                    {
                        Success = false,
                        Message = "Empty payload",
                        Timestamp = DateTime.UtcNow
                    });
                }

                // Try to parse as JSON
                TradingViewAlert? alert = null;
                try
                {
                    alert = JsonSerializer.Deserialize<TradingViewAlert>(rawPayload);
                }
                catch (JsonException)
                {
                    // If not valid JSON, treat as plain text message
                    alert = new TradingViewAlert { Message = rawPayload };
                }

                if (alert != null)
                {
                    var alertId = await _webhookService.ProcessAlertAsync(alert);
                    return Ok(new WebhookResponse
                    {
                        Success = true,
                        Message = "Alert received and processed successfully",
                        Timestamp = DateTime.UtcNow,
                        AlertId = alertId
                    });
                }

                return BadRequest(new WebhookResponse
                {
                    Success = false,
                    Message = "Could not process payload",
                    Timestamp = DateTime.UtcNow
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing raw webhook alert");
                return StatusCode(500, new WebhookResponse
                {
                    Success = false,
                    Message = "Internal server error",
                    Timestamp = DateTime.UtcNow
                });
            }
        }

        /// <summary>
        /// Test endpoint to verify webhook is working
        /// </summary>
        [HttpGet("test")]
        public IActionResult Test()
        {
            _logger.LogInformation("Test endpoint called");
            return Ok(new
            {
                status = "Webhook receiver is running",
                timestamp = DateTime.UtcNow,
                endpoints = new
                {
                    receive = "/api/webhook/receive (POST)",
                    receiveRaw = "/api/webhook/receive-raw (POST)",
                    test = "/api/webhook/test (GET)"
                }
            });
        }
    }
}


