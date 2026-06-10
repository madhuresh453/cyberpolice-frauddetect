$ErrorActionPreference = "Stop"

$requiredPaths = @(
  "apps/citizen-android/README.md",
  "apps/police-portal/package.json",
  "apps/isp-portal/package.json",
  "backend/services/api-gateway/pyproject.toml",
  "backend/services/websocket-service/pyproject.toml",
  "ai/risk-scoring-engine/pyproject.toml",
  "databases/postgres/README.md",
  "infrastructure/kubernetes/README.md",
  "government-integrations/sanchar-saathi/README.md",
  "docs/README.md",
  "docker-compose.yml",
  "package.json",
  "pnpm-workspace.yaml",
  "pyproject.toml",
  ".env.example"
)

$missing = @()
foreach ($path in $requiredPaths) {
  if (-not (Test-Path -LiteralPath (Join-Path (Resolve-Path ".") $path))) {
    $missing += $path
  }
}

if ($missing.Count -gt 0) {
  Write-Error ("Missing Phase 1 paths:`n" + ($missing -join "`n"))
}

Write-Host "Phase 1 verification passed: required scaffold paths exist."
