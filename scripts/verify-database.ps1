param(
    [string]$MongoUri = $env:MONGODB_URI,
    [string]$DbName = $env:DB_NAME
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CYBERSHIELD-AI Database Verification  " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$requiredCollections = @(
    "users", "roles", "permissions", "sessions", "refresh_tokens", "api_keys",
    "citizens", "familymembers", "citizen_profiles", "blockednumbers", "saved_evidence",
    "policeofficers", "police_departments", "cases", "firs", "investigations",
    "isp_operators", "telecom_providers", "traffic_logs", "sms_logs",
    "fraud_reports", "fraud_numbers", "fraud_upi_ids", "fraud_bank_accounts", "fraud_websites", "fraud_apps",
    "call_analysis", "sms_analysis", "whatsapp_analysis", "deepfake_analysis", "campaign_detection",
    "emergency_sos", "emergency_contacts", "emergency_sessions",
    "bank_accounts", "freeze_requests", "upi_verifications",
    "threat_campaigns", "ioc_feeds", "threat_indicators",
    "evidence_files", "evidence_metadata", "chain_of_custody",
    "trust_scores", "risk_scores", "heatmap_data", "fraud_statistics",
    "audit_logs", "notifications", "activity_logs"
)

$requiredIndexes = @(
    "phoneNumber", "upiId", "aadhaarHash", "deviceId", "userId",
    "caseId", "firId", "reportId", "status", "riskScore",
    "createdAt", "updatedAt", "location", "district", "state",
    "fraudType", "trustScore"
)

Write-Host "Checking MongoDB connection..." -ForegroundColor Yellow
try {
    $mongo = New-Object -TypeName "MongoDB.Driver.MongoClient" -ArgumentList $MongoUri
    $database = $mongo.GetDatabase($DbName)
    Write-Host "  [PASS] MongoDB connected successfully" -ForegroundColor Green
} catch {
    Write-Host "  [FAIL] MongoDB connection failed: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "--- Collection Verification ---" -ForegroundColor Cyan
$collections = $database.ListCollectionNames().ToList()
$found = 0
$missing = @()

foreach ($col in $requiredCollections) {
    if ($collections -contains $col) {
        $count = $database.GetCollection($col).CountDocuments($null)
        Write-Host "  [PASS] $col ($count documents)" -ForegroundColor Green
        $found++
    } else {
        Write-Host "  [FAIL] $col - NOT FOUND" -ForegroundColor Red
        $missing += $col
    }
}

Write-Host ""
Write-Host "Collections: $found/$($requiredCollections.Count) present" -ForegroundColor $(
    if ($found -eq $requiredCollections.Count) { "Green" } else { "Yellow" }
)

if ($missing.Count -gt 0) {
    Write-Host "Missing collections: $($missing -join ', ')" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "--- Index Verification ---" -ForegroundColor Cyan

$indexCount = 0
foreach ($col in $requiredCollections) {
    if ($collections -contains $col) {
        $indexes = $database.GetCollection($col).Indexes.List().ToList()
        $indexNames = $indexes | ForEach-Object { $_.Name }
        foreach ($idx in $requiredIndexes) {
            if ($indexNames -match $idx) {
                $indexCount++
            }
        }
    }
}

Write-Host "  Indexes verified across collections" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  VERIFICATION COMPLETE" -ForegroundColor $(
    if ($found -eq $requiredCollections.Count) { "Green" } else { "Yellow" }
)
Write-Host "  Collections: $found/$($requiredCollections.Count)" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan