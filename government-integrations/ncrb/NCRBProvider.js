import { BaseProvider } from '../GovernmentIntegrationProvider.js';

export class NCRBProvider extends BaseProvider {
  constructor(config = {}) {
    super({
      name: 'NCRB',
      baseUrl: config.baseUrl || 'https://api.ncrb.gov.in/cybercrime/v1',
      apiKey: config.apiKey || process.env.NCRB_API_KEY || '',
      timeout: config.timeout || 15000,
      retryCount: config.retryCount || 3
    });
  }

  // File FIR electronically with NCRB
  async fileFIR(firData) {
    const {
      complainantName, complainantPhone, complainantEmail,
      crimeType, crimeDescription, fraudAmount,
      suspectNumbers, suspectAccounts, suspectUpiIds,
      evidenceIds, stateCode, districtCode, psCode
    } = firData;

    const payload = {
      complainant: {
        name: complainantName,
        phone: complainantPhone,
        email: complainantEmail,
        id_type: 'Aadhaar',
        timestamp: new Date().toISOString()
      },
      crime: {
        type: crimeType || 'CYBER_FRAUD',
        description: crimeDescription,
        amount: fraudAmount || 0,
        occurred_date: new Date().toISOString(),
        state_code: stateCode || 'DL',
        district_code: districtCode || 'DL-001',
        police_station: psCode || 'CyberCrimePS'
      },
      suspects: {
        phone_numbers: suspectNumbers || [],
        bank_accounts: suspectAccounts || [],
        upi_ids: suspectUpiIds || []
      },
      evidence: {
        evidence_ids: evidenceIds || [],
        platform: 'CyberShield-AI'
      },
      filing_source: 'CyberShield-AI',
      priority: fraudAmount > 500000 ? 'HIGH' : 'MEDIUM'
    };

    try {
      const result = await this.makeRequest('/fir/file', 'POST', payload);
      return {
        success: true,
        firNumber: result.fir_number || `NCRB-${Date.now()}`,
        status: result.status || 'FILED',
        referenceId: result.reference_id || '',
        provider: this.name
      };
    } catch (error) {
      return { success: false, error: error.message, provider: this.name };
    }
  }

  // Check FIR status
  async checkFIRStatus(firNumber) {
    try {
      const result = await this.makeRequest(`/fir/status/${firNumber}`, 'GET');
      return {
        firNumber,
        status: result.status || 'UNKNOWN',
        lastUpdated: result.last_updated,
        actions: result.actions || [],
        provider: this.name
      };
    } catch (error) {
      return { firNumber, status: 'UNKNOWN', error: error.message };
    }
  }

  // Get crime statistics
  async getCrimeStats(filters = {}) {
    const params = new URLSearchParams(filters).toString();
    try {
      return await this.makeRequest(`/stats?${params}`, 'GET');
    } catch (error) {
      return { stats: [], error: error.message };
    }
  }

  // Report cyber crime incident
  async reportIncident(incident) {
    const payload = {
      incident_type: incident.type || 'CYBER_FRAUD',
      description: incident.description,
      victim_details: incident.victim || {},
      financial_loss: incident.amount || 0,
      digital_evidence: incident.evidence || [],
      timestamp: new Date().toISOString(),
      source: 'CyberShield-AI'
    };

    try {
      return await this.makeRequest('/incidents/report', 'POST', payload);
    } catch (error) {
      return { success: false, error: error.message };
    }
  }
}

export default NCRBProvider;