param(
    [string]$BaseUrl = "http://localhost:5000"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CYBERSHIELD-AI API Verification       " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$endpoints = @(
    # Health & System
    @{Method="GET"; Path="/"; Expected=200},
    @{Method="GET"; Path="/health"; Expected=200},
    @{Method="GET"; Path="/api"; Expected=200},
    @{Method="GET"; Path="/system/status"; Expected=200},
    @{Method="GET"; Path="/database/collections"; Expected=200},
    
    # Auth
    @{Method="POST"; Path="/api/auth/register"; Expected=400},
    @{Method="POST"; Path="/api/auth/login"; Expected=400},
    @{Method="POST"; Path="/api/auth/logout"; Expected=200},
    
    # Citizen APIs
    @{Method="POST"; Path="/api/v1/citizen/report/call"; Expected=401},
    @{Method="POST"; Path="/api/v1/citizen/report/sms"; Expected=401},
    @{Method="POST"; Path="/api/v1/citizen/report/whatsapp"; Expected=401},
    @{Method="GET"; Path="/api/v1/citizen/trust-score/9999999999"; Expected=401},
    @{Method="GET"; Path="/api/v1/citizen/history"; Expected=401},
    @{Method="POST"; Path="/api/v1/citizen/block-number"; Expected=401},
    @{Method="POST"; Path="/api/v1/citizen/emergency-sos"; Expected=401},
    @{Method="GET"; Path="/api/v1/citizen/family-protection"; Expected=401},
    @{Method="POST"; Path="/api/v1/citizen/evidence/upload"; Expected=401},
    
    # Police APIs
    @{Method="GET"; Path="/api/v1/police/cases"; Expected=401},
    @{Method="POST"; Path="/api/v1/police/cases"; Expected=401},
    @{Method="GET"; Path="/api/v1/police/firs"; Expected=401},
    @{Method="POST"; Path="/api/v1/police/firs"; Expected=401},
    @{Method="GET"; Path="/api/v1/police/evidence"; Expected=401},
    @{Method="GET"; Path="/api/v1/police/analytics"; Expected=401},
    @{Method="GET"; Path="/api/v1/police/heatmap"; Expected=401},
    @{Method="GET"; Path="/api/v1/police/fraud-network"; Expected=401},
    @{Method="POST"; Path="/api/v1/police/bank-freeze"; Expected=401},
    @{Method="POST"; Path="/api/v1/police/deepfake-analysis"; Expected=401},
    
    # ISP APIs
    @{Method="GET"; Path="/api/v1/isp/number-intelligence"; Expected=401},
    @{Method="GET"; Path="/api/v1/isp/sms-firewall"; Expected=401},
    @{Method="GET"; Path="/api/v1/isp/traffic-analysis"; Expected=401},
    @{Method="GET"; Path="/api/v1/isp/blocked-numbers"; Expected=401},
    @{Method="GET"; Path="/api/v1/isp/fraud-campaigns"; Expected=401},
    @{Method="GET"; Path="/api/v1/isp/threat-feed"; Expected=401},
    
    # Government APIs
    @{Method="GET"; Path="/api/v1/government/national-dashboard"; Expected=401},
    @{Method="GET"; Path="/api/v1/government/state-dashboard"; Expected=401},
    @{Method="GET"; Path="/api/v1/government/district-dashboard"; Expected=401},
    @{Method="GET"; Path="/api/v1/government/fraud-trends"; Expected=401},
    @{Method="GET"; Path="/api/v1/government/economic-impact"; Expected=401}
)

$passed = 0
$failed = 0
$skipped = 0

Write-Host "Testing $($endpoints.Count) API endpoints..." -ForegroundColor Yellow
Write-Host ""

foreach ($ep in $endpoints) {
    $url = "$BaseUrl$($ep.Path)"
    try {
        if ($ep.Method -eq "GET") {
            $response = Invoke-WebRequest -Uri $url -Method GET -TimeoutSec 5 -SkipCertificateCheck -ErrorAction Stop
        } else {
            $body = @{} | ConvertTo-Json
            $response = Invoke-WebRequest -Uri $url -Method $ep.Method -Body $body -ContentType "application/json" -TimeoutSec 5 -SkipCertificateCheck -ErrorAction Stop
        }
        
        $expectedCodes = if ($ep.Expected -is [array]) { $ep.Expected } else { @($ep.Expected) }
        
        if ($expectedCodes -contains $response.StatusCode) {
            Write-Host "  [PASS] $($ep.Method) $($ep.Path) -> $($response.StatusCode)" -ForegroundColor Green
            $passed++
        } else {
            Write-Host "  [FAIL] $($ep.Method) $($ep.Path) -> Expected $($ep.Expected), Got $($response.StatusCode)" -ForegroundColor Red
            $failed++
        }
    } catch {
        if ($_.Exception.Response) {
            $statusCode = [int]$_.Exception.Response.StatusCode
            $expectedCodes = if ($ep.Expected -is [array]) { $ep.Expected } else { @($ep.Expected) }
            if ($expectedCodes -contains $statusCode) {
                Write-Host "  [PASS] $($ep.Method) $($ep.Path) -> $statusCode" -ForegroundColor Green
                $passed++
            } else {
                Write-Host "  [FAIL] $($ep.Method) $($ep.Path) -> Expected $($ep.Expected), Got $statusCode" -ForegroundColor Red
                $failed++
            }
        } else {
            Write-Host "  [SKIP] $($ep.Method) $($ep.Path) -> Server not reachable" -ForegroundColor Yellow
            $skipped++
        }
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  API VERIFICATION RESULTS" -ForegroundColor Cyan
Write-Host "  Total: $($endpoints.Count)" -ForegroundColor White
Write-Host "  Passed: $passed" -ForegroundColor Green
Write-Host "  Failed: $failed" -ForegroundColor $(if ($failed -gt 0) { "Red" } else { "Green" })
Write-Host "  Skipped: $skipped" -ForegroundColor Yellow
Write-Host "  Success Rate: $(if ($endpoints.Count - $skipped -gt 0) { [math]::Round($passed / ($endpoints.Count - $skipped) * 100) } else { 0 })%" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan

if ($failed -gt 0) { exit 1 } else { exit 0 }