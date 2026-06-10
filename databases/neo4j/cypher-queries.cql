// ==========================================
// CYBERSHIELD AI - Neo4j Graph Intelligence
// Threat Intelligence Graph Queries
// ==========================================

// ============ CONSTRAINTS ============

CREATE CONSTRAINT unique_phone IF NOT EXISTS FOR (p:Phone) REQUIRE p.value IS UNIQUE;
CREATE CONSTRAINT unique_upi IF NOT EXISTS FOR (u:UPI) REQUIRE u.value IS UNIQUE;
CREATE CONSTRAINT unique_device IF NOT EXISTS FOR (d:Device) REQUIRE d.device_id IS UNIQUE;
CREATE CONSTRAINT unique_case IF NOT EXISTS FOR (c:Case) REQUIRE c.case_id IS UNIQUE;

// ============ INDEXES ============

CREATE INDEX phone_risk IF NOT EXISTS FOR (p:Phone) ON (p.risk_score);
CREATE INDEX case_status IF NOT EXISTS FOR (c:Case) ON (c.status);
CREATE INDEX scammer_id IF NOT EXISTS FOR (s:Scammer) ON (s.scammer_id);

// ============ NODE CREATION ============

// Create phone node
MERGE (p:Phone {value: $phone_number})
ON CREATE SET 
  p.risk_score = $risk_score,
  p.status = $status,
  p.created_at = timestamp(),
  p.report_count = 1
ON MATCH SET 
  p.risk_score = p.risk_score + $risk_score / 2,
  p.report_count = p.report_count + 1;

// Create UPI node
MERGE (u:UPI {value: $upi_id})
ON CREATE SET 
  u.risk_score = $risk_score,
  u.bank = $bank_name,
  u.created_at = timestamp();

// Create device node
MERGE (d:Device {device_id: $device_id})
ON CREATE SET 
  d.device_type = $device_type,
  d.fingerprint = $fingerprint,
  d.created_at = timestamp();

// ============ RELATIONSHIP CREATION ============

// Phone called another phone (fraud call)
MATCH (caller:Phone {value: $caller}), (receiver:Phone {value: $receiver})
MERGE (caller)-[r:CALLED {
  call_id: $call_id,
  duration: $duration,
  timestamp: $timestamp,
  risk_score: $risk_score
}]->(receiver);

// UPI transaction between accounts
MATCH (from_phone:Phone {value: $from_phone}), (to_upi:UPI {value: $to_upi})
MERGE (from_phone)-[r:TRANSFERRED {
  transaction_id: $transaction_id,
  amount: $amount,
  timestamp: $timestamp,
  risk_score: $risk_score
}]->(to_upi);

// Phone linked to device
MATCH (p:Phone {value: $phone}), (d:Device {device_id: $device_id})
MERGE (p)-[r:USES {
  first_seen: $timestamp,
  last_seen: $timestamp
}]->(d);

// Citizen reported fraud
MATCH (c:Citizen {citizen_id: $citizen_id}), (case:Case {case_id: $case_id})
MERGE (c)-[r:REPORTED {
  report_id: $report_id,
  timestamp: $timestamp
}]->(case);

// Phone linked to case
MATCH (p:Phone {value: $phone}), (c:Case {case_id: $case_id})
MERGE (p)-[r:LINKED_TO {
  role: $role,
  timestamp: $timestamp
}]->(c);

// ============ FRAUD RING DETECTION ============

// Find fraud rings (shared devices)
MATCH (p1:Phone)-[:USES]->(d:Device)<-[:USES]-(p2:Phone)
WHERE p1 <> p2
WITH d, collect(DISTINCT p1) + collect(DISTINCT p2) AS phones
WHERE size(phones) >= 3
RETURN d.device_id AS shared_device,
       [p IN phones | p.value] AS phone_numbers,
       size(phones) AS phone_count
ORDER BY phone_count DESC;

// Find fraud clusters (common UPI targets)
MATCH (p:Phone)-[:TRANSFERRED]->(u:UPI)<-[:TRANSFERRED]-(other:Phone)
WHERE p <> other AND u.risk_score > 60
RETURN u.value AS upi_id,
       collect(DISTINCT p.value) AS senders,
       count(DISTINCT other) AS victim_count,
       u.risk_score
ORDER BY victim_count DESC;

// Detect call networks
MATCH path = (p:Phone)-[:CALLED*1..3]-(other:Phone)
WHERE p.risk_score > 70
RETURN path, p.value AS source, other.value AS target
LIMIT 100;

// ============ SHORTEST PATH ANALYSIS ============

// Find connection between two entities
MATCH path = shortestPath(
  (start {value: $from_value})-[*..6]-(end {value: $to_value})
)
WHERE start:Phone OR start:UPI
  AND end:Phone OR end:UPI
RETURN [node IN nodes(path) | labels(node)[0] + ": " + node.value] AS path_nodes,
       [rel IN relationships(path) | type(rel)] AS relationships,
       length(path) AS path_length;

// ============ FRAUD NETWORK VISUALIZATION ============

// Full network around a phone number
MATCH (p:Phone {value: $phone})
OPTIONAL MATCH (p)-[r1:CALLED|TRANSFERRED|USES]-(connected)
OPTIONAL MATCH (connected)-[r2:CALLED|TRANSFERRED]-(extended)
WHERE connected IS NOT NULL
RETURN p AS source,
       collect(DISTINCT {
         node: connected,
         relationship: type(r1),
         extended: collect(DISTINCT {
           node: extended,
           relationship: type(r2)
         })
       }) AS connections;

// ============ RISK AGGREGATION ============

// Calculate aggregate risk for a phone
MATCH (p:Phone {value: $phone})
OPTIONAL MATCH (p)-[:CALLED|TRANSFERRED]-(connected)
WITH p, count(DISTINCT connected) AS connection_count
OPTIONAL MATCH (p)-[:LINKED_TO]->(c:Case)
WITH p, connection_count, count(c) AS case_count
SET p.aggregate_risk = 
  p.risk_score * 0.4 +
  (CASE WHEN connection_count > 10 THEN 20 ELSE connection_count * 2 END) * 0.3 +
  (CASE WHEN case_count > 5 THEN 25 ELSE case_count * 5 END) * 0.3
RETURN p.value AS phone,
       p.risk_score,
       connection_count,
       case_count,
       p.aggregate_risk;

// ============ CAMPAIGN DETECTION ============

// Detect coordinated fraud campaigns
MATCH (p:Phone)-[:CALLED]->(victim:Phone)
WHERE p.risk_score > 60
WITH p, collect(victim.value) AS victims, count(victim) AS victim_count
WHERE victim_count >= 5
MATCH (p)-[:USES]->(d:Device)
RETURN p.value AS scammer_phone,
       victim_count,
       victims[0..10] AS sample_victims,
       d.device_id AS device,
       p.risk_score
ORDER BY victim_count DESC
LIMIT 20;

// ============ EVIDENCE CHAIN ============

// Build evidence chain for a case
MATCH (c:Case {case_id: $case_id})
OPTIONAL MATCH (evidence:Evidence)-[:PART_OF]->(c)
OPTIONAL MATCH (p:Phone)-[:LINKED_TO]->(c)
OPTIONAL MATCH (citizen:Citizen)-[:REPORTED]->(c)
RETURN c.case_id,
       collect(DISTINCT evidence.evidence_id) AS evidence_ids,
       collect(DISTINCT p.value) AS phone_numbers,
       collect(DISTINCT citizen.citizen_id) AS reporters;

// ============ CLEANUP ============

// Remove inactive nodes (risk_score < 10, no activity in 90 days)
MATCH (p:Phone)
WHERE p.risk_score < 10 AND p.updated_at < timestamp() - 7776000000
DETACH DELETE p;

// ============ SEARCH ============

// Search across all entities
MATCH (n)
WHERE ANY(label IN labels(n) WHERE label IN ['Phone', 'UPI', 'Device', 'WhatsApp'])
  AND n.value CONTAINS $search_term
RETURN labels(n)[0] AS type, n.value AS value, n.risk_score AS risk
ORDER BY risk DESC
LIMIT 20;