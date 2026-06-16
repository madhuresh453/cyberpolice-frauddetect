import EvidenceHashService from './EvidenceHashService.js';
import AuditTrailService from './AuditTrailService.js';

export class EmergencyReportService {
  constructor() {
    this.evidenceHash = new EvidenceHashService();
    this.auditTrail = new AuditTrailService();
  }

  async submitReport(reportData) {
    const {
      sessionId,
      phone_number,
      risk_score,
      risk_level,
      type,
      reporter_id,
      details
    } = reportData;

    // Create evidence record
    const evidence = await this.evidenceHash.createEvidenceRecord({
      evidenceId: `RPT-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
      sessionId: sessionId || `EMERGENCY-${Date.now()}`,
      type: type || 'EMERGENCY_REPORT',
      source: phone_number,
      status: 'REPORTED',
      riskScore: risk_score || 0,
      riskLevel: risk_level || 'RED',
      timestamp: new Date().toISOString(),
      messageHash: ''
    });

    // Audit the report
    await this.auditTrail.recordAction({
      action: 'EMERGENCY_REPORT',
      resourceType: 'EMERGENCY',
      resourceId: phone_number,
      userId: reporter_id || 'system',
      details: {
        riskScore: risk_score,
        riskLevel: risk_level,
        type
      },
      sessionId
    });

    return {
      success: true,
      reportId: evidence.evidenceId,
      status: 'SUBMITTED',
      timestamp: new Date().toISOString()
    };
  }

  async getReportStatus(reportId) {
    return {
      reportId,
      status: 'SUBMITTED',
      evidenceHash: 'verified',
      timestamp: new Date().toISOString()
    };
  }
}

export default EmergencyReportService;