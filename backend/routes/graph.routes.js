import { Router } from 'express';
import FraudGraphExplorer from '../services/graph-intelligence-service/FraudGraphExplorer.js';

const router = Router();
const graphExplorer = new FraudGraphExplorer();

// Fraud Network Graph
router.get('/fraud/:phone', async (req, res) => {
  try {
    const result = await graphExplorer.getFraudGraph(req.params.phone);
    res.json(result);
  } catch (error) {
    res.json({ nodes: [], relationships: [], error: error.message });
  }
});

// Victim Graph
router.get('/victim/:caseId', async (req, res) => {
  try {
    const result = await graphExplorer.getVictimGraph(req.params.caseId);
    res.json(result);
  } catch (error) {
    res.json({ nodes: [], relationships: [], error: error.message });
  }
});

// UPI Graph
router.get('/upi/:upiId', async (req, res) => {
  try {
    const result = await graphExplorer.getUpiGraph(req.params.upiId);
    res.json(result);
  } catch (error) {
    res.json({ nodes: [], relationships: [], error: error.message });
  }
});

// Phone Graph
router.get('/phone/:phone', async (req, res) => {
  try {
    const result = await graphExplorer.getPhoneGraph(req.params.phone);
    res.json(result);
  } catch (error) {
    res.json({ nodes: [], relationships: [], error: error.message });
  }
});

// Case Graph
router.get('/case/:caseId', async (req, res) => {
  try {
    const result = await graphExplorer.getCaseGraph(req.params.caseId);
    res.json(result);
  } catch (error) {
    res.json({ nodes: [], relationships: [], error: error.message });
  }
});

// Search nodes
router.get('/search', async (req, res) => {
  try {
    const { q, types } = req.query;
    const typeArray = types ? types.split(',') : [];
    const result = await graphExplorer.searchNodes(q, typeArray);
    res.json({ nodes: result });
  } catch (error) {
    res.json({ nodes: [], error: error.message });
  }
});

// Expand node
router.get('/expand/:nodeId', async (req, res) => {
  try {
    const result = await graphExplorer.expandNode(req.params.nodeId);
    res.json(result);
  } catch (error) {
    res.json({ nodes: [], relationships: [], error: error.message });
  }
});

// Export graph
router.get('/export/:sessionId', async (req, res) => {
  try {
    const result = await graphExplorer.exportGraph(req.params.sessionId);
    res.setHeader('Content-Type', 'application/json');
    res.setHeader('Content-Disposition', `attachment; filename="graph-${req.params.sessionId}.json"`);
    res.json(result);
  } catch (error) {
    res.json({ error: error.message });
  }
});

// Create fraud node
router.post('/node', async (req, res) => {
  try {
    const result = await graphExplorer.createFraudNode(req.body);
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Create relationship
router.post('/relationship', async (req, res) => {
  try {
    const { fromId, toId, type, properties } = req.body;
    const result = await graphExplorer.createRelationship(fromId, toId, type, properties);
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Graph explorer UI
router.get('/ui', (req, res) => {
  res.sendFile('graph-explorer-ui.html', {
    root: process.cwd() + '/backend/services/graph-intelligence-service'
  });
});

export default router;