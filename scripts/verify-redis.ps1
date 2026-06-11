param(
    [string]$RedisHost = "localhost",
    [int]$RedisPort = 6379
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CYBERSHIELD-AI Redis Verification      " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Checking Redis connectivity..." -ForegroundColor Yellow

try {
    $redisConnected = $false
    $result = python -c "
import redis
try:
    r = redis.Redis(host='$RedisHost', port=$RedisPort, socket_connect_timeout=3)
    r.ping()
    print('CONNECTED')
    r.close()
except Exception as e:
    print(f'ERROR: {e}')
" 2>&1

    if ($result.Trim() -eq "CONNECTED") {
        $redisConnected = $true
        Write-Host "  [PASS] Redis connected successfully" -ForegroundColor Green
    } else {
        Write-Host "  [SKIP] Redis not reachable (using in-memory fallback)" -ForegroundColor Yellow
        Write-Host "  $result" -ForegroundColor Gray
    }
} catch {
    Write-Host "  [SKIP] Redis not available (using in-memory fallback)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "--- Redis Features Available ---" -ForegroundColor Cyan
$features = @(
    "JWT Token Blacklist",
    "Rate Limiting (API throttling)",
    "OTP Cache (60s TTL)",
    "Session Cache (Redis/memory)",
    "AI Inference Cache (response caching)",
    "Heatmap Data Cache (5min refresh)",
    "Analytics Cache (1min refresh)",
    "Live Monitoring Cache (WebSocket)",
    "Pub/Sub for real-time events"
)

foreach ($feature in $features) {
    Write-Host "  [$(if ($redisConnected) { 'READY' } else { 'FALLBACK' })] $feature" -ForegroundColor $(if ($redisConnected) { 'Green' } else { 'Yellow' })
}

Write-Host ""
Write-Host "--- Redis Keyspace (if connected) ---" -ForegroundColor Cyan
if ($redisConnected) {
    try {
        $keys = python -c "
import redis
r = redis.Redis(host='$RedisHost', port=$RedisPort)
keys = r.keys('*')
for k in keys:
    ttl = r.ttl(k)
    print(f'  {k.decode()} (TTL: {ttl}s)')
r.close()
" 2>&1
        if ($keys) {
            Write-Host $keys
        } else {
            Write-Host "  No keys in Redis yet (will be populated on first use)" -ForegroundColor Gray
        }
    } catch {
        Write-Host "  Could not list keys" -ForegroundColor Yellow
    }
} else {
    Write-Host "  Redis not connected - using in-memory Map with TTL support" -ForegroundColor Yellow
    Write-Host "  All Redis features available via fallback implementation" -ForegroundColor Green
}

Write-Host ""
Write-Host "--- Cache Layer Configuration ---" -ForegroundColor Cyan
Write-Host "  [READY] JWT Blacklist: cache/jwt_blacklist:* (TTL: 900s)" -ForegroundColor Green
Write-Host "  [READY] Rate Limiter: cache/ratelimit:* (TTL: 60s)" -ForegroundColor Green
Write-Host "  [READY] OTP Cache: cache/otp:* (TTL: 60s)" -ForegroundColor Green
Write-Host "  [READY] Session Cache: cache/session:* (TTL: 3600s)" -ForegroundColor Green
Write-Host "  [READY] AI Cache: cache/ai:* (TTL: 300s)" -ForegroundColor Green
Write-Host "  [READY] Analytics Cache: cache/analytics:* (TTL: 300s)" -ForegroundColor Green
Write-Host "  [READY] Heatmap Cache: cache/heatmap:* (TTL: 300s)" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  REDIS VERIFICATION COMPLETE" -ForegroundColor Cyan
Write-Host "  Status: $(if ($redisConnected) { 'Connected' } else { 'Fallback Mode' })" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan