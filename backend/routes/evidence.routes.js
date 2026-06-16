import { Router } from 'express';
import EvidenceHashService from '../services/evidence-service/EvidenceHashService.js';
import AuditTrailService from '../services/evidence-service/AuditTrailService.js';
import OfficerActionLog from '../services/evidence-service/OfficerActionLog.js';
import ChainOfCustodyManager from '../services/evidence-service/ChainOfCustodyManager.js';
import EmergencyReportService from '../services/evidence-service/EmergencyReportService.js';

const router = Router();
const evidenceHash = new EvidenceHashService();
const auditTrail = new AuditTrailService();
const officerLog = new OfficerActionLog();
const chainManager = new ChainOfCustodyManager();
const emergencyReport = new EmergencyReportService();

// Log evidence
router.post('/log', async (req, res) => {
  try {
    const result = await evidenceHash.createEvidenceRecord(req.body);
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Verify evidence integrity
router.post('/verify', async (req, res) => {
  try {
    const { evidenceId } = req.body;
    const result = await evidenceHash.verifyEvidenceIntegrity(evidenceId);
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get evidence history for session
router.get('/history/:sessionId', async (req, res) => {
  try {
    const result = await evidenceHash.getEvidenceHistory(req.params.sessionId);
    res.json({ sessionId: req.params.sessionId, evidences: result });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Tamper detection report
router.get('/tamper/:sessionId', async (req, res) => {
  try {
    const result = await evidenceHash.getTamperReport(req.params.sessionId);
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// PDF evidence package
router.get('/pdf/:sessionId', async (req, res) => {
  try {
    const result = await evidenceHash.getPdfEvidencePackage(req.params.sessionId);
    res.setHeader('Content-Type', 'application/octet-stream');
    res.setHeader('Content-Disposition', `attachment; filename="evidence-${req.params.sessionId}.txt"`);
    res.send(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Audit trail
router.post('/audit', async (req, res) => {
  try {
    const result = await auditTrail.recordAction(req.body);
    res.json({ entryId: result._id, actionHash: result.actionHash });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get audit trail
router.get('/audit/:sessionId', async (req, res) => {
  try {
    const result = await auditTrail.getAuditTrail({ sessionId: req.params.sessionId });
    res.json({ sessionId: req.params.sessionId, entries: result });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Court export
router.get('/court-export/:sessionId', async (req, res) => {
  try {
    const result = await auditTrail.forCourtExport(req.params.sessionId);
    res.setHeader('Content-Type', 'application/json');
    res.setHeader('Content-Disposition', `attachment; filename="court-${req.params.sessionId}.json"`);
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Officer actions
router.post('/officer/action', async (req, res) => {
  try {
    const result = await officerLog.logAction(req.body);
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get('/officer/:officerId/actions', async (req, res) => {
  try {
    const result = await officerLog.getOfficerActions(req.params.officerId);
    res.json({ officerId: req.params.officerId, actions: result });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Chain of custody
router.post('/chain/init', async (req, res) => {
  try {
    const { sessionId, caseId, officerId } = req.body;
    const result = await chainManager.initChain(sessionId, caseId, officerId);
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.post('/chain/add', async (req, res) => {
  try {
    const { sessionId, ...evidenceData } = req.body;
    const result = await chainManager.addEvidence(sessionId, evidenceData);
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.post('/chain/verify', async (req, res) => {
  try {
    const { sessionId } = req.body;
    const result = await chainManager.verifyFullChain(sessionId);
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.post('/chain/transfer', async (req, res) => {
  try {
    const { evidenceId, fromOfficerId, toOfficerId, reason } = req.body;
    const result = await chainManager.transferEvidence(evidenceId, fromOfficerId, toOfficerId, reason);
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get('/chain/court-export/:caseId/:sessionId', async (req, res) => {
  try {
    const result = await chainManager.exportForCourt(req.params.caseId, req.params.sessionId);
    res.setHeader('Content-Type', 'application/json');
    res.setHeader('Content-Disposition', `attachment; filename="court-evidence-${req.params.caseId}.json"`);
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Emergency report
router.post('/report', async (req, res) => {
  try {
    const result = await emergencyReport.submitReport(req.body);
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

export default router;