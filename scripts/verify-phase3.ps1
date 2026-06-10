$ErrorActionPreference = "Stop"

$required = @(
  "docs/MONGODB_ARCHITECTURE.md",
  "docs/COLLECTION_SCHEMA.md",
  "docs/INDEXING_STRATEGY.md",
  "docs/PHASE3_VERIFICATION_CHECKLIST.md",
  "README_AUTH.md",
  "backend/shared/database/database.py",
  "backend/shared/database/mongodb.py",
  "backend/shared/database/base_document.py",
  "backend/shared/database/documents.py",
  "backend/shared/repositories/mongodb_repository.py",
  "backend/services/auth-service/main.py",
  "backend/services/auth-service/Dockerfile",
  "backend/services/auth-service/requirements.txt",
  "backend/services/auth-service/routers/auth.py",
  "backend/services/auth-service/routers/users.py",
  "backend/services/auth-service/routers/roles.py",
  "backend/services/auth-service/routers/sessions.py",
  "backend/services/auth-service/services/auth_service.py",
  "backend/services/auth-service/services/token_service.py",
  "backend/services/auth-service/services/mfa_service.py",
  "backend/services/auth-service/services/session_service.py",
  "backend/services/auth-service/services/api_key_service.py",
  "backend/services/auth-service/services/audit_service.py",
  "backend/services/auth-service/middleware/jwt_middleware.py",
  "backend/services/auth-service/middleware/rbac_middleware.py",
  "backend/services/auth-service/middleware/rate_limit.py",
  "backend/services/auth-service/middleware/request_logger.py",
  "backend/services/auth-service/tests/test_auth.py",
  "backend/services/auth-service/tests/test_rbac.py",
  "backend/services/auth-service/tests/test_mfa.py",
  "backend/services/auth-service/tests/test_sessions.py"
)

$root = Resolve-Path "."
$missing = @()
foreach ($path in $required) {
  if (-not (Test-Path -LiteralPath (Join-Path $root $path))) {
    $missing += $path
  }
}
if ($missing.Count -gt 0) {
  Write-Error ("Missing Phase 3 files:`n" + ($missing -join "`n"))
}

$forbidden = rg -n "SQLAlchemy|Alembic|PostgreSQL|postgresql|psycopg|asyncpg" backend/services/auth-service backend/shared/database docs/MONGODB_ARCHITECTURE.md docs/COLLECTION_SCHEMA.md docs/INDEXING_STRATEGY.md
if ($LASTEXITCODE -eq 0) {
  Write-Error ("Forbidden relational dependency reference found:`n" + ($forbidden -join "`n"))
}

$pythonFiles = Get-ChildItem -Recurse -Filter *.py backend/shared/database,backend/shared/repositories,backend/services/auth-service | ForEach-Object { $_.FullName }
python -m py_compile $pythonFiles
if ($LASTEXITCODE -ne 0) {
  Write-Error "Python compilation failed."
}

Write-Host "Phase 3 verification passed: MongoDB migration docs and auth-service files compile."
