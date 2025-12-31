#!/bin/bash

# TradingView Webhook Test Script (Linux/Mac)
# Run this script to test your webhook

BASE_URL="${1:-http://localhost:5000}"

echo "=================================="
echo "TradingView Webhook Test Script"
echo "=================================="
echo ""
echo "Testing webhook at: $BASE_URL"
echo ""

# Test 1: Health Check
echo "[Test 1] Health Check..."
if curl -s "$BASE_URL/health" | grep -q "healthy"; then
    echo "✓ Health check passed"
else
    echo "✗ Health check failed"
    exit 1
fi
echo ""

# Test 2: Webhook Test Endpoint
echo "[Test 2] Webhook Test Endpoint..."
curl -s "$BASE_URL/api/webhook/test"
echo ""
echo ""

# Test 3: Simple Buy Alert
echo "[Test 3] Simple Buy Alert..."
curl -X POST "$BASE_URL/api/webhook/receive" \
    -H "Content-Type: application/json" \
    -d '{"ticker":"BTCUSD","action":"buy","price":45000.50}'
echo ""
echo ""

# Test 4: Comprehensive Alert
echo "[Test 4] Comprehensive Alert..."
curl -X POST "$BASE_URL/api/webhook/receive" \
    -H "Content-Type: application/json" \
    -d '{
        "ticker": "ETHUSDT",
        "action": "long",
        "price": 3500.25,
        "time": "2025-12-31T10:30:00Z",
        "exchange": "BINANCE",
        "strategy": "MA_CROSSOVER",
        "interval": "15m",
        "volume": 125.45
    }'
echo ""
echo ""

# Test 5: Sell Signal
echo "[Test 5] Sell Signal..."
curl -X POST "$BASE_URL/api/webhook/receive" \
    -H "Content-Type: application/json" \
    -d '{
        "ticker": "AAPL",
        "action": "sell",
        "price": 185.50,
        "strategy": "RSI_OVERBOUGHT"
    }'
echo ""
echo ""

# Test 6: Raw Text Alert
echo "[Test 6] Raw Text Alert..."
curl -X POST "$BASE_URL/api/webhook/receive-raw" \
    -H "Content-Type: text/plain" \
    -d "BUY BTCUSD at 45000 - Strong bullish signal"
echo ""
echo ""

# Summary
echo "=================================="
echo "Test Summary"
echo "=================================="
echo "All core tests completed!"
echo ""
echo "Next steps:"
echo "1. Check logs in the 'logs' folder"
echo "2. Check saved alerts in the 'alerts' folder"
echo "3. Configure TradingView to send alerts to:"
echo "   $BASE_URL/api/webhook/receive"
echo ""

