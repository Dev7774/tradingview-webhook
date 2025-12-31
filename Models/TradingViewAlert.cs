using System.Text.Json.Serialization;

namespace TradingViewWebhook.Models
{
    /// <summary>
    /// Represents a TradingView webhook alert payload
    /// You can customize this class based on your alert message format
    /// </summary>
    public class TradingViewAlert
    {
        [JsonPropertyName("ticker")]
        public string? Ticker { get; set; }

        [JsonPropertyName("action")]
        public string? Action { get; set; }

        [JsonPropertyName("price")]
        public decimal? Price { get; set; }

        [JsonPropertyName("time")]
        public string? Time { get; set; }

        [JsonPropertyName("exchange")]
        public string? Exchange { get; set; }

        [JsonPropertyName("strategy")]
        public string? Strategy { get; set; }

        [JsonPropertyName("interval")]
        public string? Interval { get; set; }

        [JsonPropertyName("volume")]
        public decimal? Volume { get; set; }

        [JsonPropertyName("message")]
        public string? Message { get; set; }

        // You can add any custom fields here based on your TradingView alert configuration
        [JsonExtensionData]
        public Dictionary<string, object>? AdditionalData { get; set; }

        public override string ToString()
        {
            return $"Ticker: {Ticker}, Action: {Action}, Price: {Price}, Time: {Time}, Exchange: {Exchange}, Strategy: {Strategy}";
        }
    }

    /// <summary>
    /// Response model for webhook endpoint
    /// </summary>
    public class WebhookResponse
    {
        public bool Success { get; set; }
        public string? Message { get; set; }
        public DateTime Timestamp { get; set; }
        public string? AlertId { get; set; }
    }
}


