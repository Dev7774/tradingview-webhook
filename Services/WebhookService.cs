using TradingViewWebhook.Models;
using System.Text.Json;

namespace TradingViewWebhook.Services
{
    public class WebhookService : IWebhookService
    {
        private readonly ILogger<WebhookService> _logger;
        private readonly string _alertsDirectory;

        public WebhookService(ILogger<WebhookService> logger, IConfiguration configuration)
        {
            _logger = logger;
            
            // Store alerts in a directory (you can change this to database storage)
            _alertsDirectory = configuration.GetValue<string>("AlertsDirectory") ?? "alerts";
            
            // Create directory if it doesn't exist
            if (!Directory.Exists(_alertsDirectory))
            {
                Directory.CreateDirectory(_alertsDirectory);
            }
        }

        public async Task<string> ProcessAlertAsync(TradingViewAlert alert)
        {
            try
            {
                // Generate a unique alert ID
                var alertId = Guid.NewGuid().ToString();
                
                _logger.LogInformation("Processing alert with ID: {AlertId}", alertId);

                // Log the alert details
                _logger.LogInformation("Alert Details - Ticker: {Ticker}, Action: {Action}, Price: {Price}, Time: {Time}", 
                    alert.Ticker, alert.Action, alert.Price, alert.Time);

                // Save alert to file (you can replace this with database storage)
                await SaveAlertToFileAsync(alertId, alert);

                // HERE YOU CAN ADD YOUR CUSTOM LOGIC:
                // - Send email notifications
                // - Execute trades through broker API
                // - Send Discord/Telegram notifications
                // - Store in database
                // - Trigger other webhooks
                // - etc.

                await ProcessAlertLogic(alert);

                _logger.LogInformation("Alert {AlertId} processed successfully", alertId);

                return alertId;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing alert");
                throw;
            }
        }

        private async Task SaveAlertToFileAsync(string alertId, TradingViewAlert alert)
        {
            try
            {
                var fileName = $"{DateTime.UtcNow:yyyyMMdd-HHmmss}_{alertId}.json";
                var filePath = Path.Combine(_alertsDirectory, fileName);

                var alertData = new
                {
                    Id = alertId,
                    ReceivedAt = DateTime.UtcNow,
                    Alert = alert
                };

                var json = JsonSerializer.Serialize(alertData, new JsonSerializerOptions 
                { 
                    WriteIndented = true 
                });

                await File.WriteAllTextAsync(filePath, json);
                
                _logger.LogInformation("Alert saved to file: {FilePath}", filePath);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error saving alert to file");
            }
        }

        private async Task ProcessAlertLogic(TradingViewAlert alert)
        {
            // Add your custom logic here based on the alert action
            if (alert.Action != null)
            {
                switch (alert.Action.ToLower())
                {
                    case "buy":
                        _logger.LogInformation("BUY signal received for {Ticker} at {Price}", alert.Ticker, alert.Price);
                        // TODO: Implement buy logic
                        break;

                    case "sell":
                        _logger.LogInformation("SELL signal received for {Ticker} at {Price}", alert.Ticker, alert.Price);
                        // TODO: Implement sell logic
                        break;

                    case "long":
                        _logger.LogInformation("LONG signal received for {Ticker} at {Price}", alert.Ticker, alert.Price);
                        // TODO: Implement long position logic
                        break;

                    case "short":
                        _logger.LogInformation("SHORT signal received for {Ticker} at {Price}", alert.Ticker, alert.Price);
                        // TODO: Implement short position logic
                        break;

                    case "close":
                        _logger.LogInformation("CLOSE signal received for {Ticker}", alert.Ticker);
                        // TODO: Implement close position logic
                        break;

                    default:
                        _logger.LogWarning("Unknown action: {Action}", alert.Action);
                        break;
                }
            }

            // Simulate async processing
            await Task.CompletedTask;
        }
    }
}


