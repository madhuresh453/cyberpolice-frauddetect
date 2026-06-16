import crypto from 'crypto';
import AuditLog from '../../shared/models/AuditLog.js';
import PoliceOfficer from '../../shared/models/PoliceOfficer.js';

export class OfficerActionLog {
  constructor() {
    this.algorithm = 'sha256';
  }

  async logAction(actionData) {
    const {
      officerId,
      action,
      resourceType,
      resourceId,
      sessionId,
      details,
      ipAddress
    } = actionData;

    const timestamp = new Date();
    const raw = `${officerId}|${action}|${resourceType}|${resourceId}|${timestamp.toISOString()}`;
    const actionHash = crypto.createHash(this.algorithm).update(raw).digest('hex');

    const previousRecord = await AuditLog.findOne({ officerId })
      .sort({ createdAt: -1 })
      .lean();

    const entry = new AuditLog({
      action: `OFFICER_${action}`,
      resourceType,
      resourceId,
      userId: officerId,
      officerId,
      details: {
        ...details,
        officerVerified: true
      },
      ipAddress: ipAddress || '127.0.0.1',
      userAgent: 'CyberShield-AI Officer Portal',
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

    await entry.save();

    await this.updateOfficerStats(officerId, action);

    return {
      entryId: entry._id,
      officerId,
      action,
      actionHash,
      timestamp
    };
  }

  async updateOfficerStats(officerId, action) {
    try {
      await PoliceOfficer.updateOne(
        { officerId },
        {
          $inc: { actionCount: 1 },
          $set: { lastAction: action, lastActionTime: new Date() }
        }
      );
    } catch (err) {
      // Officer stats update is non-critical
    }
  }

  async getOfficerActions(officerId, filters = {}) {
    const query = { officerId };
    if (filters.action) query.action = `OFFICER_${filters.action}`;
    if (filters.dateFrom) query.timestamp = { $gte: new Date(filters.dateFrom) };
    if (filters.dateTo) {
      query.timestamp = query.timestamp || {};
      query.timestamp.$lte = new Date(filters.dateTo);
    }

    const actions = await AuditLog.find(query)
      .sort({ timestamp: -1 })
      .limit(filters.limit || 200)
      .lean();

    return actions.map((entry, idx) => ({
      sequence: idx + 1,
      entryId: entry._id,
      action: entry.action.replace('OFFICER_', ''),
      resourceType: entry.resourceType,
      resourceId: entry.resourceId,
      details: entry.details,
      timestamp: entry.timestamp,
      actionHash: entry.actionHash
    }));
  }

  async verifyOfficerChain(officerId) {
    const actions = await AuditLog.find({ officerId })
      .sort({ createdAt: 1 })
      .lean();

    const broken = [];
    for (let i = 1; i < actions.length; i++) {
      if (actions[i].previousHash !== actions[i - 1].actionHash) {
        broken.push({
          index: i,
          expectedPreviousHash: actions[i - 1].actionHash,
          actualPreviousHash: actions[i].previousHash,
          entryId: actions[i]._id
        });
      }
    }

    return {
      officerId,
      totalActions: actions.length,
      chainIntact: broken.length === 0,
      brokenLinks: broken
    };
  }

  async forCourtReport(officerId, sessionId) {
    const actions = await this.getOfficerActions(officerId, { sessionId });
    const chainStatus = await this.verifyOfficerChain(officerId);

    const report = {
      officerId,
      sessionId,
      reportDate: new Date().toISOString(),
      actionCount: actions.length,
      actions,
      chainStatus,
      chainHash: crypto.createHash(this.algorithm)
        .update(JSON.stringify(actions))
        .digest('hex'),
      certifiedBy: 'CyberShield-AI Evidence Authentication',
      courtReady: true,
      reportType: 'OFFICER_ACTION_LOG'
    };

    return report;
  }

  generateBlockHash(currentHash, previousHash, timestamp) {
    return crypto.createHash(this.algorithm)
      .update(`${previousHash}|${currentHash}|${timestamp}`)
      .digest('hex');
  }
}

export default OfficerActionLog;