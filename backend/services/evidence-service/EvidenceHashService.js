import crypto from 'crypto';
import EvidenceChain from '../../shared/models/EvidenceChain.js';
import AuditLog from '../../shared/models/AuditLog.js';

export class EvidenceHashService {
  constructor() {
    this.algorithm = 'sha256';
  }

  generateHash(data) {
    const content = typeof data === 'string' ? data : JSON.stringify(data);
    return crypto.createHash(this.algorithm).update(content).digest('hex');
  }

  generateFileHash(fileBuffer) {
    return crypto.createHash(this.algorithm).update(fileBuffer).digest('hex');
  }

  async createEvidenceRecord(evidenceData) {
    const {
      evidenceId,
      sessionId,
      type,
      source,
      status,
      riskScore,
      riskLevel,
      timestamp,
      messageHash
    } = evidenceData;

    const raw = `${evidenceId}|${sessionId}|${type}|${source}|${status}|${riskScore}|${riskLevel}|${timestamp}`;
    const hash = this.generateHash(raw);

    const previousEvidence = await EvidenceChain.findOne()
      .sort({ createdAt: -1 })
      .lean();

    const previousHash = previousEvidence ? previousEvidence.hash : '';

    const chainOfCustody = new EvidenceChain({
      evidenceId,
      sessionId,
      type,
      source,
      status,
      riskScore,
      riskLevel,
      timestamp: new Date(timestamp),
      hash,
      previousHash,
      messageHash: messageHash || '',
      blockHash: this.generateBlockHash(hash, previousHash, timestamp)
    });

    await chainOfCustody.save();

    await this.logAudit('CREATE_EVIDENCE', evidenceId, 'system', {
      type,
      hash,
      previousHash
    });

    return {
      evidenceId,
      hash,
      previousHash,
      valid: true,
      chainValid: true,
      timestamp
    };
  }

  async verifyEvidenceIntegrity(evidenceId) {
    const evidence = await EvidenceChain.findOne({ evidenceId }).lean();
    if (!evidence) {
      return { valid: false, error: 'Evidence not found' };
    }

    const raw = `${evidence.evidenceId}|${evidence.sessionId}|${evidence.type}|${evidence.source}|${evidence.status}|${evidence.riskScore}|${evidence.riskLevel}|${evidence.timestamp}`;
    const recomputedHash = this.generateHash(raw);

    const isHashValid = recomputedHash === evidence.hash;

    let chainIntact = true;
    const chainEntries = await EvidenceChain.find({ sessionId: evidence.sessionId })
      .sort({ createdAt: 1 })
      .lean();

    for (let i = 1; i < chainEntries.length; i++) {
      if (chainEntries[i].previousHash !== chainEntries[i - 1].hash) {
        chainIntact = false;
        break;
      }
    }

    return {
      evidenceId,
      hashValid: isHashValid,
      chainIntact,
      valid: isHashValid && chainIntact,
      currentHash: evidence.hash,
      recomputedHash,
      chainLength: chainEntries.length
    };
  }

  async getEvidenceHistory(sessionId) {
    const entries = await EvidenceChain.find({ sessionId })
      .sort({ createdAt: 1 })
      .lean();

    return entries.map((entry, idx) => ({
      evidenceId: entry.evidenceId,
      type: entry.type,
      source: entry.source,
      status: entry.status,
      hash: entry.hash,
      previousHash: entry.previousHash,
      blockHash: entry.blockHash,
      timestamp: entry.timestamp,
      sequence: idx + 1
    }));
  }

  async getTamperReport(sessionId) {
    const entries = await EvidenceChain.find({ sessionId })
      .sort({ createdAt: 1 })
      .lean();

    const tamperEvents = [];
    for (let i = 1; i < entries.length; i++) {
      if (entries[i].previousHash !== entries[i - 1].hash) {
        tamperEvents.push({
          evidenceId: entries[i].evidenceId,
          expectedPreviousHash: entries[i - 1].hash,
          actualPreviousHash: entries[i].previousHash,
          timestamp: entries[i].timestamp,
          type: 'CHAIN_BREAK'
        });
      }
    }

    return {
      sessionId,
      totalEvidence: entries.length,
      tamperDetected: tamperEvents.length > 0,
      tamperEvents,
      reportGeneratedAt: new Date().toISOString()
    };
  }

  async getPdfEvidencePackage(sessionId) {
    const evidences = await this.getEvidenceHistory(sessionId);
    const tamperReport = await this.getTamperReport(sessionId);

    const packageData = {
      sessionId,
      evidences,
      tamperReport,
      chainHash: this.generateHash(JSON.stringify(evidences)),
      exportTimestamp: new Date().toISOString(),
      exportedBy: 'CyberShield-AI Evidence Export',
      version: '1.0'
    };

    await this.logAudit('PDF_EXPORT', sessionId, 'system', {
      evidenceCount: evidences.length,
      chainHash: packageData.chainHash
    });

    return this.generatePdfContent(packageData);
  }

  generatePdfContent(data) {
    const lines = [];
    lines.push('=== CyberShield AI - Evidence Package ===');
    lines.push(`Session ID: ${data.sessionId}`);
    lines.push(`Export Timestamp: ${data.exportTimestamp}`);
    lines.push(`Chain Hash: ${data.chainHash}`);
    lines.push('');
    lines.push('--- Evidence Chain ---');
    data.evidences.forEach((ev, idx) => {
      lines.push(`[${idx + 1}] Evidence ID: ${ev.evidenceId}`);
      lines.push(`    Type: ${ev.type} | Source: ${ev.source} | Status: ${ev.status}`);
      lines.push(`    Hash: ${ev.hash}`);
      lines.push(`    Previous Hash: ${ev.previousHash}`);
      lines.push(`    Timestamp: ${ev.timestamp}`);
      lines.push('');
    });
    lines.push('--- Tamper Report ---');
    lines.push(`Tamper Detected: ${data.tamperReport.tamperDetected}`);
    lines.push(`Total Evidence: ${data.tamperReport.totalEvidence}`);
    if (data.tamperReport.tamperEvents.length > 0) {
      data.tamperReport.tamperEvents.forEach(te => {
        lines.push(`    ${te.type}: Evidence ${te.evidenceId} at ${te.timestamp}`);
      });
    }
    lines.push('--- End of Package ---');
    return lines.join('\n');
  }

  blockHash(currentHash, previousHash, timestamp) {
    return this.generateHash(`${previousHash}|${currentHash}|${timestamp}`);
  }

  generateBlockHash(currentHash, previousHash, timestamp) {
    return crypto.createHash(this.algorithm)
      .update(`${previousHash}|${currentHash}|${timestamp}`)
      .digest('hex');
  }

  async logAudit(action, evidenceId, userId, details) {
    const audit = new AuditLog({
      action,
      evidenceId,
      userId,
      details,
      timestamp: new Date(),
      ip: 'system'
    });
    await audit.save();
  }
}

export default EvidenceHashService;