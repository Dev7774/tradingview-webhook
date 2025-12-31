# Complete IIS Deployment Guide

## 📋 Pre-Deployment Checklist

- [ ] Windows Server with IIS installed
- [ ] .NET 8.0 Hosting Bundle installed
- [ ] Domain name or public IP configured
- [ ] Firewall rules configured
- [ ] SSL certificate (optional but recommended)

## 🎯 Detailed IIS Setup Steps

### Part 1: Server Preparation

#### 1.1 Install IIS (if not already installed)

Run PowerShell as Administrator:

```powershell
# Install IIS with management tools
Install-WindowsFeature -name Web-Server -IncludeManagementTools

# Install additional IIS features
Install-WindowsFeature Web-WebSockets
Install-WindowsFeature Web-Http-Redirect
```

#### 1.2 Install .NET Hosting Bundle

1. Download the .NET 8.0 Hosting Bundle:
   ```
   https://dotnet.microsoft.com/en-us/download/dotnet/8.0
   ```

2. Look for "**Hosting Bundle**" under the Runtime section

3. Install the bundle (dotnet-hosting-8.x.x-win.exe)

4. **IMPORTANT:** Restart IIS after installation:
   ```powershell
   net stop was /y
   net start w3svc
   ```

5. Verify installation:
   ```powershell
   dotnet --info
   ```

### Part 2: Application Publishing

#### 2.1 Publish Using Visual Studio

1. Open the project in Visual Studio 2022
2. Right-click on `TradingViewWebhook` project
3. Select **Publish**
4. Choose **Folder** as target
5. Set location: `C:\Publish\TradingViewWebhook`
6. Configuration: **Release**
7. Target Framework: **net8.0**
8. Click **Publish**

#### 2.2 Publish Using Command Line

```powershell
# Navigate to project directory
cd D:\Projects\tradingview-webhook

# Publish in Release mode
dotnet publish -c Release -o C:\Publish\TradingViewWebhook --self-contained false

# Verify published files
dir C:\Publish\TradingViewWebhook
```

#### 2.3 Copy to IIS Directory

```powershell
# Create IIS directory
New-Item -Path "C:\inetpub\tradingview-webhook" -ItemType Directory -Force

# Copy published files
Copy-Item -Path "C:\Publish\TradingViewWebhook\*" -Destination "C:\inetpub\tradingview-webhook" -Recurse -Force
```

### Part 3: IIS Configuration

#### 3.1 Create Application Pool

**Using IIS Manager GUI:**

1. Open IIS Manager (inetmgr.exe)
2. Expand server node
3. Click **Application Pools**
4. In Actions pane, click **Add Application Pool**
5. Configure:
   - **Name:** `TradingViewWebhookPool`
   - **.NET CLR version:** `No Managed Code` ⚠️ IMPORTANT
   - **Managed pipeline mode:** `Integrated`
   - **Start application pool immediately:** ✅ Checked
6. Click **OK**

**Using PowerShell:**

```powershell
Import-Module WebAdministration

# Create Application Pool
New-WebAppPool -Name "TradingViewWebhookPool"

# Configure Application Pool
Set-ItemProperty IIS:\AppPools\TradingViewWebhookPool -Name managedRuntimeVersion -Value ""
Set-ItemProperty IIS:\AppPools\TradingViewWebhookPool -Name managedPipelineMode -Value "Integrated"
```

#### 3.2 Configure Application Pool Settings

**Using IIS Manager:**

1. Right-click **TradingViewWebhookPool** → **Advanced Settings**
2. Configure:
   - **Identity:** `ApplicationPoolIdentity` (recommended)
   - **Start Mode:** `AlwaysRunning` (for better performance)
   - **Idle Time-out:** `20` minutes (or 0 to disable)
   - **Regular Time Interval:** `0` (disable recycling)
3. Click **OK**

**Using PowerShell:**

```powershell
# Configure advanced settings
$pool = Get-Item IIS:\AppPools\TradingViewWebhookPool
$pool.processModel.identityType = "ApplicationPoolIdentity"
$pool.startMode = "AlwaysRunning"
$pool.processModel.idleTimeout = [TimeSpan]::FromMinutes(20)
$pool | Set-Item
```

#### 3.3 Create Website

**Using IIS Manager:**

1. Right-click **Sites** → **Add Website**
2. Configure:
   - **Site name:** `TradingViewWebhook`
   - **Application pool:** `TradingViewWebhookPool`
   - **Physical path:** `C:\inetpub\tradingview-webhook`
   - **Binding:**
     - Type: `http`
     - IP address: `All Unassigned`
     - Port: `80` (or `8080` if 80 is in use)
     - Host name: Leave blank or enter your domain
3. Click **OK**

**Using PowerShell:**

```powershell
# Create website
New-Website -Name "TradingViewWebhook" `
    -ApplicationPool "TradingViewWebhookPool" `
    -PhysicalPath "C:\inetpub\tradingview-webhook" `
    -Port 80

# Start the website
Start-Website -Name "TradingViewWebhook"
```

#### 3.4 Verify web.config

Ensure `web.config` exists in `C:\inetpub\tradingview-webhook\` with correct content:

```xml
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <location path="." inheritInChildApplications="false">
    <system.webServer>
      <handlers>
        <add name="aspNetCore" path="*" verb="*" modules="AspNetCoreModuleV2" resourceType="Unspecified" />
      </handlers>
      <aspNetCore processPath="dotnet" 
                  arguments=".\TradingViewWebhook.dll" 
                  stdoutLogEnabled="true" 
                  stdoutLogFile=".\logs\stdout" 
                  hostingModel="inprocess" />
    </system.webServer>
  </location>
</configuration>
```

### Part 4: Security Configuration

#### 4.1 Set File System Permissions

```powershell
# Navigate to application directory
cd C:\inetpub\tradingview-webhook

# Grant read permissions to IIS_IUSRS
icacls . /grant "IIS_IUSRS:(OI)(CI)RX" /T

# Grant write permissions for logs and alerts folders
New-Item -Path ".\logs" -ItemType Directory -Force
New-Item -Path ".\alerts" -ItemType Directory -Force

icacls .\logs /grant "IIS_IUSRS:(OI)(CI)M"
icacls .\alerts /grant "IIS_IUSRS:(OI)(CI)M"
```

#### 4.2 Configure Windows Firewall

```powershell
# Open port 80 for HTTP
New-NetFirewallRule -DisplayName "TradingView Webhook HTTP" `
    -Direction Inbound `
    -Protocol TCP `
    -LocalPort 80 `
    -Action Allow

# Open port 443 for HTTPS (if using SSL)
New-NetFirewallRule -DisplayName "TradingView Webhook HTTPS" `
    -Direction Inbound `
    -Protocol TCP `
    -LocalPort 443 `
    -Action Allow
```

#### 4.3 Whitelist TradingView IPs (Optional but Recommended)

```powershell
# TradingView webhook source IPs
$tvIPs = @(
    "52.89.214.238",
    "34.212.75.30",
    "54.218.53.128",
    "52.32.178.7"
)

# Create firewall rule allowing only TradingView IPs
New-NetFirewallRule -DisplayName "Allow TradingView Webhooks" `
    -Direction Inbound `
    -Protocol TCP `
    -LocalPort 80 `
    -RemoteAddress $tvIPs `
    -Action Allow `
    -Priority 1
```

### Part 5: SSL/HTTPS Configuration (Recommended)

#### 5.1 Obtain SSL Certificate

**Option A: Let's Encrypt (Free)**
- Use win-acme tool: https://www.win-acme.com/

**Option B: Commercial Certificate**
- Purchase from SSL provider
- Import .pfx file to Windows Certificate Store

#### 5.2 Bind SSL Certificate to Website

```powershell
# Import certificate (if using .pfx)
$certPassword = ConvertTo-SecureString -String "YourPassword" -Force -AsPlainText
$cert = Import-PfxCertificate -FilePath "C:\path\to\cert.pfx" `
    -CertStoreLocation Cert:\LocalMachine\My `
    -Password $certPassword

# Add HTTPS binding
New-WebBinding -Name "TradingViewWebhook" `
    -Protocol https `
    -Port 443 `
    -SslFlags 1

# Bind certificate
$binding = Get-WebBinding -Name "TradingViewWebhook" -Protocol https
$binding.AddSslCertificate($cert.Thumbprint, "My")
```

#### 5.3 Force HTTPS Redirect

In `web.config`, add inside `<system.webServer>`:

```xml
<rewrite>
  <rules>
    <rule name="HTTPS Redirect" stopProcessing="true">
      <match url="(.*)" />
      <conditions>
        <add input="{HTTPS}" pattern="off" ignoreCase="true" />
      </conditions>
      <action type="Redirect" url="https://{HTTP_HOST}/{R:1}" redirectType="Permanent" />
    </rule>
  </rules>
</rewrite>
```

### Part 6: Testing and Verification

#### 6.1 Test Locally on Server

```powershell
# Test health endpoint
Invoke-WebRequest -Uri "http://localhost/health" -Method GET

# Test webhook test endpoint
Invoke-WebRequest -Uri "http://localhost/api/webhook/test" -Method GET

# Test webhook receive endpoint
$testAlert = @{
    ticker = "BTCUSD"
    action = "buy"
    price = 45000.50
    time = (Get-Date).ToString("o")
    exchange = "BINANCE"
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost/api/webhook/receive" `
    -Method POST `
    -Body $testAlert `
    -ContentType "application/json"
```

#### 6.2 Test from External Network

Using PowerShell:
```powershell
Invoke-WebRequest -Uri "http://your-domain.com/api/webhook/test"
```

Using curl:
```bash
curl http://your-domain.com/api/webhook/test
```

Using browser:
```
http://your-domain.com/api/webhook/test
```

#### 6.3 Test with TradingView

1. Go to TradingView.com
2. Open any chart
3. Click **Alert** button (clock icon)
4. Configure alert with webhook:
   - **Webhook URL:** `http://your-domain.com/api/webhook/receive`
   - **Message:**
     ```json
     {
       "ticker": "{{ticker}}",
       "action": "buy",
       "price": {{close}}
     }
     ```
5. Save and trigger the alert
6. Check logs: `C:\inetpub\tradingview-webhook\logs\`

### Part 7: Monitoring and Maintenance

#### 7.1 View Application Logs

```powershell
# View latest application logs
Get-Content "C:\inetpub\tradingview-webhook\logs\tradingview-webhook-*.txt" -Tail 50 -Wait

# View IIS stdout logs
Get-Content "C:\inetpub\tradingview-webhook\logs\stdout*.log" -Tail 50 -Wait

# View Windows Event Logs
Get-EventLog -LogName Application -Source "IIS*" -Newest 50
```

#### 7.2 Monitor Website Status

```powershell
# Check website status
Get-Website -Name "TradingViewWebhook"

# Check application pool status
Get-WebAppPoolState -Name "TradingViewWebhookPool"

# Restart if needed
Restart-WebAppPool -Name "TradingViewWebhookPool"
Restart-Website -Name "TradingViewWebhook"
```

#### 7.3 Setup Automated Monitoring

Create a scheduled task to check webhook health:

```powershell
$action = New-ScheduledTaskAction -Execute 'PowerShell.exe' `
    -Argument '-Command "Invoke-WebRequest -Uri http://localhost/health"'

$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) `
    -RepetitionInterval (New-TimeSpan -Minutes 5) `
    -RepetitionDuration ([TimeSpan]::MaxValue)

Register-ScheduledTask -TaskName "TradingView Webhook Health Check" `
    -Action $action `
    -Trigger $trigger `
    -User "SYSTEM"
```

### Part 8: Troubleshooting Common Issues

#### Issue 1: HTTP 502.5 Error

**Cause:** .NET Hosting Bundle not installed or wrong version

**Solution:**
```powershell
# Check .NET version
dotnet --info

# Reinstall Hosting Bundle
# Download from: https://dotnet.microsoft.com/download/dotnet/8.0

# Restart IIS
iisreset
```

#### Issue 2: HTTP 500.19 Error

**Cause:** Invalid web.config or missing AspNetCoreModuleV2

**Solution:**
```powershell
# Verify ASP.NET Core Module is installed
Get-WindowsFeature -Name Web-Server | Select-Object -ExpandProperty InstallState

# Repair .NET Hosting Bundle
# Uninstall and reinstall from Microsoft website
```

#### Issue 3: Cannot Write to Logs Folder

**Cause:** Insufficient permissions

**Solution:**
```powershell
cd C:\inetpub\tradingview-webhook
icacls .\logs /grant "IIS_IUSRS:(OI)(CI)M"
icacls .\alerts /grant "IIS_IUSRS:(OI)(CI)M"

# Restart application pool
Restart-WebAppPool -Name "TradingViewWebhookPool"
```

#### Issue 4: Website Not Accessible from External Network

**Cause:** Firewall or port binding issue

**Solution:**
```powershell
# Check if port is listening
netstat -ano | findstr :80

# Test firewall
Test-NetConnection -ComputerName localhost -Port 80

# Verify binding
Get-WebBinding -Name "TradingViewWebhook"
```

### Part 9: Production Best Practices

#### 9.1 Enable Application Insights (Optional)

Add to `appsettings.json`:
```json
{
  "ApplicationInsights": {
    "InstrumentationKey": "your-key-here"
  }
}
```

#### 9.2 Setup Log Rotation

Serilog automatically rotates logs daily. To limit log file count:

Edit `Program.cs`:
```csharp
.WriteTo.File("logs/tradingview-webhook-.txt", 
    rollingInterval: RollingInterval.Day,
    retainedFileCountLimit: 30) // Keep last 30 days
```

#### 9.3 Configure Request Limits

In `web.config`:
```xml
<security>
  <requestFiltering>
    <requestLimits maxAllowedContentLength="10485760" /> <!-- 10 MB -->
  </requestFiltering>
</security>
```

#### 9.4 Enable Response Compression

In `Program.cs`:
```csharp
builder.Services.AddResponseCompression(options =>
{
    options.EnableForHttps = true;
});

app.UseResponseCompression();
```

## ✅ Post-Deployment Checklist

- [ ] Website accessible from external network
- [ ] HTTPS configured and working
- [ ] Logs being written successfully
- [ ] Firewall rules configured
- [ ] Test alert received from TradingView
- [ ] Monitoring configured
- [ ] Backups configured
- [ ] Documentation updated with actual URLs

## 📞 Support Resources

- **IIS Logs Location:** `C:\inetpub\logs\LogFiles\`
- **Application Logs:** `C:\inetpub\tradingview-webhook\logs\`
- **Windows Event Viewer:** `eventvwr.msc`
- **IIS Manager:** `inetmgr.exe`

---

**Deployment completed! Your TradingView webhook receiver is now live! 🚀**

