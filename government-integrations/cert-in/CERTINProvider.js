import { BaseProvider } from '../GovernmentIntegrationProvider.js';

export class CERTINProvider extends BaseProvider {
  constructor(config = {}) {
    super({
      name: 'CERT-IN',
      baseUrl: config.baseUrl || 'https://api.cert-in.org.in/v1',
      apiKey: config.apiKey || process.env.CERTIN_API_KEY || '',
      timeout: config.timeout || 15000,
      retryCount: config.retryCount || 3
    });
    this.indicatorTypes = ['ip', 'domain', 'url', 'hash', 'email'];
  }

  // Report malicious IP/domain/URL to CERT-IN
  async reportMaliciousIndicator(indicator) {
    const { type, value, severity, description, source } = indicator;

    const payload = {
      report_type: 'MALICIOUS_INDICATOR',
      indicator_type: type,
      indicator_value: value,
      severity: this.mapSeverity(severity),
      description: description || '',
      source: source || 'CyberShield-AI',
      timestamp: new Date().toISOString(),
      country: 'IN',
      reporter: 'CyberShield-AI Platform'
    };

    try {
      const result = await this.makeRequest('/reports/submit', 'POST', payload);
      return {
        success: true,
        referenceId: result.reference_id || `CERTIN-${Date.now()}`,
        status: 'SUBMITTED',
        provider: this.name
      };
    } catch (error) {
      return {
        success: false,
        error: error.message,
        provider: this.name,
        fallback: true
      };
    }
  }

  // Query CERT-IN for threat intelligence
  async queryIndicator(type, value) {
    try {
      const result = await this.makeRequest(`/lookup?type=${type}&value=${encodeURIComponent(value)}`, 'GET');
      return {
        found: result.found || false,
        riskLevel: result.risk_level || 'UNKNOWN',
        reports: result.reports || [],
        provider: this.name
      };
    } catch (error) {
      return { found: false, riskLevel: 'UNKNOWN', reports: [], provider: this.name, error: error.message };
    }
  }

  // Bulk report fraud numbers
  async reportFraudNumbers(numbers) {
    const batch = {
      reports: numbers.map(n => ({
        phone_number: n.number,
        fraud_type: n.fraudType || 'TELECOM_FRAUD',
        risk_score: n.riskScore || 0,
        report_count: n.reportCount || 1,
        first_reported: n.firstReported || new Date().toISOString(),
        last_reported: n.lastReported || new Date().toISOString()
      })),
      source: 'CyberShield-AI',
      batch_id: `BATCH-${Date.now()}`,
      timestamp: new Date().toISOString()
    };

    try {
      return await this.makeRequest('/reports/bulk', 'POST', batch);
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  // Get latest CERT-In advisories
  async getAdvisories(limit = 20) {
    try {
      return await this.makeRequest(`/advisories?limit=${limit}`, 'GET');
    } catch (error) {
      return { advisories: [], error: error.message };
    }
  }

  mapSeverity(severity) {
    const map = { critical: 'CRITICAL', high: 'HIGH', medium: 'MEDIUM', low: 'LOW', info: 'INFO' };
    return map[(severity || '').toLowerCase()] || 'MEDIUM';
  }
}

export default CERTINProvider;