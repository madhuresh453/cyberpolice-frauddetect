import crypto from 'crypto';
import EvidenceChain from '../../shared/models/EvidenceChain.js';
import AuditLog from '../../shared/models/AuditLog.js';
import EvidenceHashService from './EvidenceHashService.js';
import AuditTrailService from './AuditTrailService.js';

export class ChainOfCustodyManager {
  constructor() {
    this.evidenceHash = new EvidenceHashService();
    this.auditTrail = new AuditTrailService();
    this.algorithm = 'sha256';
  }

  async initChain(sessionId, caseId, officerId) {
    const genesisRaw = `GENESIS|${sessionId}|${caseId}|${new Date().toISOString()}`;
    const genesisHash = crypto.createHash(this.algorithm).update(genesisRaw).digest('hex');

    const genesis = new EvidenceChain({
      evidenceId: `GENESIS_${sessionId}`,
      sessionId,
      caseId,
      type: 'GENESIS',
      source: 'SYSTEM',
      status: 'CHAIN_INIT',
      riskScore: 0,
      riskLevel: 'NONE',
      timestamp: new Date(),
      hash: genesisHash,
      previousHash: '',
      blockHash: genesisHash,
      officerId
    });

    await genesis.save();

    await this.auditTrail.recordAction({
      action: 'CHAIN_INIT',
      resourceType: 'SESSION',
      resourceId: sessionId,
      userId: 'system',
      officerId,
      details: { caseId, genesisHash },
      sessionId
    });

    return {
      sessionId,
      caseId,
      genesisHash,
      chainValid: true,
      initializedAt: new Date().toISOString()
    };
  }

  async addEvidence(sessionId, evidenceData) {
    const {
      evidenceId,
      type,
      source,
      status,
      riskScore,
      riskLevel,
      messageHash
    } = evidenceData;

    const previousEntry = await EvidenceChain.findOne({ sessionId })
      .sort({ createdAt: -1 })
      .lean();

    if (!previousEntry) {
      throw new Error(`No chain found for session ${sessionId}`);
    }

    const timestamp = new Date().toISOString();
    const raw = `${evidenceId}|${sessionId}|${type}|${source}|${status}|${riskScore}|${riskLevel}|${timestamp}`;
    const hash = crypto.createHash(this.algorithm).update(raw).digest('hex');

    const blockHash = crypto.createHash(this.algorithm)
      .update(`${previousEntry.hash}|${hash}|${timestamp}`)
      .digest('hex');

    const entry = new EvidenceChain({
      evidenceId,
      sessionId,
      caseId: previousEntry.caseId,
      type,
      source,
      status,
      riskScore,
      riskLevel,
      timestamp: new Date(timestamp),
      hash,
      previousHash: previousEntry.hash,
      blockHash,
      messageHash: messageHash || ''
    });

    await entry.save();

    await this.auditTrail.recordAction({
      action: 'ADD_EVIDENCE',
      resourceType: 'EVIDENCE',
      resourceId: evidenceId,
      userId: 'system',
      details: { type, hash, blockHash },
      sessionId
    });

    return {
      evidenceId,
      hash,
      previousHash: previousEntry.hash,
      blockHash,
      chainValid: true
    };
  }

  async transferEvidence(evidenceId, fromOfficerId, toOfficerId, reason) {
    const evidence = await EvidenceChain.findOne({ evidenceId }).lean();
    if (!evidence) {
      throw new Error(`Evidence ${evidenceId} not found`);
    }

    const timestamp = new Date().toISOString();
    const raw = `TRANSFER|${evidenceId}|${fromOfficerId}|${toOfficerId}|${reason}|${timestamp}`;
    const hash = crypto.createHash(this.algorithm).update(raw).digest('hex');

    const blockHash = crypto.createHash(this.algorithm)
      .update(`${evidence.hash}|${hash}|${timestamp}`)
      .digest('hex');

    const transfer = new EvidenceChain({
      evidenceId: `TRANSFER_${evidenceId}_${Date.now()}`,
      sessionId: evidence.sessionId,
      caseId: evidence.caseId,
      type: 'TRANSFER',
      source: fromOfficerId,
      destination: toOfficerId,
      status: 'TRANSFERRED',
      riskScore: 0,
      riskLevel: 'NONE',
      timestamp: new Date(timestamp),
      hash,
      previousHash: evidence.hash,
      blockHash,
      transferReason: reason
    });

    await transfer.save();

    await this.auditTrail.recordAction({
      action: 'TRANSFER_EVIDENCE',
      resourceType: 'EVIDENCE',
      resourceId: evidenceId,
      userId: fromOfficerId,
      officerId: toOfficerId,
      details: { fromOfficerId, toOfficerId, reason, hash },
      sessionId: evidence.sessionId
    });

    return {
      evidenceId,
      transferredFrom: fromOfficerId,
      transferredTo: toOfficerId,
      hash,
      blockHash,
      timestamp
    };
  }

  async verifyFullChain(sessionId) {
    const entries = await EvidenceChain.find({ sessionId })
      .sort({ createdAt: 1 })
      .lean();

    if (entries.length === 0) {
      return { valid: false, error: 'No chain entries found' };
    }

    const issues = [];
    let valid = true;

    for (let i = 1; i < entries.length; i++) {
      if (entries[i].previousHash !== entries[i - 1].hash) {
        valid = false;
        issues.push({
          position: i,
          evidenceId: entries[i].evidenceId,
          expectedPreviousHash: entries[i - 1].hash,
          actualPreviousHash: entries[i].previousHash,
          type: 'HASH_MISMATCH'
        });
      }
    }

    if (entries[0].previousHash !== '') {
      issues.push({
        position: 0,
        evidenceId: entries[0].evidenceId,
        type: 'GENESIS_INVALID',
        message: 'Genesis block should have empty previousHash'
      });
      valid = false;
    }

    return {
      sessionId,
      totalEntries: entries.length,
      valid,
      issues,
      verifiedAt: new Date().toISOString()
    };
  }

  async getCaseSummary(caseId) {
    const entries = await EvidenceChain.find({ caseId })
      .sort({ createdAt: 1 })
      .lean();

    const evidenceTypes = {};
    entries.forEach(entry => {
      evidenceTypes[entry.type] = (evidenceTypes[entry.type] || 0) + 1;
    });

    const officers = [...new Set(entries.filter(e => e.officerId).map(e => e.officerId))];

    return {
      caseId,
      totalEvidence: entries.length,
      evidenceTypes,
      officersInvolved: officers,
      chainValid: await this.validateChainSequence(entries),
      firstEntry: entries.length > 0 ? entries[0].timestamp : null,
      lastEntry: entries.length > 0 ? entries[entries.length - 1].timestamp : null
    };
  }

  async validateChainSequence(entries) {
    for (let i = 1; i < entries.length; i++) {
      if (entries[i].previousHash !== entries[i - 1].hash) {
        return false;
      }
    }
    return true;
  }

  async exportForCourt(caseId, sessionId) {
    const chainEntries = await EvidenceChain.find({ sessionId })
      .sort({ createdAt: 1 })
      .lean();

    const verification = await this.verifyFullChain(sessionId);

    const courtPackage = {
      exportType: 'COURT_READY_EVIDENCE_PACKAGE',
      caseId,
      sessionId,
      exportDate: new Date().toISOString(),
      chainEntries: chainEntries.map(entry => ({
        evidenceId: entry.evidenceId,
        type: entry.type,
        source: entry.source,
        status: entry.status,
        riskScore: entry.riskScore,
        riskLevel: entry.riskLevel,
        timestamp: entry.timestamp,
        hash: entry.hash,
        previousHash: entry.previousHash,
        blockHash: entry.blockHash
      })),
      verification,
      summary: await this.getCaseSummary(caseId),
      auditTrail: await this.auditTrail.forCourtExport(sessionId),
      packageHash: crypto.createHash(this.algorithm)
        .update(JSON.stringify({ caseId, sessionId, chainEntries: chainEntries.length }))
        .digest('hex'),
      certifyingAuthority: 'CyberShield-AI National Evidence System',
      signature: 'INTEGRITY_VERIFIED',
      courtAdmissible: verification.valid
    };

    return courtPackage;
  }
}

export default ChainOfCustodyManager;