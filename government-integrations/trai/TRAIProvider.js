import { BaseProvider } from '../GovernmentIntegrationProvider.js';

export class TRAIProvider extends BaseProvider {
  constructor(config = {}) {
    super({
      name: 'TRAI',
      baseUrl: config.baseUrl || 'https://api.trai.gov.in/ndnc/v1',
      apiKey: config.apiKey || process.env.TRAI_API_KEY || '',
      timeout: config.timeout || 15000,
      retryCount: config.retryCount || 3
    });
  }

  // Check if number is on NDNC registry
  async checkNDNCStatus(phoneNumber) {
    try {
      const result = await this.makeRequest(`/ndnc/check?number=${encodeURIComponent(phoneNumber)}`, 'GET');
      return {
        phoneNumber,
        ndncRegistered: result.registered || false,
        operator: result.operator || '',
        circle: result.circle || '',
        provider: this.name
      };
    } catch (error) {
      return { phoneNumber, ndncRegistered: false, error: error.message, provider: this.name };
    }
  }

  // Report spam number to TRAI
  async reportSpamNumber(report) {
    const { phoneNumber, spamType, reportCount, lastSeen } = report;
    const payload = {
      phone_number: phoneNumber,
      spam_type: spamType || 'UNWANTED_CALL',
      report_count: reportCount || 1,
      last_seen: lastSeen || new Date().toISOString(),
      source: 'CyberShield-AI',
      timestamp: new Date().toISOString(),
      category: this.classifySpamType(spamType)
    };

    try {
      const result = await this.makeRequest('/spam/report', 'POST', payload);
      return {
        success: true,
        referenceId: result.reference_id || `TRAI-${Date.now()}`,
        provider: this.name
      };
    } catch (error) {
      return { success: false, error: error.message, provider: this.name };
    }
  }

  // Bulk report spam numbers
  async bulkReportSpam(numbers) {
    const payload = {
      reports: numbers.map(n => ({
        phone_number: n.number,
        spam_type: n.spamType || 'UNWANTED_CALL',
        report_count: n.reportCount || 1,
        caller_name: n.callerName || '',
        category: n.category || 'UNKNOWN'
      })),
      source: 'CyberShield-AI',
      batch_timestamp: new Date().toISOString()
    };

    try {
      return await this.makeRequest('/spam/bulk-report', 'POST', payload);
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  // Get spam statistics
  async getSpamStats(phoneNumber) {
    try {
      return await this.makeRequest(`/spam/stats?number=${encodeURIComponent(phoneNumber)}`, 'GET');
    } catch (error) {
      return { reports: 0, riskLevel: 'UNKNOWN', error: error.message };
    }
  }

  // Check UCC (Unsolicited Commercial Communication) complaints
  async fileUCCComplaint(complaint) {
    const payload = {
      complainant_number: complaint.phone,
      spam_number: complaint.spamPhone,
      message_content: complaint.message || '',
      date_time: complaint.dateTime || new Date().toISOString(),
      complaint_type: 'UCC',
      source: 'CyberShield-AI'
    };

    try {
      return await this.makeRequest('/ucc/complaint', 'POST', payload);
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  classifySpamType(type) {
    const map = {
      'OTP_SCAM': 'FINANCIAL_FRAUD',
      'KYC_SCAM': 'IDENTITY_FRAUD',
      'BANK_SCAM': 'FINANCIAL_FRAUD',
      'DELIVERY_SCAM': 'PHISHING',
      'INVESTMENT_SCAM': 'FINANCIAL_FRAUD',
      'UNWANTED_CALL': 'UNWANTED_COMMUNICATION'
    };
    return map[type] || 'GENERAL_SPAM';
  }
}

export default TRAIProvider;