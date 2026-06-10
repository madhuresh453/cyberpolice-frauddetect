$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")

$readmes = @{
  "apps" = "Application workspaces for citizen, police, and ISP user experiences."
  "apps/citizen-android" = "Citizen Android application built with Kotlin, Jetpack Compose, MVVM, Hilt, Room, Retrofit, and WorkManager."
  "apps/police-portal" = "Police investigation portal built with Next.js, TypeScript, Tailwind CSS, ShadCN UI, and React Query."
  "apps/isp-portal" = "ISP intelligence portal built with Next.js, TypeScript, Tailwind CSS, ShadCN UI, and React Query."
  "backend" = "Backend workspace for FastAPI services, shared libraries, contracts, and operational adapters."
  "backend/services" = "Independently deployable backend service boundaries."
  "ai" = "AI and ML workspace for speech, text, fraud, risk, deepfake, and MLOps engines."
  "databases" = "Database schemas, migrations, seeds, and engine-specific configuration."
  "databases/postgres" = "Primary relational schema for identity, cases, reports, analysis, evidence, notifications, API keys, sessions, and audit logs."
  "databases/redis" = "Redis configuration for caching, rate limiting, queues, and ephemeral session metadata."
  "databases/mongo" = "MongoDB configuration for document-oriented evidence metadata and operational records."
  "databases/neo4j" = "Neo4j graph database workspace for fraud relationship intelligence."
  "infrastructure" = "Infrastructure-as-code, containers, networking, and observability configuration."
  "infrastructure/docker" = "Docker build and runtime configuration."
  "infrastructure/kubernetes" = "Kubernetes manifests and deployment overlays."
  "infrastructure/terraform" = "Terraform modules for cloud infrastructure."
  "infrastructure/nginx" = "Nginx ingress and reverse proxy configuration."
  "infrastructure/monitoring" = "Prometheus, Grafana, Loki, Jaeger, and OpenTelemetry configuration."
  "government-integrations" = "Adapters for approved government and regulated ecosystem integrations."
  "government-integrations/sanchar-saathi" = "Sanchar Saathi integration boundary for approved reporting workflows."
  "government-integrations/trai" = "TRAI integration boundary for approved telecom workflows."
  "government-integrations/cert-in" = "CERT-In integration boundary for approved cyber incident workflows."
  "government-integrations/cybercrime-portal" = "National Cyber Crime Reporting Portal integration boundary."
  "government-integrations/npci" = "NPCI integration boundary for approved UPI fraud workflows."
  "government-integrations/emergency-1930" = "Emergency 1930 integration boundary for approved escalation workflows."
  "docs" = "Architecture, contracts, security, operations, and implementation documentation."
  "scripts" = "Development, verification, migration, seed, and operational scripts."
  "tests" = "Cross-service integration, contract, and verification tests."
}

$services = @(
  "api-gateway", "auth-service", "citizen-service", "police-service", "isp-service",
  "scam-analysis-service", "sms-analysis-service", "whatsapp-analysis-service",
  "upi-fraud-service", "deepfake-detection-service", "campaign-correlation-service",
  "threat-intelligence-service", "threat-graph-service", "evidence-service",
  "notification-service", "reporting-service", "analytics-service", "audit-service",
  "file-storage-service", "websocket-service"
)

$aiModules = @(
  "speech-to-text", "scam-classification", "deepfake-detection", "keyword-engine",
  "intent-analysis", "sentiment-analysis", "fraud-pattern-engine", "risk-scoring-engine",
  "mlops"
)

foreach ($service in $services) {
  $readmes["backend/services/$service"] = "$service service boundary. Phase 4 will add routes, controllers, schemas, repositories, middleware, tests, and container packaging."
}

foreach ($module in $aiModules) {
  $readmes["ai/$module"] = "$module AI module boundary. Phase 5 will add production inference, training, evaluation, and serving code where applicable."
}

foreach ($entry in $readmes.GetEnumerator()) {
  $dir = Join-Path $root $entry.Key
  New-Item -ItemType Directory -Force -Path $dir | Out-Null
  $name = Split-Path $entry.Key -Leaf
  if ($name -eq "") { $name = "CYBERSHIELD AI" }
  $title = ($name -replace "-", " ").ToUpperInvariant()
  $body = "# $title`n`n$($entry.Value)`n`n## Phase Status`n`n- Phase 1: directory, README, and baseline manifest created.`n"
  Set-Content -LiteralPath (Join-Path $dir "README.md") -Value $body -Encoding UTF8
}

$portalPackage = @{
  scripts = @{
    dev = "next dev"
    build = "next build"
    start = "next start"
    lint = "next lint"
    test = "vitest run"
  }
  dependencies = @{
    "@tanstack/react-query" = "^5.66.0"
    "class-variance-authority" = "^0.7.1"
    "clsx" = "^2.1.1"
    "lucide-react" = "^0.468.0"
    "next" = "^15.1.0"
    "react" = "^19.0.0"
    "react-dom" = "^19.0.0"
    "tailwind-merge" = "^2.5.5"
  }
  devDependencies = @{
    "@types/node" = "^22.10.0"
    "@types/react" = "^19.0.0"
    "@types/react-dom" = "^19.0.0"
    "eslint" = "^9.16.0"
    "eslint-config-next" = "^15.1.0"
    "tailwindcss" = "^3.4.16"
    "typescript" = "^5.7.2"
    "vitest" = "^2.1.8"
  }
}

foreach ($portal in @("police-portal", "isp-portal")) {
  $pkg = $portalPackage.Clone()
  $pkg.name = "@cybershield/$portal"
  $pkg.version = "0.1.0"
  $pkg.private = $true
  $pkg.description = "CYBERSHIELD AI $portal application."
  $json = $pkg | ConvertTo-Json -Depth 8
  Set-Content -LiteralPath (Join-Path $root "apps/$portal/package.json") -Value $json -Encoding UTF8
}

Set-Content -LiteralPath (Join-Path $root "apps/citizen-android/settings.gradle.kts") -Value @"
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "CyberShieldAI"
include(":app")
"@ -Encoding UTF8

Set-Content -LiteralPath (Join-Path $root "apps/citizen-android/build.gradle.kts") -Value @"
plugins {
    id("com.android.application") version "8.7.3" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
    id("com.google.dagger.hilt.android") version "2.52" apply false
}
"@ -Encoding UTF8

foreach ($service in $services) {
  Set-Content -LiteralPath (Join-Path $root "backend/services/$service/pyproject.toml") -Value @"
[project]
name = "cybershield-$service"
version = "0.1.0"
requires-python = ">=3.11"
description = "CYBERSHIELD AI $service."

[tool.pytest.ini_options]
testpaths = ["tests"]
"@ -Encoding UTF8
}

foreach ($module in $aiModules) {
  Set-Content -LiteralPath (Join-Path $root "ai/$module/pyproject.toml") -Value @"
[project]
name = "cybershield-ai-$module"
version = "0.1.0"
requires-python = ">=3.11"
description = "CYBERSHIELD AI $module module."
"@ -Encoding UTF8
}

Write-Host "Phase 1 scaffold files generated."
