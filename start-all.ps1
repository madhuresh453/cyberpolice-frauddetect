<#
.SYNOPSIS
    CyberShield AI - Unified Startup Script
    Starts all services in separate PowerShell windows
.DESCRIPTION
    Launches all microservices, portals, and infrastructure for CyberShield AI
#>

$ROOT = "E:\cybershield-ai"
$BACKEND = "$ROOT\backend"
$AI = "$ROOT\ai"

# ===== CONFIGURATION =====
$services = @(
    @{
        Name = "Backend Gateway (Express)"
        Title = "Backend Gateway"
        Command = "cd $ROOT && node backend/server.js"
        Port = 5000
        Color = "Cyan"
    }
    @{
        Name = "AI Gateway (FastAPI)"
        Title = "AI Gateway"
        Command = "cd $ROOT && python -m uvicorn ai.ai_gateway:app --reload --host 0.0.0.0 --port 8000"
        Port = 8000
        Color = "Green"
    }
    @{
        Name = "Auth Service (FastAPI)"
        Title = "Auth Service"
        Command = "cd $ROOT && python -m uvicorn backend.services.auth-service.main:app --reload --host 0.0.0.0 --port 5001"
        Port = 5001
        Color = "Yellow"
    }
    @{
        Name = "Bank Integration (FastAPI)"
        Title = "Bank Service"
        Command = "cd $ROOT && python -m uvicorn backend.services.bank-integration-service.main:app --reload --host 0.0.0.0 --port 8002"
        Port = 8002
        Color = "Magenta"
    }
    @{
        Name = "Deepfake Detection (FastAPI)"
        Title = "Deepfake Service"
        Command = "cd $ROOT && python -m uvicorn backend.services.deepfake-detection-service.main:app --reload --host 0.0.0.0 --port 8003"
        Port = 8003
        Color = "Red"
    }
    @{
        Name = "Emergency Response (FastAPI)"
        Title = "Emergency Service"
        Command = "cd $ROOT && python -m uvicorn backend.services.emergency-response-service.main:app --reload --host 0.0.0.0 --port 8004"
        Port = 8004
        Color = "DarkYellow"
    }
    @{
        Name = "Graph Intelligence (FastAPI)"
        Title = "Graph Service"
        Command = "cd $ROOT && python -m uvicorn backend.services.graph-intelligence-service.main:app --reload --host 0.0.0.0 --port 8005"
        Port = 8005
        Color = "DarkCyan"
    }
)

# ===== LAUNCH ALL SERVICES =====
Write-Host "========================================" -ForegroundColor White
Write-Host "   CyberShield AI - Starting All Services " -ForegroundColor White
Write-Host "========================================" -ForegroundColor White
Write-Host ""

foreach ($svc in $services) {
    Write-Host "[STARTING] $($svc.Name) on port $($svc.Port)..." -ForegroundColor $svc.Color
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "& { $($svc.Command) }" -WindowStyle Normal
    Start-Sleep -Seconds 2
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "   All services launched!                " -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Service Port Map:" -ForegroundColor White
Write-Host "  Backend Gateway  : http://localhost:5000" -ForegroundColor Cyan
Write-Host "  AI Gateway       : http://localhost:8000" -ForegroundColor Green
Write-Host "  Auth Service     : http://localhost:5001" -ForegroundColor Yellow
Write-Host "  Bank Service     : http://localhost:8002" -ForegroundColor Magenta
Write-Host "  Deepfake         : http://localhost:8003" -ForegroundColor Red
Write-Host "  Emergency        : http://localhost:8004" -ForegroundColor DarkYellow
Write-Host "  Graph Intelligence: http://localhost:8005" -ForegroundColor DarkCyan
Write-Host ""
Write-Host "Health Checks:" -ForegroundColor White
Write-Host "  curl http://localhost:5000" -ForegroundColor Gray
Write-Host "  curl http://localhost:8000/health" -ForegroundColor Gray
Write-Host "  curl http://localhost:5001/health" -ForegroundColor Gray
Write-Host "  curl http://localhost:8002/health" -ForegroundColor Gray
Write-Host "  curl http://localhost:8003/health" -ForegroundColor Gray
Write-Host "  curl http://localhost:8004/health" -ForegroundColor Gray
Write-Host "  curl http://localhost:8005/health" -ForegroundColor Gray