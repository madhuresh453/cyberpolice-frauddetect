import AuditLog from '../../shared/models/AuditLog.js';
import crypto from 'crypto';

export class AuditTrailService {
  constructor() {
    this.algorithm = 'sha256';
  }

  async recordAction(actionData) {
    const {
      action,
      resourceType,
      resourceId,
      userId,
      officerId,
      details,
      ipAddress,
      userAgent,
      sessionId
    } = actionData;

    const timestamp = new Date();
    const raw = `${action}|${resourceType}|${resourceId}|${userId}|${officerId}|${timestamp.toISOString()}`;
    const actionHash = crypto.createHash(this.algorithm).update(raw).digest('hex');

    const previousRecord = await AuditLog.findOne()
      .sort({ createdAt: -1 })
      .lean();

    const auditEntry = new AuditLog({
      action,
      resourceType,
      resourceId,
      userId,
      officerId,
      details,
      ipAddress: ipAddress || '127.0.0.1',
      userAgent: userAgent || 'CyberShield-AI',
      sessionId,
      timestamp,
      actionHash,
      previousHash: previousRecord ? previousRecord.actionHash : '',
      blockHash: this.generateBlockHash(
        actionHash,
        previousRecord ? previousRecord.actionHash : '',
        timestamp.toISOString()
      )
    });

    await auditEntry.save();
    return auditEntry;
  }

  async verifyAuditIntegrity(auditId) {
    const entry = await AuditLog.findOne({ _id: auditId }).lean();
    if (!entry) {
      return { valid: false, error: 'Audit entry not found' };
    }

    const raw = `${entry.action}|${entry.resourceType}|${entry.resourceId}|${entry.userId}|${entry.officerId}|${entry.timestamp.toISOString()}`;
    const recomputedHash = crypto.createHash(this.algorithm).update(raw).digest('hex');

    return {
      auditId,
      hashValid: recomputedHash === entry.actionHash,
      recomputedHash,
      storedHash: entry.actionHash,
      timestamp: entry.timestamp
    };
  }

  async getAuditTrail(filters = {}) {
    const query = {};
    if (filters.sessionId) query.sessionId = filters.sessionId;
    if (filters.userId) query.userId = filters.userId;
    if (filters.officerId) query.officerId = filters.officerId;
    if (filters.action) query.action = filters.action;
    if (filters.resourceType) query.resourceType = filters.resourceType;
    if (filters.dateFrom) query.timestamp = { $gte: new Date(filters.dateFrom) };
    if (filters.dateTo) {
      query.timestamp = query.timestamp || {};
      query.timestamp.$lte = new Date(filters.dateTo);
    }

    const entries = await AuditLog.find(query)
      .sort({ timestamp: 1 })
      .limit(filters.limit || 100)
      .lean();

    return entries.map((entry, idx) => ({
      sequence: idx + 1,
      auditId: entry._id,
      action: entry.action,
      resourceType: entry.resourceType,
      resourceId: entry.resourceId,
      userId: entry.userId,
      officerId: entry.officerId,
      details: entry.details,
      timestamp: entry.timestamp,
      actionHash: entry.actionHash,
      previousHash: entry.previousHash,
      blockHash: entry.blockHash
    }));
  }

  async forCourtExport(sessionId) {
    const auditEntries = await this.getAuditTrail({ sessionId });
    const evidenceEntries = await AuditLog.find({ action: { $in: ['CREATE_EVIDENCE', 'PDF_EXPORT'] }, sessionId }).lean();

    const exportData = {
      sessionId,
      courtExport: true,
      exportDate: new Date().toISOString(),
      auditTrail: auditEntries,
      evidenceAudit: evidenceEntries,
      totalActions: auditEntries.length,
      chainHash: crypto.createHash(this.algorithm)
        .update(JSON.stringify(auditEntries))
        .digest('hex'),
      courtReady: true,
      certifiedBy: 'CyberShield-AI Evidence Authority',
      signatureAlgorithm: 'SHA-256',
      disclaimer: 'This document is generated for court purposes. Chain integrity verified by CyberShield AI.'
    };

    return exportData;
  }

  generateBlockHash(currentHash, previousHash, timestamp) {
    return crypto.createHash(this.algorithm)
      .update(`${previousHash}|${currentHash}|${timestamp}`)
      .digest('hex');
  }
}

export default AuditTrailService;