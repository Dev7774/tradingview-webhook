# Quick Start Guide

Get your TradingView webhook receiver up and running in 5 minutes!

## 🚀 Local Testing (5 Minutes)

### Step 1: Run the Application

```bash
cd D:\Projects\tradingview-webhook
dotnet restore
dotnet run
```

You should see:
```
info: TradingView Webhook Receiver started
Now listening on: http://localhost:5000
```

### Step 2: Test the Webhook

Open a new terminal and test:

```bash
# Test health endpoint
curl http://localhost:5000/health

# Test webhook endpoint
curl http://localhost:5000/api/webhook/test

# Send a test alert
curl -X POST http://localhost:5000/api/webhook/receive ^
  -H "Content-Type: application/json" ^
  -d "{\"ticker\":\"BTCUSD\",\"action\":\"buy\",\"price\":45000}"
```

### Step 3: View the Logs

Check the `logs` and `alerts` folders that were created:

```bash
# View application logs
type logs\tradingview-webhook-*.txt

# View saved alerts
dir alerts
type alerts\*.json
```

✅ **Success!** Your webhook is working locally!

---

## 🌐 IIS Deployment (15 Minutes)

### Step 1: Install Prerequisites

Download and install .NET 8.0 Hosting Bundle:
- **URL:** https://dotnet.microsoft.com/download/dotnet/8.0
- Look for "**Hosting Bundle**"
- After install: `iisreset`

### Step 2: Publish

```powershell
dotnet publish -c Release -o C:\inetpub\tradingview-webhook
```

### Step 3: Create IIS Site

```powershell
# Create Application Pool
New-WebAppPool -Name "TradingViewWebhookPool"
Set-ItemProperty IIS:\AppPools\TradingViewWebhookPool -Name managedRuntimeVersion -Value ""

# Create Website
New-Website -Name "TradingViewWebhook" `
    -ApplicationPool "TradingViewWebhookPool" `
    -PhysicalPath "C:\inetpub\tradingview-webhook" `
    -Port 80

# Set Permissions
cd C:\inetpub\tradingview-webhook
icacls . /grant "IIS_IUSRS:(OI)(CI)M" /T

# Start Website
Start-Website -Name "TradingViewWebhook"
```

### Step 4: Configure Firewall

```powershell
New-NetFirewallRule -DisplayName "TradingView Webhook" `
    -Direction Inbound -Protocol TCP -LocalPort 80 -Action Allow
```

### Step 5: Test

```powershell
# Test locally
Invoke-WebRequest -Uri "http://localhost/api/webhook/test"

# Test externally (replace with your domain/IP)
Invoke-WebRequest -Uri "http://your-domain.com/api/webhook/test"
```

✅ **Success!** Your webhook is live on IIS!

---

## 📡 Configure TradingView

### Step 1: Create an Alert

1. Go to [TradingView.com](https://www.tradingview.com)
2. Open any chart
3. Click the **Alert** button (⏰)

### Step 2: Set Webhook URL

In the alert dialog:
- ✅ Enable "Webhook URL"
- **URL:** `http://your-domain.com/api/webhook/receive`

### Step 3: Set Alert Message

Use JSON format:

```json
{
  "ticker": "{{ticker}}",
  "action": "buy",
  "price": {{close}},
  "time": "{{time}}",
  "exchange": "{{exchange}}"
}
```

### Step 4: Save & Test

1. Click **Create**
2. Manually trigger the alert
3. Check your logs:

```powershell
Get-Content "C:\inetpub\tradingview-webhook\logs\tradingview-webhook-*.txt" -Tail 20
```

You should see:
```
[INF] Received webhook request from IP: 52.89.214.238
[INF] Processing TradingView Alert: Ticker: BTCUSD, Action: buy, Price: 45000
[INF] Alert processed successfully
```

✅ **Success!** TradingView is sending alerts to your webhook!

---

## 🛠️ Customize Alert Processing

Edit `Services/WebhookService.cs`:

```csharp
private async Task ProcessAlertLogic(TradingViewAlert alert)
{
    switch (alert.Action?.ToLower())
    {
        case "buy":
            // Add your buy logic here
            await SendEmailNotification(alert);
            await PlaceBuyOrder(alert);
            break;
        
        case "sell":
            // Add your sell logic here
            await PlaceSellOrder(alert);
            break;
    }
}

private async Task SendEmailNotification(TradingViewAlert alert)
{
    // TODO: Implement email notification
    _logger.LogInformation("Sending email for {Action} on {Ticker}", 
        alert.Action, alert.Ticker);
}

private async Task PlaceBuyOrder(TradingViewAlert alert)
{
    // TODO: Integrate with your broker API
    _logger.LogInformation("Placing BUY order for {Ticker} at {Price}", 
        alert.Ticker, alert.Price);
}
```

---

## 📊 Monitor Your Webhook

### View Live Logs

```powershell
# Watch logs in real-time
Get-Content "C:\inetpub\tradingview-webhook\logs\tradingview-webhook-*.txt" -Tail 50 -Wait
```

### Check Received Alerts

```powershell
# List all received alerts
dir C:\inetpub\tradingview-webhook\alerts\*.json | Sort-Object LastWriteTime -Descending

# View latest alert
Get-Content (Get-ChildItem C:\inetpub\tradingview-webhook\alerts\*.json | 
    Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName
```

### Check IIS Status

```powershell
# Check website status
Get-Website -Name "TradingViewWebhook"

# Check application pool
Get-WebAppPoolState -Name "TradingViewWebhookPool"

# Restart if needed
Restart-WebAppPool -Name "TradingViewWebhookPool"
```

---

## 🎯 Next Steps

1. **Add Security:** Implement API key authentication
2. **Add Database:** Store alerts in SQL Server or SQLite
3. **Add Notifications:** Send Discord/Telegram messages
4. **Integrate Broker:** Connect to your broker's API
5. **Add SSL:** Configure HTTPS with SSL certificate
6. **Add Monitoring:** Setup health checks and alerting

See the full documentation in:
- `README.md` - Complete guide
- `IIS-DEPLOYMENT-GUIDE.md` - Detailed IIS setup
- `EXAMPLES.md` - TradingView alert examples

---

## 🆘 Troubleshooting

### Local Development Issues

**Port already in use:**
```bash
# Change port in appsettings.json or use:
dotnet run --urls "http://localhost:5001"
```

**Cannot write to logs:**
```bash
# Run as administrator or create folders manually
mkdir logs
mkdir alerts
```

### IIS Issues

**HTTP 502.5 Error:**
```powershell
# Reinstall .NET Hosting Bundle and restart
iisreset
```

**Cannot access from external network:**
```powershell
# Check firewall
Test-NetConnection -ComputerName localhost -Port 80

# Check website binding
Get-WebBinding -Name "TradingViewWebhook"
```

**Permissions error:**
```powershell
cd C:\inetpub\tradingview-webhook
icacls . /grant "IIS_IUSRS:(OI)(CI)M" /T
Restart-WebAppPool -Name "TradingViewWebhookPool"
```

---

## 📞 Need Help?

1. Check logs: `logs/tradingview-webhook-*.txt`
2. Review `README.md` for detailed documentation
3. Check `IIS-DEPLOYMENT-GUIDE.md` for deployment issues
4. Test with curl/PowerShell to isolate issues

---

**You're all set! Happy trading! 🎉📈**

