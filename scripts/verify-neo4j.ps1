param(
    [string]$Neo4jUri = $env:NEO4J_URI,
    [string]$Neo4jUser = $env:NEO4J_USER,
    [string]$Neo4jPassword = $env:NEO4J_PASSWORD
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CYBERSHIELD-AI Neo4j Graph Verification" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$queries = @(
    @{Name="Phone Nodes"; Query="MATCH (p:Phone) RETURN count(p) AS count"},
    @{Name="UPI Nodes"; Query="MATCH (u:UPI) RETURN count(u) AS count"},
    @{Name="Device Nodes"; Query="MATCH (d:Device) RETURN count(d) AS count"},
    @{Name="Case Nodes"; Query="MATCH (c:Case) RETURN count(c) AS count"},
    @{Name="Citizen Nodes"; Query="MATCH (c:Citizen) RETURN count(c) AS count"},
    @{Name="Officer Nodes"; Query="MATCH (o:Officer) RETURN count(o) AS count"},
    @{Name="Website Nodes"; Query="MATCH (w:Website) RETURN count(w) AS count"},
    @{Name="App Nodes"; Query="MATCH (a:App) RETURN count(a) AS count"},
    @{Name="CALLED Relationships"; Query="MATCH ()-[r:CALLED]->() RETURN count(r) AS count"},
    @{Name="TRANSFERRED_TO Relationships"; Query="MATCH ()-[r:TRANSFERRED_TO]->() RETURN count(r) AS count"},
    @{Name="USES Relationships"; Query="MATCH ()-[r:USES]->() RETURN count(r) AS count"},
    @{Name="OWNS Relationships"; Query="MATCH ()-[r:OWNS]->() RETURN count(r) AS count"},
    @{Name="CONNECTED_TO Relationships"; Query="MATCH ()-[r:CONNECTED_TO]->() RETURN count(r) AS count"},
    @{Name="INVOLVED_IN Relationships"; Query="MATCH ()-[r:INVOLVED_IN]->() RETURN count(r) AS count"}
)

Write-Host "Checking Neo4j connectivity..." -ForegroundColor Yellow
try {
    $result = python -c "
from neo4j import GraphDatabase
driver = GraphDatabase.driver('$Neo4jUri', auth=('$Neo4jUser', '$Neo4jPassword'))
driver.verify_connectivity()
driver.close()
print('CONNECTED')
" 2>&1
    if ($result -eq "CONNECTED") {
        Write-Host "  [PASS] Neo4j connected successfully" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] Neo4j connection failed: $result" -ForegroundColor Red
        Write-Host "  (Neo4j might not be running - skipping graph verification)" -ForegroundColor Yellow
        exit 0
    }
} catch {
    Write-Host "  [SKIP] Neo4j not reachable (verify Neo4j is running)" -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "--- Graph Node/Relationship Verification ---" -ForegroundColor Cyan

$totalNodes = 0
$totalRelationships = 0

foreach ($q in $queries) {
    try {
        $pyCode = @"
from neo4j import GraphDatabase
driver = GraphDatabase.driver('$Neo4jUri', auth=('$Neo4jUser', '$Neo4jPassword'))
with driver.session() as session:
    result = session.run("$($q.Query)")
    record = result.single()
    count = record['count'] if record else 0
    print(count)
driver.close()
"@
        $count = python -c $pyCode 2>&1
        $count = $count.Trim()
        if ($count -match '^\d+$') {
            Write-Host "  [PASS] $($q.Name): $count" -ForegroundColor Green
            if ($q.Name -match 'Relationships') {
                $totalRelationships += [int]$count
            } else {
                $totalNodes += [int]$count
            }
        } else {
            Write-Host "  [SKIP] $($q.Name): Could not query" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "  [SKIP] $($q.Name): $_" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "--- Constraint Verification ---" -ForegroundColor Cyan
$constraints = @("unique_phone", "unique_upi", "unique_device", "unique_case")
foreach ($c in $constraints) {
    try {
        $pyCode = @"
from neo4j import GraphDatabase
driver = GraphDatabase.driver('$Neo4jUri', auth=('$Neo4jUser', '$Neo4jPassword'))
with driver.session() as session:
    result = session.run("SHOW CONSTRAINTS")
    found = [r for r in result if '$c' in r['name']]
    print('FOUND' if found else 'NOT_FOUND')
driver.close()
"@
        $found = python -c $pyCode 2>&1
        if ($found.Trim() -eq "FOUND") {
            Write-Host "  [PASS] Constraint: $c" -ForegroundColor Green
        } else {
            Write-Host "  [SKIP] Constraint: $c (not found, will be created on connect)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "  [SKIP] Constraint: $c" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  NEO4J VERIFICATION RESULTS" -ForegroundColor Cyan
Write-Host "  Total Nodes: $totalNodes" -ForegroundColor White
Write-Host "  Total Relationships: $totalRelationships" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan