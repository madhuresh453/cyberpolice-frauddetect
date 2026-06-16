import { BaseProvider } from '../GovernmentIntegrationProvider.js';

export class CyberCrimePortalProvider extends BaseProvider {
  constructor(config = {}) {
    super({
      name: 'CyberCrimePortal',
      baseUrl: config.baseUrl || 'https://api.cybercrime.gov.in/v1',
      apiKey: config.apiKey || process.env.CYBERCRIME_API_KEY || '',
      timeout: config.timeout || 15000,
      retryCount: config.retryCount || 3
    });
  }

  // Lodge a complaint on the National Cyber Crime Portal
  async lodgeComplaint(complaint) {
    const {
      complainantName, complainantPhone, complainantEmail,
      crimeCategory, crimeDescription, lossAmount,
      suspectDetails, evidenceIds, location
    } = complaint;

    const payload = {
      complainant: {
        name: complainantName,
        phone: complainantPhone,
        email: complainantEmail
      },
      crime: {
        category: crimeCategory || 'OTHER_CYBER_CRIME',
        description: crimeDescription || '',
        loss_amount: lossAmount || 0,
        occurred_date: new Date().toISOString(),
        location: location || {}
      },
      suspects: suspectDetails || [],
      evidence: evidenceIds || [],
      source: 'CyberShield-AI',
      timestamp: new Date().toISOString()
    };

    try {
      const result = await this.makeRequest('/complaints/file', 'POST', payload);
      return {
        success: true,
        complaintId: result.complaint_id || `CC-${Date.now()}`,
        status: result.status || 'REGISTERED',
        firNumber: result.fir_number || '',
        referenceId: result.reference_id || '',
        provider: this.name
      };
    } catch (error) {
      return { success: false, error: error.message, provider: this.name };
    }
  }

  // Check complaint status
  async checkComplaintStatus(complaintId) {
    try {
      const result = await this.makeRequest(`/complaints/status/${complaintId}`, 'GET');
      return {
        complaintId,
        status: result.status || 'UNKNOWN',
        lastUpdated: result.last_updated || '',
        actions: result.actions || [],
        firNumber: result.fir_number || '',
        provider: this.name
      };
    } catch (error) {
      return { complaintId, status: 'UNKNOWN', error: error.message };
    }
  }

  // Report fraud call/SMS
  async reportFraudContent(report) {
    const payload = {
      type: report.type || 'CALL',
      source_number: report.sourceNumber,
      target_number: report.targetNumber || '',
      content: report.content || '',
      risk_score: report.riskScore || 0,
      fraud_type: report.fraudType || 'UNKNOWN',
      timestamp: new Date().toISOString(),
      source: 'CyberShield-AI'
    };

    try {
      const result = await this.makeRequest('/fraud/report', 'POST', payload);
      return {
        success: true,
        referenceId: result.reference_id || `CCR-${Date.now()}`,
        provider: this.name
      };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  // Bulk report multiple fraud incidents
  async bulkReportFraud(incidents) {
    const payload = {
      incidents: incidents.map(i => ({
        source_number: i.sourceNumber,
        fraud_type: i.fraudType || 'UNKNOWN',
        risk_score: i.riskScore || 0,
        content: i.content || '',
        timestamp: i.timestamp || new Date().toISOString()
      })),
      source: 'CyberShield-AI',
      batch_id: `CCBATCH-${Date.now()}`
    };

    try {
      return await this.makeRequest('/fraud/bulk-report', 'POST', payload);
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  // Get cyber crime advisories for citizens
  async getCyberSafetyAdvisories(limit = 20) {
    try {
      return await this.makeRequest(`/advisories?limit=${limit}&source=CYBERSHIELD`, 'GET');
    } catch (error) {
      return { advisories: [], error: error.message };
    }
  }

  // Get cyber crime statistics
  async getCrimeStatistics(filters = {}) {
    const params = new URLSearchParams(filters).toString();
    try {
      return await this.makeRequest(`/statistics?${params}`, 'GET');
    } catch (error) {
      return { stats: [], error: error.message };
    }
  }

  // Block a fraudulent UPI ID
  async blockFraudUpiId(upiId, reason, reporterId) {
    try {
      return await this.makeRequest('/upi/block', 'POST', {
        upi_id: upiId,
        reason: reason || 'Suspected fraud',
        reported_by: reporterId,
        source: 'CyberShield-AI',
        timestamp: new Date().toISOString()
      });
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  // Block a fraudulent bank account
  async blockFraudBankAccount(accountNumber, bankName, reason) {
    try {
      return await this.makeRequest('/bank/block', 'POST', {
        account_number: accountNumber,
        bank_name: bankName,
        reason: reason || 'Fraudulent account',
        source: 'CyberShield-AI',
        timestamp: new Date().toISOString()
      });
    } catch (error) {
      return { success: false, error: error.message };
    }
  }
}

export default CyberCrimePortalProvider;