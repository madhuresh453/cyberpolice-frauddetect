# Kill process on port 8000
$connections = netstat -ano | Select-String ':8000.*LISTEN'
foreach ($line in $connections) {
    $parts = $line -split '\s+'
    $pid = $parts[-1]
    if ($pid -match '^\d+$') {
        Write-Host "Killing PID $pid on port 8000"
        taskkill /PID $pid /F 2>$null
    }
}
Start-Sleep -Seconds 2
Write-Host "Restarting AI Gateway..."
Start-Process python -ArgumentList 'ai/ai-gateway.py' -WindowStyle Hidden
Start-Sleep -Seconds 4
Write-Host "AI Gateway restarted."