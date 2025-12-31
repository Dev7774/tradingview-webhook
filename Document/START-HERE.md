# 🚀 START HERE - TradingView Webhook Receiver

Welcome! This is a complete, production-ready TradingView webhook receiver built with .NET 8 C# and ready for IIS hosting.

## ✅ What You Have

A fully functional webhook receiver that:
- ✅ Receives TradingView alerts via HTTP POST
- ✅ Supports JSON and plain text payloads
- ✅ Logs all alerts with Serilog
- ✅ Saves alerts to file system (easily adaptable to database)
- ✅ Includes comprehensive error handling
- ✅ Ready for IIS deployment
- ✅ Includes test scripts and documentation

## 📚 Documentation Guide

Choose your path based on your needs:

### 🏃 Quick Start (5-15 minutes)
**File:** [`QUICKSTART.md`](QUICKSTART.md)
- Test locally in 5 minutes
- Deploy to IIS in 15 minutes
- Configure TradingView alerts

### 📖 Complete Guide
**File:** [`README.md`](README.md)
- Full feature overview
- Detailed setup instructions
- API documentation
- Customization guide
- Troubleshooting

### 🖥️ IIS Deployment (Detailed)
**File:** [`IIS-DEPLOYMENT-GUIDE.md`](IIS-DEPLOYMENT-GUIDE.md)
- Step-by-step IIS setup
- SSL/HTTPS configuration
- Security best practices
- Monitoring and maintenance
- PowerShell automation

### 📊 TradingView Examples
**File:** [`EXAMPLES.md`](EXAMPLES.md)
- 10+ alert templates
- JSON payload examples
- Testing examples
- TradingView variables reference

### 🏗️ Project Structure
**File:** [`PROJECT-STRUCTURE.md`](PROJECT-STRUCTURE.md)
- File organization
- Architecture overview
- Customization points

## 🎯 Choose Your Path

### Path 1: Test Locally First (Recommended)

1. **Run the application:**
   ```powershell
   dotnet run
   ```

2. **Test the webhook:**
   ```powershell
   .\test-webhook.ps1
   ```

3. **Check the logs:**
   ```powershell
   Get-Content logs\tradingview-webhook-*.txt
   ```

4. **View saved alerts:**
   ```powershell
   dir alerts\*.json
   ```

### Path 2: Deploy to IIS Immediately

1. **Run automated setup (as Administrator):**
   ```powershell
   .\setup-iis.ps1
   ```

2. **Test the deployment:**
   ```powershell
   .\test-webhook.ps1 -BaseUrl "http://localhost"
   ```

3. **Configure TradingView:**
   - Webhook URL: `http://your-domain.com/api/webhook/receive`

### Path 3: Manual IIS Setup

Follow the detailed guide in [`IIS-DEPLOYMENT-GUIDE.md`](IIS-DEPLOYMENT-GUIDE.md)

## 🔗 Key Endpoints

Once running, you'll have these endpoints:

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/health` | GET | Health check |
| `/api/webhook/test` | GET | Test webhook is working |
| `/api/webhook/receive` | POST | Main webhook (JSON) |
| `/api/webhook/receive-raw` | POST | Raw payload (text/JSON) |
| `/swagger` | GET | API docs (dev only) |

## 📝 TradingView Configuration

### Step 1: Create Alert in TradingView

1. Go to [TradingView.com](https://www.tradingview.com)
2. Open any chart
3. Click Alert button (⏰)

### Step 2: Configure Webhook

- ✅ Enable "Webhook URL"
- **URL:** `http://your-domain.com/api/webhook/receive`

### Step 3: Set Alert Message (JSON)

```json
{
  "ticker": "{{ticker}}",
  "action": "buy",
  "price": {{close}},
  "time": "{{time}}",
  "exchange": "{{exchange}}"
}
```

See [`EXAMPLES.md`](EXAMPLES.md) for more templates!

## 🛠️ Customization

### Add Your Trading Logic

Edit `Services/WebhookService.cs`:

```csharp
private async Task ProcessAlertLogic(TradingViewAlert alert)
{
    switch (alert.Action?.ToLower())
    {
        case "buy":
            // TODO: Add your buy logic here
            // - Send email/SMS notification
            // - Place order via broker API
            // - Update database
            // - Send Discord/Telegram message
            break;
        
        case "sell":
            // TODO: Add your sell logic here
            break;
    }
}
```

### Common Customizations

1. **Database Storage**: Replace file storage with SQL Server/PostgreSQL
2. **Email Notifications**: Add SMTP email alerts
3. **Broker Integration**: Connect to Alpaca, Interactive Brokers, etc.
4. **Discord/Telegram**: Send notifications to chat
5. **Authentication**: Add API key validation
6. **SSL/HTTPS**: Configure SSL certificate

## 🧪 Testing

### Local Testing

```powershell
# Run all tests
.\test-webhook.ps1

# Test specific endpoint
curl http://localhost:5000/api/webhook/test
```

### IIS Testing

```powershell
# Run tests against IIS
.\test-webhook.ps1 -BaseUrl "http://localhost"

# Check logs
Get-Content C:\inetpub\tradingview-webhook\logs\tradingview-webhook-*.txt -Tail 50
```

### TradingView Testing

1. Create a test alert in TradingView
2. Trigger it manually
3. Check your logs for the received alert

## 📊 Monitoring

### View Live Logs

```powershell
# Watch logs in real-time
Get-Content logs\tradingview-webhook-*.txt -Tail 50 -Wait
```

### Check Received Alerts

```powershell
# List all alerts
dir alerts\*.json | Sort-Object LastWriteTime -Descending

# View latest alert
Get-Content (Get-ChildItem alerts\*.json | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName
```

### IIS Management

```powershell
# Check status
Get-Website -Name "TradingViewWebhook"

# Restart
Restart-WebAppPool -Name "TradingViewWebhookPool"
```

## 🆘 Troubleshooting

### Issue: Cannot run locally

**Solution:**
```powershell
# Check .NET is installed
dotnet --version

# Restore packages
dotnet restore

# Run
dotnet run
```

### Issue: IIS shows 502 error

**Solution:**
1. Install .NET Hosting Bundle: https://dotnet.microsoft.com/download/dotnet/8.0
2. Restart IIS: `iisreset`

### Issue: Cannot access from external network

**Solution:**
```powershell
# Check firewall
Test-NetConnection -ComputerName localhost -Port 80

# Add firewall rule
New-NetFirewallRule -DisplayName "TradingView Webhook" -Direction Inbound -Protocol TCP -LocalPort 80 -Action Allow
```

### Issue: Logs not being created

**Solution:**
```powershell
# Create folders manually
mkdir logs
mkdir alerts

# Set permissions (IIS only)
icacls logs /grant "IIS_IUSRS:(OI)(CI)M"
icacls alerts /grant "IIS_IUSRS:(OI)(CI)M"
```

## 📞 Getting Help

1. **Check logs first**: `logs/tradingview-webhook-*.txt`
2. **Review documentation**: See files listed above
3. **Test endpoints**: Use `test-webhook.ps1`
4. **Check IIS logs**: `C:\inetpub\logs\LogFiles\`

## 🎓 Learning Resources

- [TradingView Webhooks Documentation](https://www.tradingview.com/support/folders/43000560150-webhooks-usage/)
- [ASP.NET Core Documentation](https://docs.microsoft.com/aspnet/core)
- [IIS Hosting Guide](https://docs.microsoft.com/aspnet/core/host-and-deploy/iis)

## ✅ Verification Checklist

Before going live, verify:

- [ ] Application builds successfully (`dotnet build`)
- [ ] Local tests pass (`.\test-webhook.ps1`)
- [ ] IIS deployment successful
- [ ] Health endpoint accessible
- [ ] Test alert received from TradingView
- [ ] Logs being written
- [ ] Alerts being saved
- [ ] Firewall configured
- [ ] SSL certificate installed (production)
- [ ] Custom logic implemented

## 🚀 Next Steps

1. ✅ **You are here** - Understanding the project
2. 📖 Read [`QUICKSTART.md`](QUICKSTART.md) for immediate setup
3. 🧪 Test locally with `dotnet run`
4. 🖥️ Deploy to IIS using [`setup-iis.ps1`](setup-iis.ps1)
5. 📡 Configure TradingView alerts
6. 🛠️ Customize `WebhookService.cs` for your needs
7. 🔒 Add security (SSL, authentication)
8. 📊 Monitor and optimize

## 📦 What's Included

```
📁 tradingview-webhook/
├── 📄 START-HERE.md (You are here!)
├── 📄 QUICKSTART.md (5-minute guide)
├── 📄 README.md (Complete documentation)
├── 📄 IIS-DEPLOYMENT-GUIDE.md (Detailed IIS setup)
├── 📄 EXAMPLES.md (TradingView alert templates)
├── 📄 PROJECT-STRUCTURE.md (Architecture)
│
├── 🔧 setup-iis.ps1 (Automated IIS setup)
├── 🧪 test-webhook.ps1 (Test script - Windows)
├── 🧪 test-webhook.sh (Test script - Linux/Mac)
│
├── 📝 Program.cs (Application entry point)
├── ⚙️ appsettings.json (Configuration)
├── 🌐 web.config (IIS configuration)
│
├── 📂 Controllers/
│   └── WebhookController.cs (API endpoints)
├── 📂 Models/
│   └── TradingViewAlert.cs (Data models)
├── 📂 Services/
│   ├── IWebhookService.cs (Interface)
│   └── WebhookService.cs (Business logic - CUSTOMIZE THIS!)
│
├── 📂 logs/ (Auto-created - application logs)
└── 📂 alerts/ (Auto-created - saved alerts)
```

## 🎉 You're Ready!

Everything is set up and ready to go. Choose your path above and start receiving TradingView alerts!

**Recommended first step:** Open [`QUICKSTART.md`](QUICKSTART.md) and follow the 5-minute local testing guide.

---

**Happy Trading! 📈🚀**

*Built with .NET 8, ASP.NET Core, and ❤️*

