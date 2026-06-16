import neo4j from 'neo4j-driver';

export class FraudGraphExplorer {
  constructor() {
    this.driver = null;
    this.initialized = false;
  }

  async initialize() {
    if (this.initialized) return;
    const neo4jUrl = process.env.NEO4J_URI || 'bolt://localhost:7687';
    const neo4jUser = process.env.NEO4J_USER || 'neo4j';
    const neo4jPassword = process.env.NEO4J_PASSWORD || 'password';
    this.driver = neo4j.driver(neo4jUrl, neo4j.auth.basic(neo4jUser, neo4jPassword));
    this.initialized = true;
  }

  async close() {
    if (this.driver) await this.driver.close();
  }

  async getSession() {
    await this.initialize();
    return this.driver.session();
  }

  // Fraud Network Graph - find connected fraud entities
  async getFraudGraph(phoneNumber) {
    const session = await this.getSession();
    try {
      const result = await session.run(
        `MATCH path = (start {number: $phone})-[*1..4]-(connected)
         WHERE start:Phone OR start:Person OR start:Account
         RETURN path
         LIMIT 100`,
        { phone: phoneNumber }
      );
      return this.parseGraphResult(result);
    } finally {
      await session.close();
    }
  }

  // Victim Graph - find all victims connected to a fraud pattern
  async getVictimGraph(caseId) {
    const session = await this.getSession();
    try {
      const result = await session.run(
        `MATCH (c:Case {id: $caseId})<-[:REPORTED]-(v:Victim)
         OPTIONAL MATCH (v)-[:INTERACTED_WITH]->(f:Fraudster)
         OPTIONAL MATCH (f)-[:USED]->(n:Number)
         OPTIONAL MATCH (f)-[:RECEIVED_AT]->(a:Account)
         RETURN c, v, f, n, a`,
        { caseId }
      );
      return this.parseGraphResult(result);
    } finally {
      await session.close();
    }
  }

  // UPI Fraud Graph - trace UPI transaction fraud networks
  async getUpiGraph(upiId) {
    const session = await this.getSession();
    try {
      const result = await session.run(
        `MATCH path = (u:UpiId {upiId: $upiId})-[:SENT_TO|RECEIVED_FROM*1..3]-(related)
         RETURN path
         LIMIT 200`,
        { upiId }
      );
      return this.parseGraphResult(result);
    } finally {
      await session.close();
    }
  }

  // Phone Graph - find phone number clusters
  async getPhoneGraph(phoneNumber) {
    const session = await this.getSession();
    try {
      const result = await session.run(
        `MATCH (p:Phone {number: $phone})
         OPTIONAL MATCH (p)-[:CALLED]->(c:Phone)
         OPTIONAL MATCH (c)-[:RECEIVED_SMS]->(s:Sms)
         OPTIONAL MATCH (p)-[:LINKED_ACCOUNT]->(a:Account)
         RETURN p, c, s, a`,
        { phone: phoneNumber }
      );
      return this.parseGraphResult(result);
    } finally {
      await session.close();
    }
  }

  // Case Graph - full investigation graph
  async getCaseGraph(caseId) {
    const session = await this.getSession();
    try {
      const result = await session.run(
        `MATCH (c:Case {id: $caseId})
         OPTIONAL MATCH (c)-[:INVOLVES]->(e:Evidence)
         OPTIONAL MATCH (c)-[:INVESTIGATED_BY]->(o:Officer)
         OPTIONAL MATCH (c)-[:INvolves]->(p:Phone)
         OPTIONAL MATCH (c)-[:INvolves]->(u:UpiId)
         OPTIONAL MATCH (c)-[:INvolves]->(v:Victim)
         RETURN c, e, o, p, u, v`,
        { caseId }
      );
      return this.parseGraphResult(result);
    } finally {
      await session.close();
    }
  }

  // Search nodes
  async searchNodes(query, nodeTypes = []) {
    const session = await this.getSession();
    try {
      const whereClause = nodeTypes.length > 0
        ? `WHERE ANY(label IN labels(n) WHERE label IN $types)`
        : '';
      const params = nodeTypes.length > 0 ? { query, types: nodeTypes } : { query };

      const result = await session.run(
        `MATCH (n)
         WHERE n.number CONTAINS $query
            OR n.upiId CONTAINS $query
            OR n.id CONTAINS $query
            OR n.name CONTAINS $query
         ${whereClause}
         RETURN n LIMIT 50`,
        params
      );
      return result.records.map(r => this.parseNode(r.get('n')));
    } finally {
      await session.close();
    }
  }

  // Expand node - find all connections
  async expandNode(nodeId, nodeType) {
    const session = await this.getSession();
    try {
      const result = await session.run(
        `MATCH (n {id: $id})-[r]-(connected)
         RETURN n, r, connected
         LIMIT 100`,
        { id: nodeId }
      );
      return this.parseGraphResult(result);
    } finally {
      await session.close();
    }
  }

  // Export graph as JSON
  async exportGraph(sessionId) {
    const session = await this.getSession();
    try {
      const result = await session.run(
        `MATCH (n)-[r]-(m)
         WHERE n.sessionId = $sessionId OR m.sessionId = $sessionId
         RETURN n, r, m LIMIT 500`,
        { sessionId }
      );
      return this.parseGraphResult(result);
    } finally {
      await session.close();
    }
  }

  // Create fraud intelligence nodes
  async createFraudNode(data) {
    const session = await this.getSession();
    try {
      const label = data.type || 'Phone';
      const props = { ...data };
      const result = await session.run(
        `CREATE (n:${label} $props) RETURN n`,
        { props }
      );
      return result.records.map(r => this.parseNode(r.get('n')))[0];
    } finally {
      await session.close();
    }
  }

  async createRelationship(fromId, toId, relType, properties = {}) {
    const session = await this.getSession();
    try {
      const result = await session.run(
        `MATCH (a {id: $fromId}), (b {id: $toId})
         CREATE (a)-[r:${relType} $props]->(b)
         RETURN r`,
        { fromId, toId, props: properties }
      );
      return result.records.map(r => ({
        type: r.get('r').type,
        properties: r.get('r').properties
      }))[0];
    } finally {
      await session.close();
    }
  }

  // Bulk import from MongoDB
  async syncFromMongo(fraudNumbers, fraudAccounts) {
    const session = await this.getSession();
    try {
      for (const num of fraudNumbers) {
        await session.run(
          `MERGE (n:Phone {number: $number})
           SET n.id = $id, n.riskScore = $riskScore, n.reportCount = $reportCount`,
          { number: num.number, id: num._id.toString(), riskScore: num.riskScore || 0, reportCount: num.reportCount || 0 }
        );
      }
      for (const acc of fraudAccounts) {
        await session.run(
          `MERGE (n:Account {accountNumber: $accountNumber})
           SET n.id = $id, n.bank = $bank, n.riskScore = $riskScore`,
          { accountNumber: acc.accountNumber, id: acc._id.toString(), bank: acc.bank || '', riskScore: acc.riskScore || 0 }
        );
      }
    } finally {
      await session.close();
    }
  }

  parseGraphResult(result) {
    const nodes = new Map();
    const relationships = [];

    result.records.forEach(record => {
      record.keys.forEach(key => {
        const value = record.get(key);
        if (value && value.properties && value.labels) {
          // It's a node
          const nodeData = this.parseNode(value);
          nodes.set(nodeData.id, nodeData);
        } else if (Array.isArray(value)) {
          // Could be a path
          value.forEach(segment => {
            if (segment.start && segment.end) {
              relationships.push({
                from: segment.start.properties?.id || '',
                to: segment.end.properties?.id || '',
                type: segment.type || '',
                properties: segment.properties || {}
              });
            }
          });
        } else if (value && value.segments) {
          // It's a path
          value.segments.forEach(seg => {
            if (seg.start) {
              const startNode = this.parseNode(seg.start);
              nodes.set(startNode.id, startNode);
            }
            if (seg.end) {
              const endNode = this.parseNode(seg.end);
              nodes.set(endNode.id, endNode);
            }
            if (seg.relationship) {
              relationships.push({
                from: seg.start?.properties?.id || '',
                to: seg.end?.properties?.id || '',
                type: seg.relationship.type || '',
                properties: seg.relationship.properties || {}
              });
            }
          });
        }
      });
    });

    return {
      nodes: Array.from(nodes.values()),
      relationships,
      nodeCount: nodes.size,
      relationshipCount: relationships.length
    };
  }

  parseNode(node) {
    if (!node || !node.properties) return {};
    const props = {};
    Object.keys(node.properties).forEach(k => {
      props[k] = node.properties[k];
    });
    return {
      id: props.id || props.number || props.upiId || props.accountNumber || 'unknown',
      labels: node.labels || [],
      properties: props
    };
  }
}

export default FraudGraphExplorer;