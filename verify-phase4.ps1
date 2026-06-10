$ErrorActionPreference = "Stop"

$services = @(
    "api-gateway", "citizen-service", "police-service", "isp-service",
    "notification-service", "reporting-service", "file-storage-service",
    "analytics-service", "websocket-service"
)

Write-Host "Verifying Phase 4 Backend Scaffolding..." -ForegroundColor Cyan

foreach ($service in $services) {
    $path = "backend/services/$service/main.py"
    if (Test-Path $path) {
        Write-Host "[OK] Service $service exists." -ForegroundColor Green
    } else {
        Write-Error "Service $service is missing main.py entry point."
    }
}

if (Test-Path "backend/shared/events/kafka_stub.py") {
    Write-Host "[OK] Shared Kafka stubs created." -ForegroundColor Green
}

Write-Host "Phase 4 Verification Passed." -ForegroundColor Green