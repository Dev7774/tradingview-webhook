# TradingView Webhook Test Script
# Run this script to test your webhook locally or on IIS

param(
    [Parameter(Mandatory=$false)]
    [string]$BaseUrl = "http://localhost:5000"
)

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "TradingView Webhook Test Script" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Testing webhook at: $BaseUrl" -ForegroundColor Yellow
Write-Host ""

# Test 1: Health Check
Write-Host "[Test 1] Health Check..." -ForegroundColor Green
try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/health" -Method GET
    Write-Host "✓ Health check passed" -ForegroundColor Green
    Write-Host "  Response: $($response | ConvertTo-Json -Compress)" -ForegroundColor Gray
} catch {
    Write-Host "✗ Health check failed: $_" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Test 2: Webhook Test Endpoint
Write-Host "[Test 2] Webhook Test Endpoint..." -ForegroundColor Green
try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/api/webhook/test" -Method GET
    Write-Host "✓ Test endpoint passed" -ForegroundColor Green
    Write-Host "  Response: $($response | ConvertTo-Json -Compress)" -ForegroundColor Gray
} catch {
    Write-Host "✗ Test endpoint failed: $_" -ForegroundColor Red
}
Write-Host ""

# Test 3: Simple Buy Alert
Write-Host "[Test 3] Simple Buy Alert..." -ForegroundColor Green
try {
    $alert = @{
        ticker = "BTCUSD"
        action = "buy"
        price = 45000.50
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri "$BaseUrl/api/webhook/receive" `
        -Method POST `
        -Body $alert `
        -ContentType "application/json"
    
    Write-Host "✓ Buy alert processed" -ForegroundColor Green
    Write-Host "  Alert ID: $($response.alertId)" -ForegroundColor Gray
    Write-Host "  Message: $($response.message)" -ForegroundColor Gray
} catch {
    Write-Host "✗ Buy alert failed: $_" -ForegroundColor Red
}
Write-Host ""

# Test 4: Comprehensive Alert
Write-Host "[Test 4] Comprehensive Alert..." -ForegroundColor Green
try {
    $alert = @{
        ticker = "ETHUSDT"
        action = "long"
        price = 3500.25
        time = (Get-Date).ToString("o")
        exchange = "BINANCE"
        strategy = "MA_CROSSOVER"
        interval = "15m"
        volume = 125.45
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri "$BaseUrl/api/webhook/receive" `
        -Method POST `
        -Body $alert `
        -ContentType "application/json"
    
    Write-Host "✓ Comprehensive alert processed" -ForegroundColor Green
    Write-Host "  Alert ID: $($response.alertId)" -ForegroundColor Gray
} catch {
    Write-Host "✗ Comprehensive alert failed: $_" -ForegroundColor Red
}
Write-Host ""

# Test 5: Sell Signal
Write-Host "[Test 5] Sell Signal..." -ForegroundColor Green
try {
    $alert = @{
        ticker = "AAPL"
        action = "sell"
        price = 185.50
        time = (Get-Date).ToString("o")
        strategy = "RSI_OVERBOUGHT"
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri "$BaseUrl/api/webhook/receive" `
        -Method POST `
        -Body $alert `
        -ContentType "application/json"
    
    Write-Host "✓ Sell signal processed" -ForegroundColor Green
    Write-Host "  Alert ID: $($response.alertId)" -ForegroundColor Gray
} catch {
    Write-Host "✗ Sell signal failed: $_" -ForegroundColor Red
}
Write-Host ""

# Test 6: Raw Text Alert
Write-Host "[Test 6] Raw Text Alert..." -ForegroundColor Green
try {
    $rawMessage = "BUY BTCUSD at 45000 - Strong bullish signal"

    $response = Invoke-RestMethod -Uri "$BaseUrl/api/webhook/receive-raw" `
        -Method POST `
        -Body $rawMessage `
        -ContentType "text/plain"
    
    Write-Host "✓ Raw text alert processed" -ForegroundColor Green
    Write-Host "  Alert ID: $($response.alertId)" -ForegroundColor Gray
} catch {
    Write-Host "✗ Raw text alert failed: $_" -ForegroundColor Red
}
Write-Host ""

# Test 7: Invalid JSON (Error Handling)
Write-Host "[Test 7] Invalid JSON (Error Handling)..." -ForegroundColor Green
try {
    $invalidJson = "{ this is not valid json }"

    $response = Invoke-RestMethod -Uri "$BaseUrl/api/webhook/receive" `
        -Method POST `
        -Body $invalidJson `
        -ContentType "application/json"
    
    Write-Host "✗ Should have failed but didn't" -ForegroundColor Red
} catch {
    Write-Host "✓ Error handling works correctly" -ForegroundColor Green
    Write-Host "  Expected error received" -ForegroundColor Gray
}
Write-Host ""

# Test 8: Empty Payload (Error Handling)
Write-Host "[Test 8] Empty Payload (Error Handling)..." -ForegroundColor Green
try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/api/webhook/receive" `
        -Method POST `
        -Body "" `
        -ContentType "application/json"
    
    Write-Host "✗ Should have failed but didn't" -ForegroundColor Red
} catch {
    Write-Host "✓ Error handling works correctly" -ForegroundColor Green
    Write-Host "  Expected error received" -ForegroundColor Gray
}
Write-Host ""

# Summary
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Test Summary" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "All core tests completed!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Check logs in the 'logs' folder" -ForegroundColor White
Write-Host "2. Check saved alerts in the 'alerts' folder" -ForegroundColor White
Write-Host "3. Configure TradingView to send alerts to:" -ForegroundColor White
Write-Host "   $BaseUrl/api/webhook/receive" -ForegroundColor Cyan
Write-Host ""


