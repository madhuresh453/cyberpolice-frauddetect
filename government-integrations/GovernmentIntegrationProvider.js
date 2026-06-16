import crypto from 'crypto';

export class BaseProvider {
  constructor(config) {
    this.name = config.name;
    this.baseUrl = config.baseUrl || '';
    this.apiKey = config.apiKey || '';
    this.timeout = config.timeout || 10000;
    this.retryCount = config.retryCount || 3;
  }

  async makeRequest(endpoint, method, data, headers = {}) {
    const url = `${this.baseUrl}${endpoint}`;
    const reqHeaders = {
      'Content-Type': 'application/json',
      'X-API-Key': this.apiKey,
      'X-Provider': this.name,
      'X-Request-ID': crypto.randomUUID(),
      'X-Timestamp': new Date().toISOString(),
      ...headers
    };

    for (let attempt = 1; attempt <= this.retryCount; attempt++) {
      try {
        const controller = new AbortController();
        const timeout = setTimeout(() => controller.abort(), this.timeout);

        const response = await fetch(url, {
          method,
          headers: reqHeaders,
          body: data ? JSON.stringify(data) : undefined,
          signal: controller.signal
        });

        clearTimeout(timeout);

        if (!response.ok) {
          const errText = await response.text();
          throw new Error(`HTTP ${response.status}: ${errText}`);
        }

        return await response.json();
      } catch (error) {
        if (attempt === this.retryCount) {
          throw new Error(`${this.name} request failed after ${this.retryCount} attempts: ${error.message}`);
        }
        await new Promise(r => setTimeout(r, 1000 * attempt));
      }
    }
  }

  async healthCheck() {
    return {
      provider: this.name,
      status: 'healthy',
      timestamp: new Date().toISOString()
    };
  }
}

export default BaseProvider;