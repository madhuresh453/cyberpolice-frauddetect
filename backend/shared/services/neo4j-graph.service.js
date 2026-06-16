/**
 * RAKSAAR (CyberShield AI) - Graph Investigation Platform
 * Phase 13: Neo4j Graph Analytics
 *
 * Nodes: PhoneNumber, UPI, Device, Victim, Case, Officer
 * Relationships: CALLED, PAID_TO, OWNS, INVESTIGATED, REPORTED, CONNECTED_TO
 */
import neo4j from "neo4j-driver";

let driver = null;

const NEO4J_URI = process.env.NEO4J_URI || "bolt://localhost:7687";
const NEO4J_USER = process.env.NEO4J_USER || "neo4j";
const NEO4J_PASSWORD = process.env.NEO4J_PASSWORD || "raksaar_secret_2024";

export async function connectGraph() {
  if (driver) return driver;
  try {
    driver = neo4j.driver(NEO4J_URI, neo4j.auth.basic(NEO4J_USER, NEO4J_PASSWORD));
    await driver.verifyConnectivity();
    console.log("Neo4j graph database connected");
    return driver;
  } catch (e) {
    console.warn("Neo4j connection failed:", e.message);
    return null;
  }
}

export function getGraphDriver() {
  return driver;
}

export async function closeGraph() {
  if (driver) {
    await driver.close();
    driver = null;
  }
}

// ===== NODE CREATION =====

export async function createPhoneNode(phoneNumber, metadata = {}) {
  if (!driver) return null;
  const session = driver.session();
  try {
    const result = await session.run(
      `MERGE (p:PhoneNumber {phoneNumber: $phoneNumber})
       ON CREATE SET p.createdAt = datetime(), p.riskScore = $riskScore, p.reportsCount = $reportsCount
       ON MATCH SET p.lastSeen = datetime(), p.riskScore = $riskScore
       RETURN p`,
      { phoneNumber, riskScore: metadata.riskScore || 0, reportsCount: metadata.reportsCount || 0 }
    );
    return result.records[0]?.get("p")?.properties;
  } finally {
    await session.close();
  }
}

export async function createUpiNode(upiId, metadata = {}) {
  if (!driver) return null;
  const session = driver.session();
  try {
    const result = await session.run(
      `MERGE (u:UPI {upiId: $upiId})
       ON CREATE SET u.createdAt = datetime(), u.riskScore = $riskScore
       RETURN u`,
      { upiId, riskScore: metadata.riskScore || 0 }
    );
    return result.records[0]?.get("u")?.properties;
  } finally {
    await session.close();
  }
}

export async function createVictimNode(victimId, metadata = {}) {
  if (!driver) return null;
  const session = driver.session();
  try {
    const result = await session.run(
      `MERGE (v:Victim {victimId: $victimId})
       ON CREATE SET v.name = $name, v.phoneNumber = $phone, v.createdAt = datetime()
       RETURN v`,
      { victimId, name: metadata.name || "Unknown", phone: metadata.phone || "" }
    );
    return result.records[0]?.get("v")?.properties;
  } finally {
    await session.close();
  }
}

export async function createCaseNode(caseId, metadata = {}) {
  if (!driver) return null;
  const session = driver.session();
  try {
    const result = await session.run(
      `MERGE (c:Case {caseId: $caseId})
       ON CREATE SET c.title = $title, c.status = $status, c.riskScore = $riskScore, c.createdAt = datetime()
       RETURN c`,
      { caseId, title: metadata.title || "", status: metadata.status || "open", riskScore: metadata.riskScore || 0 }
    );
    return result.records[0]?.get("c")?.properties;
  } finally {
    await session.close();
  }
}

// ===== RELATIONSHIPS =====

export async function createRelationship(fromType, fromId, toType, toId, relType, properties = {}) {
  if (!driver) return null;
  const session = driver.session();
  try {
    const query = `
      MATCH (a:${fromType} {${fromType === "PhoneNumber" ? "phoneNumber" : fromType === "UPI" ? "upiId" : "victimId"}: $fromId})
      MATCH (b:${toType} {${toType === "PhoneNumber" ? "phoneNumber" : toType === "UPI" ? "upiId" : "caseId"}: $toId})
      MERGE (a)-[r:${relType}]->(b)
      ON CREATE SET r.timestamp = datetime(), r.count = 1
      ON MATCH SET r.count = coalesce(r.count, 0) + 1, r.lastSeen = datetime()
      RETURN r
    `;
    const result = await session.run(query, { fromId, toId });
    return result.records[0]?.get("r")?.properties;
  } finally {
    await session.close();
  }
}

// ===== QUERIES =====

export async function getFraudNetwork(phoneNumber, depth = 2) {
  if (!driver) return { nodes: [], links: [] };
  const session = driver.session();
  try {
    const result = await session.run(
      `
      MATCH (p:PhoneNumber {phoneNumber: $phoneNumber})
      OPTIONAL MATCH path = (p)-[*1..${depth}]-(connected)
      RETURN nodes(path) as nodes, relationships(path) as rels
      LIMIT 100
      `,
      { phoneNumber }
    );

    const nodes = new Map();
    const links = [];

    for (const record of result.records) {
      const recordNodes = record.get("nodes") || [];
      const recordRels = record.get("rels") || [];

      for (const node of recordNodes) {
        nodes.set(node.elementId, {
          id: node.elementId,
          labels: node.labels,
          properties: { ...node.properties },
        });
      }

      for (const rel of recordRels) {
        links.push({
          source: rel.startNodeElementId,
          target: rel.endNodeElementId,
          type: rel.type,
          properties: { ...rel.properties },
        });
      }
    }

    return {
      nodes: Array.from(nodes.values()),
      links,
      totalNodes: nodes.size,
      totalLinks: links.length,
    };
  } finally {
    await session.close();
  }
}

export async function getFraudClusters(minSize = 3) {
  if (!driver) return { clusters: [] };
  const session = driver.session();
  try {
    const result = await session.run(
      `
      MATCH (p:PhoneNumber)-[:CALLED]->(v:Victim)
      WITH p, count(v) as victimCount
      WHERE victimCount >= $minSize
      OPTIONAL MATCH (p)-[:PAID_TO]->(u:UPI)
      RETURN p.phoneNumber as phone, victimCount, collect(u.upiId) as upiIds
      ORDER BY victimCount DESC
      LIMIT 50
      `,
      { minSize }
    );

    return {
      clusters: result.records.map((r) => ({
        phone: r.get("phone"),
        victimCount: r.get("victimCount").toNumber(),
        upiIds: r.get("upiIds"),
      })),
    };
  } finally {
    await session.close();
  }
}

export async function getInvestigationGraph(caseId) {
  if (!driver) return { nodes: [], links: [] };
  const session = driver.session();
  try {
    const result = await session.run(
      `
      MATCH (c:Case {caseId: $caseId})
      OPTIONAL MATCH (c)-[:INVESTIGATED_BY]->(o:Officer)
      OPTIONAL MATCH (v:Victim)-[:REPORTED]->(c)
      OPTIONAL MATCH (v)-[:CALLED_BY]->(p:PhoneNumber)
      OPTIONAL MATCH (p)-[:PAID_TO]->(u:UPI)
      RETURN c, o, v, p, u
      `,
      { caseId }
    );

    const nodes = [];
    const links = [];

    for (const record of result.records) {
      const caseNode = record.get("c");
      if (caseNode) {
        nodes.push({ id: caseNode.elementId, type: "Case", ...caseNode.properties });
      }

      const officer = record.get("o");
      if (officer) {
        nodes.push({ id: officer.elementId, type: "Officer", ...officer.properties });
        if (caseNode) links.push({ source: caseNode.elementId, target: officer.elementId, type: "INVESTIGATED_BY" });
      }

      const victim = record.get("v");
      if (victim) {
        nodes.push({ id: victim.elementId, type: "Victim", ...victim.properties });
        if (caseNode) links.push({ source: victim.elementId, target: caseNode.elementId, type: "REPORTED" });
      }

      const phone = record.get("p");
      if (phone) {
        nodes.push({ id: phone.elementId, type: "PhoneNumber", ...phone.properties });
        if (victim) links.push({ source: phone.elementId, target: victim.elementId, type: "CALLED" });
      }

      const upi = record.get("u");
      if (upi) {
        nodes.push({ id: upi.elementId, type: "UPI", ...upi.properties });
        if (phone) links.push({ source: phone.elementId, target: upi.elementId, type: "PAID_TO" });
      }
    }

    return { nodes, links };
  } finally {
    await session.close();
  }
}

export async function getRepeatOffenders(minReports = 3) {
  if (!driver) return { offenders: [] };
  const session = driver.session();
  try {
    const result = await session.run(
      `
      MATCH (p:PhoneNumber)-[:CALLED]->(v:Victim)
      WITH p, count(v) as victimCount, collect(v.victimId) as victims
      WHERE victimCount >= $minReports
      RETURN p.phoneNumber as phone, victimCount, victims
      ORDER BY victimCount DESC
      LIMIT 20
      `,
      { minReports }
    );

    return {
      offenders: result.records.map((r) => ({
        phone: r.get("phone"),
        victimCount: r.get("victimCount").toNumber(),
        victims: r.get("victims"),
      })),
    };
  } finally {
    await session.close();
  }
}