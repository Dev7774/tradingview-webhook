# TradingView Webhook Receiver

A production-ready webhook receiver for TradingView alerts built with **.NET 8 C#** and configured for **IIS hosting**.

## 🚀 Features

- ✅ Receives TradingView webhook alerts (JSON and plain text)
- ✅ Structured logging with Serilog (daily rotation)
- ✅ Alert storage to file system (easily adaptable to database)
- ✅ Swagger/OpenAPI documentation
- ✅ Health check endpoint
- ✅ IIS hosting ready with web.config
- ✅ Error handling and validation
- ✅ Extensible service architecture

## 📋 Prerequisites

- .NET 8.0 SDK (or .NET 6.0)
- Windows Server with IIS 10+ (for production)
- Visual Studio 2022 or VS Code (for development)
- .NET Hosting Bundle for IIS (for production deployment)

## 🛠️ Local Development Setup

### 1. Clone/Download the Project

```bash
cd D:\Projects\tradingview-webhook
```

### 2. Restore Dependencies

```bash
dotnet restore
```

### 3. Run Locally

```bash
dotnet run
```

The application will start at `http://localhost:5000`

### 4. Test the Webhook

**Test endpoint:**
```
GET http://localhost:5000/api/webhook/test
```

**Webhook endpoint:**
```powershell
# PowerShell
$body = @{
    ticker = "BTCUSD"
    action = "buy"
    price = 45000.50
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:5000/api/webhook/receive" `
    -Method POST `
    -Body $body `
    -ContentType "application/json"
```

**Or using curl:**
```bash
curl -X POST http://localhost:5000/api/webhook/receive \
  -H "Content-Type: application/json" \
  -d '{"ticker":"BTCUSD","action":"buy","price":45000}'
```

## 📡 TradingView Alert Configuration

### Example Alert Message (JSON Format)

In TradingView, when creating an alert, use this format in the "Message" field:

```json
{
  "ticker": "{{ticker}}",
  "action": "{{strategy.order.action}}",
  "price": {{close}},
  "time": "{{time}}",
  "exchange": "{{exchange}}",
  "strategy": "MY_STRATEGY",
  "interval": "{{interval}}",
  "volume": {{volume}}
}
```

### TradingView Webhook URL

Set your webhook URL in TradingView alert settings:

```
http://your-domain.com/api/webhook/receive
```

Or for raw text messages:

```
http://your-domain.com/api/webhook/receive-raw
```

## 🌐 IIS Deployment Guide

### Step 1: Install Prerequisites on Server

1. **Install .NET Hosting Bundle**
   - Download from: https://dotnet.microsoft.com/download/dotnet/8.0
   - Look for "Hosting Bundle" (includes runtime + IIS module)
   - Install and restart the server

2. **Verify IIS is Installed**
   ```powershell
   Get-WindowsFeature -Name Web-Server
   ```

### Step 2: Publish the Application

#### Option A: Using Visual Studio

1. Right-click on project → **Publish**
2. Choose **Folder** as target
3. Set folder path: `C:\inetpub\tradingview-webhook`
4. Click **Publish**

#### Option B: Using Command Line

```bash
dotnet publish -c Release -o C:\inetpub\tradingview-webhook
```

### Step 3: Configure IIS

#### 1. Create Application Pool

Open IIS Manager and:

1. Navigate to **Application Pools**
2. Click **Add Application Pool**
   - Name: `TradingViewWebhookPool`
   - .NET CLR version: **No Managed Code** ⚠️ IMPORTANT
   - Managed pipeline mode: **Integrated**
3. Click **OK**

#### 2. Configure Application Pool Identity

1. Right-click **TradingViewWebhookPool** → **Advanced Settings**
2. Set **Identity** to `ApplicationPoolIdentity`
3. Click **OK**

#### 3. Create Website

1. Right-click **Sites** → **Add Website**
   - Site name: `TradingViewWebhook`
   - Application pool: `TradingViewWebhookPool`
   - Physical path: `C:\inetpub\tradingview-webhook`
   - Binding:
     - Type: `http`
     - IP address: `All Unassigned`
     - Port: `80` (or your preferred port)
     - Host name: `yourdomain.com` (optional)
2. Click **OK**

### Step 4: Set Folder Permissions

The application needs write permissions for logs and alerts folders:

```powershell
# Navigate to the published folder
cd C:\inetpub\tradingview-webhook

# Grant write permissions to IIS_IUSRS
icacls . /grant "IIS_IUSRS:(OI)(CI)M" /T
```

### Step 5: Configure Firewall

Open the required port in Windows Firewall:

```powershell
New-NetFirewallRule -DisplayName "TradingView Webhook" `
    -Direction Inbound `
    -Protocol TCP `
    -LocalPort 80 `
    -Action Allow
```

**Important:** Also allow TradingView IPs:
- 52.89.214.238
- 34.212.75.30
- 54.218.53.128
- 52.32.178.7

### Step 6: Test the Deployment

1. **Test from server:**
   ```powershell
   Invoke-WebRequest -Uri "http://localhost/api/webhook/test" -Method GET
   ```

2. **Test from external:**
   ```
   http://your-domain.com/api/webhook/test
   ```

3. **Test webhook endpoint:**
   ```powershell
   $body = @{
       ticker = "BTCUSD"
       action = "buy"
       price = 45000
   } | ConvertTo-Json

   Invoke-WebRequest -Uri "http://localhost/api/webhook/receive" `
       -Method POST `
       -Body $body `
       -ContentType "application/json"
   ```

### Step 7: Monitor Logs

Logs are stored in:
- Application logs: `C:\inetpub\tradingview-webhook\logs\`
- IIS stdout logs: `C:\inetpub\tradingview-webhook\logs\stdout`

View recent logs:
```powershell
Get-Content "C:\inetpub\tradingview-webhook\logs\tradingview-webhook-*.txt" -Tail 50
```

## 📊 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check endpoint |
| GET | `/api/webhook/test` | Test endpoint to verify service |
| POST | `/api/webhook/receive` | Main webhook receiver (JSON) |
| POST | `/api/webhook/receive-raw` | Raw payload receiver (text/JSON) |
| GET | `/swagger` | API documentation (dev only) |

## 🔧 Customization

### Modify Alert Processing Logic

Edit `Services/WebhookService.cs` in the `ProcessAlertLogic` method:

```csharp
private async Task ProcessAlertLogic(TradingViewAlert alert)
{
    switch (alert.Action?.ToLower())
    {
        case "buy":
            // Add your buy logic here
            // e.g., call broker API, send notification, etc.
            await SendEmailNotification(alert);
            await PlaceBuyOrder(alert);
            break;
        
        case "sell":
            // Add your sell logic here
            await PlaceSellOrder(alert);
            break;
    }
}
```

### Store Alerts in Database

Replace file storage in `WebhookService.cs` with your database logic:

1. Add Entity Framework Core
2. Create DbContext and Alert entity
3. Replace `SaveAlertToFileAsync` with database insert

### Add Authentication

To secure your webhook, add authentication in `Program.cs`:

```csharp
// Add API key authentication
builder.Services.AddAuthentication("ApiKey")
    .AddScheme<ApiKeyAuthenticationOptions, ApiKeyAuthenticationHandler>("ApiKey", null);
```

## 🧪 Testing

### Automated Test Script

Use the included PowerShell test script:

```powershell
.\test-webhook.ps1
```

Or test against a specific URL:

```powershell
.\test-webhook.ps1 -BaseUrl "http://your-domain.com"
```

### Manual Testing

```powershell
# Health check
Invoke-WebRequest -Uri "http://localhost:5000/health"

# Test endpoint
Invoke-WebRequest -Uri "http://localhost:5000/api/webhook/test"

# Send test alert
$body = @{
    ticker = "BTCUSD"
    action = "buy"
    price = 45000.50
    time = (Get-Date).ToString("o")
    exchange = "BINANCE"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:5000/api/webhook/receive" `
    -Method POST `
    -Body $body `
    -ContentType "application/json"
```

## 🐛 Troubleshooting

### Issue: 404 Not Found

**Solution:** Verify the application pool is running and web.config is present.

```powershell
# Check application pool status
Get-IISAppPool -Name "TradingViewWebhookPool"

# Start if stopped
Start-IISAppPool -Name "TradingViewWebhookPool"
```

### Issue: 500 Internal Server Error

**Solution:** Check logs in `logs\` folder and enable detailed errors temporarily:

In `web.config`, ensure:
```xml
<httpErrors errorMode="Detailed" />
```

### Issue: Permissions Error

**Solution:** Grant proper permissions:

```powershell
icacls "C:\inetpub\tradingview-webhook" /grant "IIS_IUSRS:(OI)(CI)M" /T
```

### Issue: Webhook Not Receiving Alerts

**Solution:** 
1. Check firewall allows port 80/443
2. Verify TradingView IPs are not blocked
3. Test locally first with Postman/curl
4. Check IIS logs and application logs

## 📝 Example TradingView Alert Messages

### Simple Text Alert
```
BUY signal triggered for BTCUSD at 45000
```

### JSON Alert with All Fields
```json
{
  "ticker": "{{ticker}}",
  "action": "{{strategy.order.action}}",
  "price": {{close}},
  "time": "{{time}}",
  "exchange": "{{exchange}}",
  "interval": "{{interval}}",
  "volume": {{volume}},
  "message": "Custom message here"
}
```

### Strategy-Based Alert
```json
{
  "strategy": "RSI_DIVERGENCE",
  "ticker": "{{ticker}}",
  "action": "long",
  "price": {{close}},
  "time": "{{timenow}}"
}
```

## 📚 Resources

- [TradingView Webhooks Documentation](https://www.tradingview.com/support/folders/43000560150-webhooks-usage/)
- [ASP.NET Core Documentation](https://docs.microsoft.com/aspnet/core)
- [IIS Hosting Documentation](https://docs.microsoft.com/aspnet/core/host-and-deploy/iis)

## 📄 License

This project is open source and available for personal and commercial use.

## 🤝 Support

For issues or questions:
1. Check the logs in `logs/` folder
2. Review the Troubleshooting section above
3. Check TradingView webhook documentation

## 🎯 Project Structure

```
tradingview-webhook/
├── Controllers/
│   └── WebhookController.cs      # API endpoints
├── Models/
│   └── TradingViewAlert.cs       # Data models
├── Services/
│   ├── IWebhookService.cs        # Service interface
│   └── WebhookService.cs         # Business logic
├── Program.cs                    # Application entry point
├── appsettings.json              # Configuration
├── web.config                    # IIS configuration
├── setup-iis.ps1                # Automated IIS setup
└── test-webhook.ps1              # Test script
```

## 🚀 Quick Commands

```powershell
# Run locally
dotnet run

# Build project
dotnet build

# Publish for IIS
dotnet publish -c Release -o C:\inetpub\tradingview-webhook

# Test webhook
.\test-webhook.ps1

# Deploy to IIS (as Administrator)
.\setup-iis.ps1

# View logs
Get-Content logs\tradingview-webhook-*.txt -Tail 50 -Wait

# Check IIS status
Get-Website -Name "TradingViewWebhook"
Restart-WebAppPool -Name "TradingViewWebhookPool"
```

---

**Made with ❤️ for TradingView automation**

