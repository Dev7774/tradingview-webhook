# TradingView Webhook - IIS Setup Script
# Run this script as Administrator to automatically setup IIS

param(
    [Parameter(Mandatory=$false)]
    [string]$SiteName = "TradingViewWebhook",
    
    [Parameter(Mandatory=$false)]
    [string]$AppPoolName = "TradingViewWebhookPool",
    
    [Parameter(Mandatory=$false)]
    [string]$PhysicalPath = "C:\inetpub\tradingview-webhook",
    
    [Parameter(Mandatory=$false)]
    [int]$Port = 80,
    
    [Parameter(Mandatory=$false)]
    [string]$HostName = ""
)

# Check if running as Administrator
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TradingView Webhook - IIS Setup Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Import WebAdministration module
Write-Host "[1/10] Loading IIS modules..." -ForegroundColor Green
try {
    Import-Module WebAdministration -ErrorAction Stop
    Write-Host "  ✓ IIS modules loaded" -ForegroundColor Gray
} catch {
    Write-Host "  ✗ IIS is not installed or WebAdministration module not found" -ForegroundColor Red
    Write-Host "  Install IIS first: Install-WindowsFeature -name Web-Server -IncludeManagementTools" -ForegroundColor Yellow
    exit 1
}

# Check if .NET Hosting Bundle is installed
Write-Host "[2/10] Checking .NET Hosting Bundle..." -ForegroundColor Green
$dotnetInfo = dotnet --info 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ .NET is installed" -ForegroundColor Gray
    
    # Check for ASP.NET Core Module
    $aspNetCoreModule = Get-WebGlobalModule | Where-Object { $_.Name -like "*AspNetCore*" }
    if ($aspNetCoreModule) {
        Write-Host "  ✓ ASP.NET Core Module found" -ForegroundColor Gray
    } else {
        Write-Host "  ⚠ ASP.NET Core Module not found" -ForegroundColor Yellow
        Write-Host "  Download .NET Hosting Bundle from: https://dotnet.microsoft.com/download/dotnet/8.0" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ✗ .NET is not installed" -ForegroundColor Red
    Write-Host "  Download .NET Hosting Bundle from: https://dotnet.microsoft.com/download/dotnet/8.0" -ForegroundColor Yellow
    exit 1
}

# Publish the application
Write-Host "[3/10] Publishing application..." -ForegroundColor Green
$projectPath = $PSScriptRoot
if (Test-Path "$projectPath\TradingViewWebhook.csproj") {
    try {
        $publishPath = "$projectPath\publish"
        dotnet publish "$projectPath\TradingViewWebhook.csproj" -c Release -o $publishPath --self-contained false
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✓ Application published to: $publishPath" -ForegroundColor Gray
        } else {
            Write-Host "  ✗ Publish failed" -ForegroundColor Red
            exit 1
        }
    } catch {
        Write-Host "  ✗ Error publishing: $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "  ✗ Project file not found: $projectPath\TradingViewWebhook.csproj" -ForegroundColor Red
    exit 1
}

# Create physical directory
Write-Host "[4/10] Creating physical directory..." -ForegroundColor Green
if (-not (Test-Path $PhysicalPath)) {
    New-Item -Path $PhysicalPath -ItemType Directory -Force | Out-Null
    Write-Host "  ✓ Directory created: $PhysicalPath" -ForegroundColor Gray
} else {
    Write-Host "  ✓ Directory already exists: $PhysicalPath" -ForegroundColor Gray
}

# Copy published files
Write-Host "[5/10] Copying files to IIS directory..." -ForegroundColor Green
try {
    Copy-Item -Path "$projectPath\publish\*" -Destination $PhysicalPath -Recurse -Force
    Write-Host "  ✓ Files copied successfully" -ForegroundColor Gray
} catch {
    Write-Host "  ✗ Error copying files: $_" -ForegroundColor Red
    exit 1
}

# Create Application Pool
Write-Host "[6/10] Creating Application Pool..." -ForegroundColor Green
if (Test-Path "IIS:\AppPools\$AppPoolName") {
    Write-Host "  ⚠ Application Pool already exists: $AppPoolName" -ForegroundColor Yellow
    Write-Host "  Updating configuration..." -ForegroundColor Gray
} else {
    New-WebAppPool -Name $AppPoolName | Out-Null
    Write-Host "  ✓ Application Pool created: $AppPoolName" -ForegroundColor Gray
}

# Configure Application Pool
Set-ItemProperty "IIS:\AppPools\$AppPoolName" -Name managedRuntimeVersion -Value ""
Set-ItemProperty "IIS:\AppPools\$AppPoolName" -Name managedPipelineMode -Value "Integrated"
$appPool = Get-Item "IIS:\AppPools\$AppPoolName"
$appPool.processModel.identityType = "ApplicationPoolIdentity"
$appPool.startMode = "AlwaysRunning"
$appPool.processModel.idleTimeout = [TimeSpan]::FromMinutes(20)
$appPool | Set-Item
Write-Host "  ✓ Application Pool configured" -ForegroundColor Gray

# Create Website
Write-Host "[7/10] Creating Website..." -ForegroundColor Green
if (Test-Path "IIS:\Sites\$SiteName") {
    Write-Host "  ⚠ Website already exists: $SiteName" -ForegroundColor Yellow
    Remove-Website -Name $SiteName
    Write-Host "  Removed existing website" -ForegroundColor Gray
}

$bindingInfo = "*:${Port}:"
if ($HostName) {
    $bindingInfo = "*:${Port}:${HostName}"
}

New-Website -Name $SiteName `
    -ApplicationPool $AppPoolName `
    -PhysicalPath $PhysicalPath `
    -Port $Port `
    -HostHeader $HostName | Out-Null

Write-Host "  ✓ Website created: $SiteName" -ForegroundColor Gray
Write-Host "  ✓ Binding: http://${HostName}:${Port}" -ForegroundColor Gray

# Set Permissions
Write-Host "[8/10] Setting file permissions..." -ForegroundColor Green
try {
    # Grant read/execute permissions to IIS_IUSRS
    icacls $PhysicalPath /grant "IIS_IUSRS:(OI)(CI)RX" /T /Q | Out-Null
    
    # Create and grant write permissions for logs and alerts
    $logsPath = Join-Path $PhysicalPath "logs"
    $alertsPath = Join-Path $PhysicalPath "alerts"
    
    if (-not (Test-Path $logsPath)) {
        New-Item -Path $logsPath -ItemType Directory -Force | Out-Null
    }
    if (-not (Test-Path $alertsPath)) {
        New-Item -Path $alertsPath -ItemType Directory -Force | Out-Null
    }
    
    icacls $logsPath /grant "IIS_IUSRS:(OI)(CI)M" /Q | Out-Null
    icacls $alertsPath /grant "IIS_IUSRS:(OI)(CI)M" /Q | Out-Null
    
    Write-Host "  ✓ Permissions configured" -ForegroundColor Gray
} catch {
    Write-Host "  ✗ Error setting permissions: $_" -ForegroundColor Red
}

# Configure Firewall
Write-Host "[9/10] Configuring Windows Firewall..." -ForegroundColor Green
try {
    $firewallRule = Get-NetFirewallRule -DisplayName "TradingView Webhook" -ErrorAction SilentlyContinue
    if ($firewallRule) {
        Write-Host "  ⚠ Firewall rule already exists" -ForegroundColor Yellow
    } else {
        New-NetFirewallRule -DisplayName "TradingView Webhook" `
            -Direction Inbound `
            -Protocol TCP `
            -LocalPort $Port `
            -Action Allow | Out-Null
        Write-Host "  ✓ Firewall rule created for port $Port" -ForegroundColor Gray
    }
    
    # Optional: Whitelist TradingView IPs
    Write-Host "  Creating rule for TradingView IPs..." -ForegroundColor Gray
    $tvIPs = @("52.89.214.238", "34.212.75.30", "54.218.53.128", "52.32.178.7")
    $tvRule = Get-NetFirewallRule -DisplayName "Allow TradingView Webhooks" -ErrorAction SilentlyContinue
    if (-not $tvRule) {
        New-NetFirewallRule -DisplayName "Allow TradingView Webhooks" `
            -Direction Inbound `
            -Protocol TCP `
            -LocalPort $Port `
            -RemoteAddress $tvIPs `
            -Action Allow `
            -Priority 1 | Out-Null
        Write-Host "  ✓ TradingView IP whitelist rule created" -ForegroundColor Gray
    }
} catch {
    Write-Host "  ⚠ Warning: Could not configure firewall: $_" -ForegroundColor Yellow
}

# Start Website
Write-Host "[10/10] Starting website..." -ForegroundColor Green
try {
    Start-Website -Name $SiteName
    Start-WebAppPool -Name $AppPoolName
    Write-Host "  ✓ Website started successfully" -ForegroundColor Gray
} catch {
    Write-Host "  ✗ Error starting website: $_" -ForegroundColor Red
}

# Test the deployment
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Testing Deployment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Start-Sleep -Seconds 2

Write-Host "Testing health endpoint..." -ForegroundColor Green
try {
    $testUrl = "http://localhost:$Port/health"
    $response = Invoke-RestMethod -Uri $testUrl -Method GET -TimeoutSec 5
    Write-Host "  ✓ Health check passed!" -ForegroundColor Gray
    Write-Host "  Response: $($response | ConvertTo-Json -Compress)" -ForegroundColor Gray
} catch {
    Write-Host "  ✗ Health check failed: $_" -ForegroundColor Red
    Write-Host "  Check logs at: $PhysicalPath\logs\" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Website Details:" -ForegroundColor Yellow
Write-Host "  Name: $SiteName" -ForegroundColor White
Write-Host "  URL: http://localhost:$Port" -ForegroundColor White
if ($HostName) {
    Write-Host "  Host: http://${HostName}:${Port}" -ForegroundColor White
}
Write-Host "  Physical Path: $PhysicalPath" -ForegroundColor White
Write-Host "  Application Pool: $AppPoolName" -ForegroundColor White
Write-Host ""
Write-Host "Endpoints:" -ForegroundColor Yellow
Write-Host "  Health: http://localhost:$Port/health" -ForegroundColor White
Write-Host "  Test: http://localhost:$Port/api/webhook/test" -ForegroundColor White
Write-Host "  Webhook: http://localhost:$Port/api/webhook/receive" -ForegroundColor White
Write-Host ""
Write-Host "Logs Location:" -ForegroundColor Yellow
Write-Host "  Application: $PhysicalPath\logs\" -ForegroundColor White
Write-Host "  IIS: C:\inetpub\logs\LogFiles\" -ForegroundColor White
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Test webhook: .\test-webhook.ps1 -BaseUrl 'http://localhost:$Port'" -ForegroundColor White
Write-Host "  2. Configure TradingView webhook URL:" -ForegroundColor White
Write-Host "     http://your-domain.com:$Port/api/webhook/receive" -ForegroundColor Cyan
Write-Host "  3. Monitor logs for incoming alerts" -ForegroundColor White
Write-Host "  4. Customize Services\WebhookService.cs for your needs" -ForegroundColor White
Write-Host ""
Write-Host "Useful Commands:" -ForegroundColor Yellow
Write-Host "  View logs: Get-Content '$PhysicalPath\logs\tradingview-webhook-*.txt' -Tail 50 -Wait" -ForegroundColor White
Write-Host "  Restart: Restart-WebAppPool -Name '$AppPoolName'" -ForegroundColor White
Write-Host "  Stop: Stop-Website -Name '$SiteName'" -ForegroundColor White
Write-Host "  Start: Start-Website -Name '$SiteName'" -ForegroundColor White
Write-Host ""
Write-Host "Setup completed successfully! 🎉" -ForegroundColor Green
Write-Host ""


