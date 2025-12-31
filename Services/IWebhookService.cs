using TradingViewWebhook.Models;

namespace TradingViewWebhook.Services
{
    public interface IWebhookService
    {
        Task<string> ProcessAlertAsync(TradingViewAlert alert);
    }
}

