import { BaseProvider } from '../GovernmentIntegrationProvider.js';

export class SancharSaathiProvider extends BaseProvider {
  constructor(config = {}) {
    super({
      name: 'SancharSaathi',
      baseUrl: config.baseUrl || 'https://api.sancharsaathi.gov.in/v1',
      apiKey: config.apiKey || process.env.SANCHAR_SAATHI_API_KEY || '',
      timeout: config.timeout || 15000,
      retryCount: config.retryCount || 3
    });
  }

  async checkFraudStatus(phoneNumber) {
    try {
      const result = await this.makeRequest(`/fraud/check?number=${encodeURIComponent(phoneNumber)}`, 'GET');
      return {
        phoneNumber,
        isFraudulent: result.is_fraudulent || false,
        riskLevel: result.risk_level || 'LOW',
        complaints: result.complaints || 0,
        lastReported: result.last_reported || '',
        provider: this.name
      };
    } catch (error) {
      return { phoneNumber, isFraudulent: false, riskLevel: 'LOW', error: error.message, provider: this.name };
    }
  }

  async reportFraudNumber(fraudReport) {
    const { phoneNumber, fraudType, description, lossAmount, victimId } = fraudReport;
    const payload = {
      phone_number: phoneNumber,
      fraud_type: fraudType || 'TELECOM_FRAUD',
      description: description || '',
      loss_amount: lossAmount || 0,
      victim_id: victimId || '',
      source: 'CyberShield-AI',
      timestamp: new Date().toISOString(),
      category: this.mapFraudCategory(fraudType)
    };
    try {
      const result = await this.makeRequest('/fraud/report', 'POST', payload);
      return { success: true, referenceId: result.reference_id || `SS-${Date.now()}`, status: 'REPORTED', provider: this.name };
    } catch (error) {
      return { success: false, error: error.message, provider: this.name };
    }
  }

  async blockFraudulentNumbers(numbers) {
    const payload = {
      numbers: numbers.map(n => ({
        phone_number: n.number,
        is_preverified: n.preverified || false,
        fraud_type: n.fraudType || 'TELECOM_FRAUD',
        block_reason: n.reason || 'Fraudulent activity'
      })),
      source: 'CyberShield-AI',
      batch_timestamp: new Date().toISOString()
    };
    try {
      return await this.makeRequest('/numbers/block/bulk', 'POST', payload);
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  async getRegionalStats(stateOrDistrict) {
    try {
      return await this.makeRequest(`/stats/regional?area=${encodeURIComponent(stateOrDistrict)}`, 'GET');
    } catch (error) {
      return { stats: [], error: error.message };
    }
  }

  async verifyOwnership(msisdn, imei) {
    try {
      return await this.makeRequest('/ceir/verify', 'POST', { msisdn, imei });
    } catch (error) {
      return { verified: false, error: error.message };
    }
  }

  async blockStolenDevice(imei, phoneNumber, reason) {
    try {
      return await this.makeRequest('/ceir/block', 'POST', { imei, phone_number: phoneNumber, reason });
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  mapFraudCategory(type) {
    const map = {
      'OTP_SCAM': 'OTP_FRAUD', 'KYC_SCAM': 'KYC_FRAUD', 'BANK_SCAM': 'BANK_FRAUD',
      'DELIVERY_SCAM': 'PHISHING', 'INVESTMENT_SCAM': 'INVESTMENT_FRAUD', 'APK_MALWARE': 'MALWARE'
    };
    return map[type] || 'GENERAL_FRAUD';
  }
}

export default SancharSaathiProvider;