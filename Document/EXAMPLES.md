# TradingView Alert Examples

## 📝 Example Alert Messages for TradingView

### 1. Basic Buy/Sell Alert

**Alert Message:**
```json
{
  "ticker": "{{ticker}}",
  "action": "buy",
  "price": {{close}}
}
```

**Expected Webhook Payload:**
```json
{
  "ticker": "BTCUSD",
  "action": "buy",
  "price": 45000.50
}
```

---

### 2. Comprehensive Trading Signal

**Alert Message:**
```json
{
  "ticker": "{{ticker}}",
  "action": "{{strategy.order.action}}",
  "price": {{close}},
  "time": "{{time}}",
  "exchange": "{{exchange}}",
  "interval": "{{interval}}",
  "volume": {{volume}}
}
```

**Expected Webhook Payload:**
```json
{
  "ticker": "BTCUSD",
  "action": "long",
  "price": 45000.50,
  "time": "2025-12-31T10:30:00Z",
  "exchange": "BINANCE",
  "interval": "15",
  "volume": 125.45
}
```

---

### 3. Strategy-Based Alert with Custom Fields

**Alert Message:**
```json
{
  "strategy": "RSI_DIVERGENCE",
  "ticker": "{{ticker}}",
  "action": "long",
  "entry_price": {{close}},
  "stop_loss": {{close}} * 0.95,
  "take_profit": {{close}} * 1.10,
  "time": "{{timenow}}",
  "rsi": "{{plot_0}}"
}
```

**Expected Webhook Payload:**
```json
{
  "strategy": "RSI_DIVERGENCE",
  "ticker": "ETHUSDT",
  "action": "long",
  "entry_price": 3500.25,
  "stop_loss": 3325.24,
  "take_profit": 3850.28,
  "time": "2025-12-31T10:30:00",
  "rsi": "32.5"
}
```

---

### 4. Moving Average Crossover

**Alert Message:**
```json
{
  "strategy": "MA_CROSSOVER",
  "ticker": "{{ticker}}",
  "action": "{{strategy.order.action}}",
  "price": {{close}},
  "ma_fast": "{{plot_0}}",
  "ma_slow": "{{plot_1}}",
  "signal": "BULLISH",
  "timestamp": "{{time}}"
}
```

**Expected Webhook Payload:**
```json
{
  "strategy": "MA_CROSSOVER",
  "ticker": "AAPL",
  "action": "buy",
  "price": 185.50,
  "ma_fast": "183.25",
  "ma_slow": "180.10",
  "signal": "BULLISH",
  "timestamp": "2025-12-31T10:30:00"
}
```

---

### 5. Support/Resistance Breakout

**Alert Message:**
```json
{
  "alert_type": "BREAKOUT",
  "ticker": "{{ticker}}",
  "action": "long",
  "breakout_price": {{high}},
  "volume": {{volume}},
  "resistance_level": 46000,
  "time": "{{time}}"
}
```

**Expected Webhook Payload:**
```json
{
  "alert_type": "BREAKOUT",
  "ticker": "BTCUSD",
  "action": "long",
  "breakout_price": 46100.00,
  "volume": 250.75,
  "resistance_level": 46000,
  "time": "2025-12-31T10:30:00"
}
```

---

### 6. Stop Loss / Take Profit Alert

**Alert Message:**
```json
{
  "alert_type": "EXIT",
  "ticker": "{{ticker}}",
  "action": "close",
  "exit_price": {{close}},
  "exit_reason": "STOP_LOSS",
  "pnl_percent": -2.5,
  "time": "{{time}}"
}
```

**Expected Webhook Payload:**
```json
{
  "alert_type": "EXIT",
  "ticker": "EURUSD",
  "action": "close",
  "exit_price": 1.0850,
  "exit_reason": "STOP_LOSS",
  "pnl_percent": -2.5,
  "time": "2025-12-31T10:30:00"
}
```

---

### 7. Multi-Timeframe Analysis

**Alert Message:**
```json
{
  "ticker": "{{ticker}}",
  "action": "buy",
  "price": {{close}},
  "timeframes": {
    "5m": "BULLISH",
    "15m": "BULLISH",
    "1h": "NEUTRAL",
    "4h": "BULLISH"
  },
  "confidence": "HIGH",
  "time": "{{time}}"
}
```

**Expected Webhook Payload:**
```json
{
  "ticker": "SPY",
  "action": "buy",
  "price": 450.25,
  "timeframes": {
    "5m": "BULLISH",
    "15m": "BULLISH",
    "1h": "NEUTRAL",
    "4h": "BULLISH"
  },
  "confidence": "HIGH",
  "time": "2025-12-31T10:30:00"
}
```

---

### 8. Volatility Breakout

**Alert Message:**
```json
{
  "strategy": "VOLATILITY_BREAKOUT",
  "ticker": "{{ticker}}",
  "action": "long",
  "entry": {{close}},
  "atr": "{{plot_0}}",
  "bollinger_upper": "{{plot_1}}",
  "volatility": "HIGH",
  "time": "{{timenow}}"
}
```

**Expected Webhook Payload:**
```json
{
  "strategy": "VOLATILITY_BREAKOUT",
  "ticker": "TSLA",
  "action": "long",
  "entry": 245.80,
  "atr": "8.50",
  "bollinger_upper": "250.00",
  "volatility": "HIGH",
  "time": "2025-12-31T10:30:00"
}
```

---

### 9. Divergence Alert

**Alert Message:**
```json
{
  "alert_type": "DIVERGENCE",
  "ticker": "{{ticker}}",
  "divergence_type": "BULLISH",
  "indicator": "RSI",
  "price": {{close}},
  "rsi_value": "{{plot_0}}",
  "action": "buy",
  "time": "{{time}}"
}
```

**Expected Webhook Payload:**
```json
{
  "alert_type": "DIVERGENCE",
  "ticker": "GOLD",
  "divergence_type": "BULLISH",
  "indicator": "RSI",
  "price": 2050.50,
  "rsi_value": "28.5",
  "action": "buy",
  "time": "2025-12-31T10:30:00"
}
```

---

### 10. Pattern Recognition Alert

**Alert Message:**
```json
{
  "alert_type": "PATTERN",
  "pattern_name": "DOUBLE_BOTTOM",
  "ticker": "{{ticker}}",
  "action": "buy",
  "entry_price": {{close}},
  "target": 1850,
  "stop": 1700,
  "confidence": 85,
  "time": "{{time}}"
}
```

**Expected Webhook Payload:**
```json
{
  "alert_type": "PATTERN",
  "pattern_name": "DOUBLE_BOTTOM",
  "ticker": "GOOGL",
  "action": "buy",
  "entry_price": 1750.25,
  "target": 1850,
  "stop": 1700,
  "confidence": 85,
  "time": "2025-12-31T10:30:00"
}
```

---

## 🧪 Testing Your Webhook with curl

### Test 1: Basic Alert
```bash
curl -X POST http://your-domain.com/api/webhook/receive \
  -H "Content-Type: application/json" \
  -d '{"ticker":"BTCUSD","action":"buy","price":45000}'
```

### Test 2: Comprehensive Alert
```bash
curl -X POST http://your-domain.com/api/webhook/receive \
  -H "Content-Type: application/json" \
  -d '{
    "ticker": "ETHUSDT",
    "action": "long",
    "price": 3500.50,
    "time": "2025-12-31T10:30:00Z",
    "exchange": "BINANCE",
    "strategy": "MA_CROSSOVER",
    "interval": "15m"
  }'
```

### Test 3: Raw Text Alert
```bash
curl -X POST http://your-domain.com/api/webhook/receive-raw \
  -H "Content-Type: text/plain" \
  -d 'BUY BTCUSD at 45000'
```

---

## 🔍 Testing with PowerShell

### Test 1: Basic Request
```powershell
$body = @{
    ticker = "BTCUSD"
    action = "buy"
    price = 45000.50
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://your-domain.com/api/webhook/receive" `
    -Method POST `
    -Body $body `
    -ContentType "application/json"
```

### Test 2: Complex Request
```powershell
$body = @{
    strategy = "RSI_DIVERGENCE"
    ticker = "ETHUSDT"
    action = "long"
    entry_price = 3500.25
    stop_loss = 3325.24
    take_profit = 3850.28
    time = (Get-Date).ToString("o")
    rsi = 32.5
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://your-domain.com/api/webhook/receive" `
    -Method POST `
    -Body $body `
    -ContentType "application/json"
```

---

## 📊 Common TradingView Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `{{ticker}}` | Symbol name | BTCUSD |
| `{{exchange}}` | Exchange name | BINANCE |
| `{{close}}` | Close price | 45000.50 |
| `{{open}}` | Open price | 44950.25 |
| `{{high}}` | High price | 45100.00 |
| `{{low}}` | Low price | 44900.00 |
| `{{volume}}` | Volume | 1250.75 |
| `{{time}}` | Bar time | 2025-12-31T10:00:00Z |
| `{{timenow}}` | Current time | 2025-12-31T10:30:00 |
| `{{interval}}` | Timeframe | 15 |
| `{{plot_0}}` | First plot value | 32.5 |
| `{{strategy.order.action}}` | Order action | buy/sell/long/short |

---

## 💡 Tips for TradingView Alerts

1. **Always use valid JSON format** in your alert messages
2. **Test locally first** before using with real trading
3. **Use descriptive field names** for easier processing
4. **Include timestamp** for tracking and auditing
5. **Add strategy name** to differentiate alert sources
6. **Include confidence levels** for filtering
7. **Add stop loss and take profit** for risk management
8. **Log everything** for debugging and analysis

---

## 🔗 Useful Links

- [TradingView Webhook Documentation](https://www.tradingview.com/support/folders/43000560150-webhooks-usage/)
- [TradingView Pine Script Variables](https://www.tradingview.com/pine-script-docs/en/v5/)
- [JSON Validator](https://jsonlint.com/)

---

**Happy Trading! 📈**

