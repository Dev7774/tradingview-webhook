# Project Structure

## 📁 Directory Layout

```
tradingview-webhook/
│
├── Controllers/
│   └── WebhookController.cs          # Main webhook endpoints
│
├── Models/
│   └── TradingViewAlert.cs           # Alert data models
│
├── Services/
│   ├── IWebhookService.cs            # Service interface
│   └── WebhookService.cs             # Alert processing logic
│
├── Properties/
│   └── launchSettings.json           # Launch configuration
│
├── logs/                             # Application logs (auto-created)
│   └── tradingview-webhook-*.txt
│
├── alerts/                           # Saved alerts (auto-created)
│   └── *.json
│
├── Program.cs                        # Application entry point
├── appsettings.json                  # Application configuration
├── appsettings.Development.json      # Development settings
├── web.config                        # IIS configuration
├── TradingViewWebhook.csproj        # Project file
│
├── README.md                         # Main documentation
├── IIS-DEPLOYMENT-GUIDE.md          # Detailed IIS setup guide
├── QUICKSTART.md                     # Quick start guide
├── EXAMPLES.md                       # TradingView alert examples
├── PROJECT-STRUCTURE.md              # This file
│
├── test-webhook.ps1                  # PowerShell test script
├── test-webhook.sh                   # Bash test script (Linux/Mac)
│
└── .gitignore                        # Git ignore rules
```

## 📄 File Descriptions

### Core Application Files

#### `Program.cs`
- Application entry point
- Configures services and middleware
- Sets up Serilog logging
- Configures IIS integration
- Defines health check endpoint

#### `Controllers/WebhookController.cs`
- **Main webhook endpoint:** `POST /api/webhook/receive`
- **Raw payload endpoint:** `POST /api/webhook/receive-raw`
- **Test endpoint:** `GET /api/webhook/test`
- Handles JSON and plain text payloads
- Error handling and validation
- Request logging

#### `Models/TradingViewAlert.cs`
- `TradingViewAlert`: Main alert model with common fields
- `WebhookResponse`: API response model
- Supports custom fields via `JsonExtensionData`
- Matches TradingView webhook payload format

#### `Services/WebhookService.cs`
- Alert processing business logic
- File-based alert storage (easily adaptable to database)
- Action-based routing (buy/sell/long/short/close)
- Extensible for custom integrations

#### `Services/IWebhookService.cs`
- Service contract interface
- Dependency injection support

### Configuration Files

#### `appsettings.json`
- Logging configuration
- Application settings
- Kestrel endpoint configuration
- AlertsDirectory path

#### `appsettings.Development.json`
- Development-specific settings
- Enhanced logging for debugging

#### `web.config`
- IIS hosting configuration
- ASP.NET Core Module settings
- Request limits and security headers
- Stdout logging location

#### `TradingViewWebhook.csproj`
- .NET 8.0 target framework
- NuGet package references:
  - Swashbuckle (Swagger/OpenAPI)
  - Serilog (Logging)

#### `Properties/launchSettings.json`
- Development launch profiles
- IIS Express settings
- Environment variables

### Documentation Files

#### `README.md` (Main Documentation)
- Complete feature overview
- Local development setup
- TradingView configuration
- IIS deployment guide
- API endpoints reference
- Customization guide
- Troubleshooting section

#### `IIS-DEPLOYMENT-GUIDE.md` (Detailed IIS Guide)
- Step-by-step IIS setup
- Application pool configuration
- Website creation
- Security and firewall setup
- SSL/HTTPS configuration
- Monitoring and maintenance
- Troubleshooting common issues
- PowerShell automation scripts

#### `QUICKSTART.md` (Fast Start)
- 5-minute local testing guide
- 15-minute IIS deployment
- TradingView configuration
- Basic customization
- Quick troubleshooting

#### `EXAMPLES.md` (Alert Examples)
- 10+ TradingView alert templates
- JSON payload examples
- Testing with curl/PowerShell
- TradingView variable reference
- Best practices and tips

#### `PROJECT-STRUCTURE.md` (This File)
- Project organization
- File descriptions
- Architecture overview

### Test Scripts

#### `test-webhook.ps1` (PowerShell)
- Automated test suite for Windows
- Tests all endpoints
- Error handling verification
- Color-coded output
- Usage: `.\test-webhook.ps1 -BaseUrl "http://localhost:5000"`

#### `test-webhook.sh` (Bash)
- Automated test suite for Linux/Mac
- Same tests as PowerShell version
- Usage: `./test-webhook.sh http://localhost:5000`

### Runtime Folders

#### `logs/` (Auto-created)
- Application logs from Serilog
- File pattern: `tradingview-webhook-YYYYMMDD.txt`
- Daily rotation
- IIS stdout logs: `stdout-*.log`

#### `alerts/` (Auto-created)
- Saved webhook alerts in JSON format
- File pattern: `YYYYMMDD-HHmmss_[GUID].json`
- Each file contains alert details and metadata

### Git Files

#### `.gitignore`
- Excludes build artifacts
- Ignores logs and alerts
- Excludes user-specific files
- Production configuration protection

## 🏗️ Architecture

### Layered Architecture

```
┌─────────────────────────────────────┐
│        TradingView Alerts           │
└─────────────┬───────────────────────┘
              │ HTTPS/HTTP
              ▼
┌─────────────────────────────────────┐
│      WebhookController              │
│  - Receives POST requests           │
│  - Validates JSON payload           │
│  - Error handling                   │
└─────────────┬───────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│      WebhookService                 │
│  - Processes alerts                 │
│  - Saves to file/database           │
│  - Executes business logic          │
│  - Integrates with external APIs    │
└─────────────┬───────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│    Storage / External Services      │
│  - File system                      │
│  - Database                         │
│  - Email / Notifications            │
│  - Broker APIs                      │
└─────────────────────────────────────┘
```

### Request Flow

1. **TradingView** sends HTTP POST to webhook URL
2. **IIS** receives request and forwards to ASP.NET Core
3. **WebhookController** validates and deserializes JSON
4. **WebhookService** processes the alert:
   - Generates unique alert ID
   - Logs alert details
   - Saves to file system
   - Executes custom logic (buy/sell/etc.)
5. **Response** sent back to TradingView (200 OK)
6. **Logging** records all activity

### Dependency Injection

```csharp
Services:
├── IWebhookService → WebhookService (Singleton)
├── ILogger<T> → Serilog (Built-in)
└── IConfiguration → appsettings.json (Built-in)
```

## 🔧 Customization Points

### Add Database Storage

Edit `Services/WebhookService.cs`:

```csharp
// Add Entity Framework Core
// Replace SaveAlertToFileAsync with database insert
private async Task SaveAlertToDatabaseAsync(string alertId, TradingViewAlert alert)
{
    using var context = new WebhookDbContext();
    context.Alerts.Add(new AlertEntity 
    { 
        Id = alertId,
        Ticker = alert.Ticker,
        Action = alert.Action,
        Price = alert.Price,
        ReceivedAt = DateTime.UtcNow
    });
    await context.SaveChangesAsync();
}
```

### Add Email Notifications

```csharp
// Install: MailKit or SendGrid
private async Task SendEmailNotification(TradingViewAlert alert)
{
    var message = new MimeMessage();
    message.From.Add(new MailboxAddress("Webhook", "webhook@example.com"));
    message.To.Add(new MailboxAddress("Trader", "trader@example.com"));
    message.Subject = $"TradingView Alert: {alert.Action} {alert.Ticker}";
    message.Body = new TextPart("html") 
    { 
        Text = $"<h2>{alert.Action} signal for {alert.Ticker}</h2><p>Price: {alert.Price}</p>" 
    };
    
    using var client = new SmtpClient();
    await client.ConnectAsync("smtp.example.com", 587, false);
    await client.AuthenticateAsync("username", "password");
    await client.SendAsync(message);
    await client.DisconnectAsync(true);
}
```

### Add Authentication

In `Program.cs`:

```csharp
builder.Services.AddAuthentication("ApiKey")
    .AddScheme<ApiKeyAuthenticationOptions, ApiKeyAuthenticationHandler>("ApiKey", null);

app.UseAuthentication();
app.UseAuthorization();
```

Add `[Authorize]` attribute to controller:

```csharp
[Authorize(AuthenticationSchemes = "ApiKey")]
[HttpPost("receive")]
public async Task<IActionResult> ReceiveAlert([FromBody] TradingViewAlert? alert)
```

### Add Broker Integration

```csharp
private async Task PlaceBuyOrder(TradingViewAlert alert)
{
    // Example: Alpaca API
    var alpaca = new AlpacaTradingClient(apiKey, secretKey);
    await alpaca.PostOrderAsync(new NewOrderRequest(
        symbol: alert.Ticker,
        quantity: 1,
        side: OrderSide.Buy,
        type: OrderType.Market,
        timeInForce: TimeInForce.Day
    ));
}
```

## 🚀 Deployment Targets

### Local Development
- Kestrel web server
- Port 5000 (default)
- Swagger UI enabled
- Development logging

### IIS (Windows Server)
- ASP.NET Core Module V2
- InProcess hosting model
- Application pool isolation
- Production logging

### Docker (Optional)
```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY publish/ .
EXPOSE 80
ENTRYPOINT ["dotnet", "TradingViewWebhook.dll"]
```

### Azure App Service
- Deploy via Visual Studio
- Configure application settings
- Use Azure SQL Database
- Enable Application Insights

### AWS Elastic Beanstalk
- Deploy .NET application
- Configure environment
- Use RDS for database
- CloudWatch for logging

## 📊 Monitoring

### Application Logs
- Location: `logs/tradingview-webhook-*.txt`
- Format: Structured JSON-like format
- Rotation: Daily
- Retention: Configure in `Program.cs`

### IIS Logs
- Location: `C:\inetpub\logs\LogFiles\`
- Format: W3C Extended Log Format
- Includes HTTP requests and responses

### Windows Event Logs
- Source: IIS AspNetCore Module
- Log: Application
- Contains startup errors and crashes

### Health Monitoring
- Endpoint: `GET /health`
- Returns: `{ "status": "healthy", "timestamp": "..." }`
- Use for uptime monitoring tools

## 🔒 Security Considerations

1. **IP Whitelisting**: Restrict to TradingView IPs
2. **HTTPS**: Use SSL certificate for encryption
3. **Authentication**: Add API key validation
4. **Rate Limiting**: Prevent abuse
5. **Input Validation**: Validate all alert fields
6. **Error Handling**: Don't expose sensitive details
7. **Logging**: Don't log sensitive data

## 📚 Technologies Used

- **.NET 8.0**: Core framework
- **ASP.NET Core**: Web API framework
- **Serilog**: Structured logging
- **Swashbuckle**: API documentation
- **IIS**: Production web server
- **JSON**: Data serialization

## 🎯 Next Steps

1. Review `QUICKSTART.md` to get started
2. Customize `WebhookService.cs` for your needs
3. Configure TradingView alerts
4. Deploy to IIS using `IIS-DEPLOYMENT-GUIDE.md`
5. Monitor logs and test thoroughly
6. Add your custom integrations

---

**Project is ready for production use! 🎉**

