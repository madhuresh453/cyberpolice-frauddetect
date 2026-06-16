import http from 'http';
import crypto from 'crypto';

const BASE_URL = process.env.BASE_URL || 'http://localhost:3000';
const CONCURRENCY = parseInt(process.env.CONCURRENCY || '100');
const TOTAL_USERS = parseInt(process.env.TOTAL_USERS || '10000');
const RAMP_UP_SEC = parseInt(process.env.RAMP_UP || '10');

class LoadTester {
  constructor(config) {
    this.baseUrl = config.baseUrl;
    this.totalUsers = config.totalUsers;
    this.concurrency = config.concurrency;
    this.rampUp = config.rampUp;
    this.results = {
      totalRequests: 0,
      successfulRequests: 0,
      failedRequests: 0,
      responseTimes: [],
      errors: [],
      memoryUsage: [],
      cpuUsage: [],
      dbPerformance: [],
      startTime: null,
      endTime: null,
      peakRps: 0
    };
    this.activeRequests = 0;
    this.completedRequests = 0;
  }

  async run() {
    this.results.startTime = Date.now();
    console.log(`\n${'='.repeat(60)}`);
    console.log(`  CyberShield AI - Load Test`);
    console.log(`  Total Users: ${this.totalUsers} | Concurrency: ${this.concurrency}`);
    console.log(`  Base URL: ${this.baseUrl}`);
    console.log(`${'='.repeat(60)}\n`);

    // Collect system metrics
    const metricsInterval = setInterval(() => this.collectMetrics(), 1000);

    // Generate test users
    const users = this.generateUsers(this.totalUsers);

    // Run load test in batches
    const batchSize = this.concurrency;
    const batches = Math.ceil(users.length / batchSize);

    for (let i = 0; i < batches; i++) {
      const batch = users.slice(i * batchSize, (i + 1) * batchSize);
      const promises = batch.map(user => this.simulateUser(user));
      await Promise.allSettled(promises);

      this.completedRequests += batch.length;

      // Progress
      const pct = Math.round((this.completedRequests / this.totalUsers) * 100);
      if (pct % 10 === 0 || pct === 100) {
        console.log(`  Progress: ${pct}% (${this.completedRequests}/${this.totalUsers})`);
      }

      // Small delay between batches to simulate ramp-up
      if (i < batches - 1) {
        const delay = Math.round((this.rampUp * 1000) / batches);
        await this.sleep(delay);
      }
    }

    clearInterval(metricsInterval);
    this.results.endTime = Date.now();
    this.generateReport();
  }

  generateUsers(count) {
    const users = [];
    for (let i = 0; i < count; i++) {
      users.push({
        id: `user-${i + 1}`,
        phone: `+91${Math.floor(7000000000 + Math.random() * 3000000000)}`,
        email: `user${i + 1}@test.com`,
        action: ['call_check', 'sms_check', 'report', 'graph_query', 'evidence_verify'][Math.floor(Math.random() * 5)]
      });
    }
    return users;
  }

  async simulateUser(user) {
    const startTime = Date.now();
    try {
      switch (user.action) {
        case 'call_check':
          await this.makeRequest('/api/risk/call-check', 'POST', {
            phone_number: user.phone,
            source: 'load_test'
          });
          break;
        case 'sms_check':
          await this.makeRequest('/api/sms/analyze', 'POST', {
            sender: user.phone,
            message: 'Test message'
          });
          break;
        case 'report':
          await this.makeRequest('/api/evidence/log', 'POST', {
            evidenceId: `EV-${user.id}`,
            sessionId: `session-${user.id}`,
            type: 'CALL',
            source: user.phone,
            riskScore: Math.floor(Math.random() * 100),
            riskLevel: 'GREEN'
          });
          break;
        case 'graph_query':
          await this.makeRequest('/api/graph/fraud/' + user.phone, 'GET');
          break;
        case 'evidence_verify':
          await this.makeRequest('/api/evidence/verify', 'POST', {
            evidenceId: `EV-${user.id}`
          });
          break;
      }

      const elapsed = Date.now() - startTime;
      this.results.responseTimes.push(elapsed);
      this.results.successfulRequests++;
    } catch (error) {
      const elapsed = Date.now() - startTime;
      this.results.responseTimes.push(elapsed);
      this.results.failedRequests++;
      this.results.errors.push({ userId: user.id, error: error.message, elapsed });
    }
    this.results.totalRequests++;
  }

  makeRequest(path, method, body) {
    return new Promise((resolve, reject) => {
      const url = new URL(path, this.baseUrl);
      const options = {
        hostname: url.hostname,
        port: url.port || 80,
        path: url.pathname,
        method: method,
        headers: {
          'Content-Type': 'application/json',
          'X-Load-Test': 'true'
        },
        timeout: 10000
      };

      const req = http.request(options, (res) => {
        let data = '';
        res.on('data', (chunk) => { data += chunk; });
        res.on('end', () => {
          if (res.statusCode >= 200 && res.statusCode < 400) {
            resolve({ status: res.statusCode, data });
          } else {
            reject(new Error(`HTTP ${res.statusCode}: ${data.substring(0, 200)}`));
          }
        });
      });

      req.on('error', reject);
      req.on('timeout', () => { req.destroy(); reject(new Error('Timeout')); });

      if (body) req.write(JSON.stringify(body));
      req.end();
    });
  }

  collectMetrics() {
    const mem = process.memoryUsage();
    this.results.memoryUsage.push({
      timestamp: Date.now(),
      heapUsed: mem.heapUsed,
      heapTotal: mem.heapTotal,
      rss: mem.rss
    });

    // Calculate RPS
    const active = this.completedRequests - (this.results.responseTimes.length > 0 ? this.results.responseTimes.length - 1 : 0);
    if (active > this.results.peakRps) this.results.peakRps = active;
  }

  generateReport() {
    const duration = (this.results.endTime - this.results.startTime) / 1000;
    const sorted = [...this.results.responseTimes].sort((a, b) => a - b);
    const p50 = sorted[Math.floor(sorted.length * 0.5)] || 0;
    const p90 = sorted[Math.floor(sorted.length * 0.9)] || 0;
    const p95 = sorted[Math.floor(sorted.length * 0.95)] || 0;
    const p99 = sorted[Math.floor(sorted.length * 0.99)] || 0;
    const avg = this.results.responseTimes.length > 0
      ? Math.round(this.results.responseTimes.reduce((a, b) => a + b, 0) / this.results.responseTimes.length)
      : 0;
    const throughput = Math.round(this.results.totalRequests / duration);
    const successRate = this.results.totalRequests > 0
      ? ((this.results.successfulRequests / this.results.totalRequests) * 100).toFixed(2)
      : 0;

    let memPeak = 0, memAvg = 0, rssPeak = 0;
    if (this.results.memoryUsage.length > 0) {
      const memSorted = this.results.memoryUsage.map(m => m.heapUsed).sort((a, b) => b - a);
      memPeak = memSorted[0];
      memAvg = this.results.memoryUsage.reduce((a, b) => a + b.heapUsed, 0) / this.results.memoryUsage.length;
      rssPeak = Math.max(...this.results.memoryUsage.map(m => m.rss));
    }

    const report = {
      summary: {
        totalUsers: this.totalUsers,
        concurrency: this.concurrency,
        totalRequests: this.results.totalRequests,
        successfulRequests: this.results.successfulRequests,
        failedRequests: this.results.failedRequests,
        successRate: `${successRate}%`,
        durationSeconds: duration.toFixed(2),
        throughputRPS: throughput
      },
      responseTimes: {
        avg: `${avg}ms`,
        p50: `${p50}ms`,
        p90: `${p90}ms`,
        p95: `${p95}ms`,
        p99: `${p99}ms`,
        min: sorted[0] || 0,
        max: sorted[sorted.length - 1] || 0
      },
      memoryUsage: {
        heapUsedPeak: `${(memPeak / 1024 / 1024).toFixed(2)}MB`,
        heapUsedAvg: `${(memAvg / 1024 / 1024).toFixed(2)}MB`,
        rssPeak: `${(rssPeak / 1024 / 1024).toFixed(2)}MB`
      },
      cpuPerformance: {
        peakRPS: this.results.peakRps,
        errorRate: `${(this.results.failedRequests / this.results.totalRequests * 100).toFixed(2)}%`,
        avgResponseTime: `${avg}ms`
      },
      dbPerformance: {
        metricsCollected: this.results.memoryUsage.length,
        note: 'Database performance metrics require database-level instrumentation'
      },
      testMeta: {
        startTime: new Date(this.results.startTime).toISOString(),
        endTime: new Date(this.results.endTime).toISOString(),
        userAgent: 'CyberShield-AI-LoadTest/1.0'
      }
    };

    const reportJSON = JSON.stringify(report, null, 2);

    // Print report
    console.log('\n' + '='.repeat(60));
    console.log('  LOAD TEST REPORT');
    console.log('='.repeat(60));
    console.log(`\n  Duration: ${report.summary.durationSeconds}s`);
    console.log(`  Total Requests: ${report.summary.totalRequests}`);
    console.log(`  Success Rate: ${report.summary.successRate}`);
    console.log(`  Throughput: ${report.summary.throughputRPS} req/s`);
    console.log(`\n  Response Times:`);
    console.log(`    Avg: ${report.responseTimes.avg}`);
    console.log(`    P50: ${report.responseTimes.p50}`);
    console.log(`    P90: ${report.responseTimes.p90}`);
    console.log(`    P95: ${report.responseTimes.p95}`);
    console.log(`    P99: ${report.responseTimes.p99}`);
    console.log(`    Min: ${report.responseTimes.min}ms`);
    console.log(`    Max: ${report.responseTimes.max}ms`);
    console.log(`\n  Memory:`);
    console.log(`    Heap Peak: ${report.memoryUsage.heapUsedPeak}`);
    console.log(`    Heap Avg: ${report.memoryUsage.heapUsedAvg}`);
    console.log(`    RSS Peak: ${report.memoryUsage.rssPeak}`);
    console.log('\n' + '='.repeat(60));

    // Write report to file
    const fs = await import('fs');
    fs.writeFileSync('tests/load-testing/load-test-report.json', reportJSON);
    console.log(`\n  Report saved: tests/load-testing/load-test-report.json`);
    console.log(`${'='.repeat(60)}\n`);

    return report;
  }

  sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}

// Run test
async function main() {
  const tester = new LoadTester({
    baseUrl: BASE_URL,
    totalUsers: TOTAL_USERS,
    concurrency: CONCURRENCY,
    rampUp: RAMP_UP_SEC
  });

  await tester.run();
  process.exit(0);
}

main().catch(err => {
  console.error('Load test failed:', err);
  process.exit(1);
});