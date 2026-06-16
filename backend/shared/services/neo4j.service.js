import neo4j from "neo4j-driver";

let driver = null;

const NEO4J_CONFIG = {
  uri: process.env.NEO4J_URI || (process.env.NODE_ENV === "production" ? "bolt://neo4j:7687" : "bolt://localhost:7687"),
  username: process.env.NEO4J_USER || "neo4j",
  password: process.env.NEO4J_PASSWORD || "password"
};

export async function connectNeo4j() {
  if (driver) return driver;
  try {
    driver = neo4j.driver(
      NEO4J_CONFIG.uri,
      neo4j.auth.basic(NEO4J_CONFIG.username, NEO4J_CONFIG.password),
      { maxConnectionPoolSize: 10, connectionTimeout: 10000 }
    );
    await driver.verifyConnectivity();
    console.log(JSON.stringify({ level: "info", message: "Neo4j connected" }));
    await initializeConstraints();
    return driver;
  } catch (error) {
    console.warn(JSON.stringify({ level: "warn", message: "Neo4j connection failed", error: error.message }));
    return null;
  }
}

export function getNeo4jDriver() {
  return driver;
}

export async function disconnectNeo4j() {
  if (driver) {
    await driver.close();
    driver = null;
  }
}

async function executeQuery(cypher, params = {}) {
  if (!driver) return null;
  const session = driver.session();
  try {
    const result = await session.run(cypher, params);
    return result.records.map(r => {
      const obj = {};
      r.keys.forEach(key => {
        const val = r.get(key);
        obj[key] = val ? (val.properties || val) : null;
      });
      return obj;
    });
  } finally {
    await session.close();
  }
}

async function initializeConstraints() {
  const constraints = [
    "CREATE CONSTRAINT unique_phone IF NOT EXISTS FOR (p:Phone) REQUIRE p.value IS UNIQUE",
    "CREATE CONSTRAINT unique_upi IF NOT EXISTS FOR (u:UPI) REQUIRE u.value IS UNIQUE",
    "CREATE CONSTRAINT unique_device IF NOT EXISTS FOR (d:Device) REQUIRE d.device_id IS UNIQUE",
    "CREATE CONSTRAINT unique_case IF NOT EXISTS FOR (c:Case) REQUIRE c.case_id IS UNIQUE",
    "CREATE INDEX phone_risk IF NOT EXISTS FOR (p:Phone) ON (p.risk_score)",
    "CREATE INDEX case_status IF NOT EXISTS FOR (c:Case) ON (c.status)",
    "CREATE INDEX website_url IF NOT EXISTS FOR (w:Website) ON (w.url)",
    "CREATE INDEX app_package IF NOT EXISTS FOR (a:App) ON (a.package_name)"
  ];
  for (const cypher of constraints) {
    try {
      await executeQuery(cypher);
    } catch (err) {
      // Constraint may already exist
    }
  }
}

// Node creation operations
export async function createPhoneNode(phoneNumber, riskScore = 0, status = "unknown") {
  return executeQuery(
    `MERGE (p:Phone {value: $phone})
     ON CREATE SET p.risk_score = $risk, p.status = $status, p.created_at = timestamp(), p.report_count = 1, p.updated_at = timestamp()
     ON MATCH SET p.risk_score = CASE WHEN $risk > p.risk_score THEN $risk ELSE p.risk_score END,
                  p.report_count = p.report_count + 1, p.updated_at = timestamp()`,
    { phone: phoneNumber, risk: riskScore, status }
  );
}

export async function createUpiNode(upiId, riskScore = 0, bankName = null) {
  return executeQuery(
    `MERGE (u:UPI {value: $upi})
     ON CREATE SET u.risk_score = $risk, u.bank = $bank, u.created_at = timestamp(), u.updated_at = timestamp()
     ON MATCH SET u.risk_score = CASE WHEN $risk > u.risk_score THEN $risk ELSE u.risk_score END, u.updated_at = timestamp()`,
    { upi: upiId, risk: riskScore, bank: bankName }
  );
}

export async function createDeviceNode(deviceId, deviceType = null, fingerprint = null) {
  return executeQuery(
    `MERGE (d:Device {device_id: $deviceId})
     ON CREATE SET d.device_type = $type, d.fingerprint = $fingerprint, d.created_at = timestamp()`,
    { deviceId, type: deviceType, fingerprint }
  );
}

export async function createCitizenNode(citizenId, phoneNumber, fullName) {
  return executeQuery(
    `MERGE (c:Citizen {citizen_id: $id})
     ON CREATE SET c.phone = $phone, c.full_name = $name, c.created_at = timestamp()`,
    { id: citizenId, phone: phoneNumber, name: fullName }
  );
}

export async function createCaseNode(caseId, caseNumber, title, riskScore = 0) {
  return executeQuery(
    `MERGE (c:Case {case_id: $id})
     ON CREATE SET c.case_number = $number, c.title = $title, c.risk_score = $risk, c.status = 'open', c.created_at = timestamp()`,
    { id: caseId, number: caseNumber, title, risk: riskScore }
  );
}

export async function createOfficerNode(officerId, badgeNumber, fullName) {
  return executeQuery(
    `MERGE (o:Officer {officer_id: $id})
     ON CREATE SET o.badge = $badge, o.full_name = $name, o.created_at = timestamp()`,
    { id: officerId, badge: badgeNumber, name: fullName }
  );
}

export async function createWebsiteNode(url, riskScore = 0) {
  return executeQuery(
    `MERGE (w:Website {url: $url})
     ON CREATE SET w.risk_score = $risk, w.created_at = timestamp()`,
    { url, risk: riskScore }
  );
}

export async function createAppNode(packageName, appName, riskScore = 0) {
  return executeQuery(
    `MERGE (a:App {package_name: $pkg})
     ON CREATE SET a.app_name = $name, a.risk_score = $risk, a.created_at = timestamp()`,
    { pkg: packageName, name: appName, risk: riskScore }
  );
}

// Relationship creation operations
export async function createCalledRelationship(caller, receiver, callId, duration, riskScore = 0) {
  return executeQuery(
    `MATCH (caller:Phone {value: $caller}), (receiver:Phone {value: $receiver})
     MERGE (caller)-[r:CALLED {call_id: $callId}]->(receiver)
     ON CREATE SET r.duration = $duration, r.timestamp = timestamp(), r.risk_score = $risk
     ON MATCH SET r.duration = r.duration + $duration, r.count = CASE WHEN r.count IS NOT NULL THEN r.count + 1 ELSE 2 END`,
    { caller, receiver, callId, duration, risk: riskScore }
  );
}

export async function createTransferredRelationship(fromPhone, toUpi, transactionId, amount, riskScore = 0) {
  return executeQuery(
    `MATCH (p:Phone {value: $phone}), (u:UPI {value: $upi})
     MERGE (p)-[r:TRANSFERRED_TO {transaction_id: $txn}]->(u)
     ON CREATE SET r.amount = $amount, r.timestamp = timestamp(), r.risk_score = $risk`,
    { phone: fromPhone, upi: toUpi, txn: transactionId, amount, risk: riskScore }
  );
}

export async function createUsesRelationship(phone, deviceId, timestamp = Date.now()) {
  return executeQuery(
    `MATCH (p:Phone {value: $phone}), (d:Device {device_id: $deviceId})
     MERGE (p)-[r:USES]->(d)
     ON CREATE SET r.first_seen = $ts, r.last_seen = $ts
     ON MATCH SET r.last_seen = $ts`,
    { phone, deviceId, ts: timestamp }
  );
}

export async function createOwnsRelationship(citizenId, phone) {
  return executeQuery(
    `MATCH (c:Citizen {citizen_id: $id}), (p:Phone {value: $phone})
     MERGE (c)-[r:OWNS]->(p)
     ON CREATE SET r.since = timestamp()`,
    { id: citizenId, phone }
  );
}

export async function createConnectedToRelationship(entity1, entity2, type = "linked") {
  return executeQuery(
    `MATCH (a {value: $val1}), (b {value: $val2})
     MERGE (a)-[r:CONNECTED_TO {type: $type}]->(b)
     ON CREATE SET r.since = timestamp()`,
    { val1: entity1, val2: entity2, type }
  );
}

export async function createReportedByRelationship(citizenId, caseId, reportId) {
  return executeQuery(
    `MATCH (c:Citizen {citizen_id: $citizen}), (ca:Case {case_id: $case})
     MERGE (c)-[r:REPORTED_BY {report_id: $report}]->(ca)
     ON CREATE SET r.timestamp = timestamp()`,
    { citizen: citizenId, case: caseId, report: reportId }
  );
}

export async function createInvolvedInRelationship(phone, caseId, role = "suspect") {
  return executeQuery(
    `MATCH (p:Phone {value: $phone}), (c:Case {case_id: $case})
     MERGE (p)-[r:INVOLVED_IN]->(c)
     ON CREATE SET r.role = $role, r.timestamp = timestamp()`,
    { phone, case: caseId, role }
  );
}

export async function createInvestigatedByRelationship(caseId, officerId) {
  return executeQuery(
    `MATCH (c:Case {case_id: $case}), (o:Officer {officer_id: $officer})
     MERGE (c)-[r:INVESTIGATED_BY]->(o)
     ON CREATE SET r.since = timestamp()`,
    { case: caseId, officer: officerId }
  );
}

export async function createLinkedToRelationship(entity1, entity2, type = "linked") {
  return executeQuery(
    `MATCH (a {value: $val1}), (b {value: $val2})
     MERGE (a)-[r:LINKED_TO]->(b)
     ON CREATE SET r.type = $type, r.timestamp = timestamp()`,
    { val1: entity1, val2: entity2, type }
  );
}

// Graph queries
export async function detectFraudRings(minSharedDevices = 3) {
  return executeQuery(
    `MATCH (p1:Phone)-[:USES]->(d:Device)<-[:USES]-(p2:Phone)
     WHERE p1 <> p2
     WITH d, collect(DISTINCT p1) + collect(DISTINCT p2) AS phones
     WHERE size(phones) >= $min
     RETURN d.device_id AS shared_device,
            [p IN phones | p.value] AS phone_numbers,
            size(phones) AS phone_count,
            d.device_type AS device_type
     ORDER BY phone_count DESC
     LIMIT 50`,
    { min: minSharedDevices }
  );
}

export async function detectFraudClusters(minRiskScore = 60) {
  return executeQuery(
    `MATCH (p:Phone)-[:TRANSFERRED_TO]->(u:UPI)<-[:TRANSFERRED_TO]-(other:Phone)
     WHERE p <> other AND u.risk_score > $minRisk
     RETURN u.value AS upi_id,
            collect(DISTINCT p.value) AS senders,
            count(DISTINCT other) AS victim_count,
            u.risk_score AS risk_score,
            u.bank AS bank
     ORDER BY victim_count DESC
     LIMIT 50`,
    { minRisk: minRiskScore }
  );
}

export async function findShortestPath(fromValue, toValue, maxDepth = 6) {
  return executeQuery(
    `MATCH path = shortestPath(
       (start {value: $from})-[*..$depth]-(end {value: $to})
     )
     WHERE (start:Phone OR start:UPI) AND (end:Phone OR end:UPI)
     RETURN [node IN nodes(path) | labels(node)[0] + ': ' + node.value] AS path_nodes,
            [rel IN relationships(path) | type(rel)] AS relationships,
            length(path) AS path_length`,
    { from: fromValue, to: toValue, depth: maxDepth }
  );
}

export async function getFraudNetwork(phoneValue) {
  return executeQuery(
    `MATCH (p:Phone {value: $phone})
     OPTIONAL MATCH (p)-[r1:CALLED|TRANSFERRED_TO|USES|CONNECTED_TO|LINKED_TO]-(connected)
     OPTIONAL MATCH (connected)-[r2:CALLED|TRANSFERRED_TO]-(extended)
     WHERE connected IS NOT NULL
     RETURN p.value AS source_phone,
            p.risk_score AS source_risk,
            collect(DISTINCT {
              node: connected.value,
              type: labels(connected)[0],
              relationship: type(r1),
              extended: CASE WHEN extended IS NOT NULL THEN collect(DISTINCT {
                node: extended.value,
                type: labels(extended)[0],
                relationship: type(r2)
              }) ELSE [] END
            }) AS connections`,
    { phone: phoneValue }
  );
}

export async function detectHighRiskClusters(minRisk = 70) {
  return executeQuery(
    `MATCH (p:Phone)-[:CALLED|TRANSFERRED_TO*1..2]-(connected)
     WHERE p.risk_score > $minRisk
     WITH p, collect(DISTINCT connected) AS network, count(DISTINCT connected) AS network_size
     WHERE network_size >= 3
     RETURN p.value AS phone,
            p.risk_score AS risk_score,
            network_size,
            [n IN network | n.value] AS connected_entities,
            p.report_count AS report_count
     ORDER BY risk_score DESC, network_size DESC
     LIMIT 50`,
    { minRisk }
  );
}

export async function detectScamCampaigns(minAffected = 5) {
  return executeQuery(
    `MATCH (p:Phone)-[:CALLED]->(victim:Phone)
     WHERE p.risk_score > 60
     WITH p, collect(victim.value) AS victims, count(victim) AS victim_count
     WHERE victim_count >= $minAffected
     OPTIONAL MATCH (p)-[:USES]->(d:Device)
     RETURN p.value AS scammer_phone,
            victim_count,
            victims[0..20] AS sample_victims,
            d.device_id AS device_id,
            p.risk_score AS risk_score,
            p.report_count AS report_count
     ORDER BY victim_count DESC
     LIMIT 20`,
    { minAffected }
  );
}

export async function getCommunityDetection() {
  return executeQuery(
    `CALL gds.louvain.stream('fraud-graph')
     YIELD nodeId, communityId, intermediateCommunityIds
     MATCH (n) WHERE id(n) = nodeId
     RETURN communityId, collect(labels(n)[0] + ': ' + COALESCE(n.value, n.device_id, n.url)) AS members
     ORDER BY communityId`
  );
}

export async function getCentralityAnalysis() {
  return executeQuery(
    `MATCH (p:Phone)
     WHERE p.risk_score > 50
     OPTIONAL MATCH (p)-[r]-()
     WITH p, count(r) AS degree, p.risk_score AS risk
     RETURN p.value AS phone, degree, risk, (degree * 0.5 + risk * 0.5) AS centrality
     ORDER BY centrality DESC
     LIMIT 100`
  );
}

export async function getAggregateRisk(phoneValue) {
  return executeQuery(
    `MATCH (p:Phone {value: $phone})
     OPTIONAL MATCH (p)-[:CALLED|TRANSFERRED_TO]-(connected)
     WITH p, count(DISTINCT connected) AS connection_count
     OPTIONAL MATCH (p)-[:INVOLVED_IN]->(c:Case)
     WITH p, connection_count, count(c) AS case_count
     OPTIONAL MATCH (p)-[:LINKED_TO]->(c2:Case)
     WITH p, connection_count, case_count, count(c2) AS linked_case_count
     RETURN p.value AS phone,
            p.risk_score,
            connection_count,
            case_count + linked_case_count AS total_case_count,
            (p.risk_score * 0.4 + 
             CASE WHEN connection_count > 10 THEN 20 ELSE connection_count * 2 END * 0.3 +
             CASE WHEN (case_count + linked_case_count) > 5 THEN 25 ELSE (case_count + linked_case_count) * 5 END * 0.3
            ) AS aggregate_risk`
  );
}

export async function searchGraph(searchTerm) {
  return executeQuery(
    `MATCH (n)
     WHERE ANY(label IN labels(n) WHERE label IN ['Phone', 'UPI', 'Device', 'Website', 'App', 'Citizen'])
       AND n.value CONTAINS $search
     RETURN labels(n)[0] AS type, n.value AS value, n.risk_score AS risk
     ORDER BY risk DESC
     LIMIT 20`,
    { search: searchTerm }
  );
}

export async function getGraphHealth() {
  if (!driver) return { connected: false };
  try {
    await driver.verifyConnectivity();
    const counts = await executeQuery(
      `MATCH (n) RETURN labels(n)[0] AS type, count(n) AS count
       UNION ALL
       MATCH ()-[r]->() RETURN type(r) AS type, count(r) AS count`
    );
    return { connected: true, stats: counts };
  } catch {
    return { connected: false };
  }
}