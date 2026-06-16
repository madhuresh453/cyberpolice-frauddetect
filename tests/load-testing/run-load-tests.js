import http from 'http';
import fs from 'fs';

const SCALES = [
  { users: 10000, concurrency: 1000, label: '10K' },
  { users: 50000, concurrency: 5000, label: '50K' },
  { users: 100000, concurrency: 10000, label: '100K' }
];

const BASE_URL = process.env.BASE_URL || 'http://localhost:3000';
const allReports = [];

function sleep(ms) { return new Promise(r => setTimeout(r, ms)); }

async function makeRequest(path, method, body) {
  return new Promise((resolve, reject) => {
    const url = new URL(path, BASE_URL);
    const options = {
      hostname: url.hostname,
      port: url.port || 80,
      path: url.pathname,
      method,
      headers: { 'Content-Type': 'application/json', 'X-Load-Test': 'true' },
      timeout: 10000
    };
    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (c) => { data += c; });
      res.on('end', () => {
        resolve({ status: res.statusCode, data, elapsed: Date.now() });
      });
    });
    req.on('error', reject);
    req.on('timeout', () => { req.destroy(); reject(new Error('Timeout')); });
    if (body) req.write(JSON.stringify(body));
    req.end();
  });
}

async function runScale(scale) {
  console.log(`\n${'='.repeat(60)}`);
  console.log(`  SCALE: ${scale.label} USERS`);
  console.log(`  Concurrency: ${scale.concurrency}`);
  console.log(`${'='.repeat(60)}`);

  const startTime = Date.now();
  const results = { responseTimes: [], success: 0, fail: 0, memorySnapshots: [] };

  const actions = ['call_check', 'sms_check', 'report', 'graph_query', 'evidence_verify'];
  const batchSize = scale.concurrency;
  const batches = Math.ceil(scale.users / batchSize);

  const metricsInterval = setInterval(() => {
    const mem = process.memoryUsage();
    results.memorySnapshots.push({
      timestamp: Date.now(),
      heapUsed: mem.heapUsed,
      rss: mem.rss
    });
  }, 1000);

  for (let i = 0; i < batches; i++) {
    const promises = [];
    for (let j = 0; j < batchSize && (i * batchSize + j) < scale.users; j++) {
      const action = actions[Math.floor(Math.random() * actions.length)];
      const phone = `+91${Math.floor(7000000000 + Math.random() * 3000000000)}`;
      const start = Date.now();
      const promise = (async () => {
        try {
          let path, body;
          switch (action) {
            case 'call_check':
              path = '/api/risk/call-check';
              body = { phone_number: phone, source: 'load_test' };
              break;
            case 'sms_check':
              path = '/api/sms/analyze';
              body = { sender: phone, message: 'Test' };
              break;
            case 'report':
              path = '/api/evidence/log';
              body = { evidenceId: `EV-${i}-${j}`, sessionId: `s-${i}-${j}`, type: 'CALL', source: phone, riskScore: 50, riskLevel: 'GREEN' };
              break;
            case 'graph_query':
              path = '/api/graph/fraud/' + phone;
              break;
            case 'evidence_verify':
              path = '/api/evidence/verify';
              body = { evidenceId: `EV-${i}-${j}` };
              break;
          }
          await makeRequest(path, body ? 'POST' : 'GET', body);
          results.success++;
        } catch { results.fail++; }
        results.responseTimes.push(Date.now() - start);
      })();
      promises.push(promise);
    }
    await Promise.allSettled(promises);
    const pct = Math.round(((i + 1) / batches) * 100);
    if (pct % 25 === 0 || pct === 100) console.log(`  ${pct}% complete (${(i + 1) * batchSize}/${scale.users})`);
    if (i < batches - 1) await sleep(Math.max(1, Math.round(1000 / batches)));
  }

  clearInterval(metricsInterval);
  const duration = (Date.now() - startTime) / 1000;
  const sorted = [...results.responseTimes].sort((a, b) => a - b);
  const total = results.success + results.fail;

  const report = {
    scale: scale.label,
    totalUsers: scale.users,
    concurrency: scale.concurrency,
    totalRequests: total,
    successRate: `${(results.success / total * 100).toFixed(2)}%`,
    durationSeconds: duration.toFixed(2),
    throughputRPS: Math.round(total / duration),
    responseTimes: {
      avg: `${Math.round(results.responseTimes.reduce((a, b) => a + b, 0) / results.responseTimes.length)}ms`,
      p50: `${sorted[Math.floor(sorted.length * 0.5)]}ms`,
      p90: `${sorted[Math.floor(sorted.length * 0.9)]}ms`,
      p95: `${sorted[Math.floor(sorted.length * 0.95)]}ms`,
      p99: `${sorted[Math.floor(sorted.length * 0.99)]}ms`,
      min: `${sorted[0]}ms`,
      max: `${sorted[sorted.length - 1]}ms`
    },
    memoryUsage: {
      peakHeap: results.memorySnapshots.length > 0 ? `${(Math.max(...results.memorySnapshots.map(m => m.heapUsed)) / 1024 / 1024).toFixed(2)}MB` : 'N/A',
      peakRSS: results.memorySnapshots.length > 0 ? `${(Math.max(...results.memorySnapshots.map(m => m.rss)) / 1024 / 1024).toFixed(2)}MB` : 'N/A'
    },
    cpuPerformance: {
      errorRate: `${(results.fail / total * 100).toFixed(2)}%`,
      avgResponseTime: `${Math.round(results.responseTimes.reduce((a, b) => a + b, 0) / results.responseTimes.length)}ms`
    }
  };

  console.log(`\n  Result for ${scale.label}:`);
  console.log(`    Requests: ${total} | Success: ${report.successRate} | RPS: ${report.throughputRPS}`);
  console.log(`    Avg: ${report.responseTimes.avg} | P95: ${report.responseTimes.p95} | P99: ${report.responseTimes.p99}`);
  console.log(`    Memory Peak: ${report.memoryUsage.peakHeap}`);

  return report;
}

async function main() {
  console.log('CyberShield AI - Multi-Scale Load Testing');
  console.log('Scales: 10,000 | 50,000 | 100,000 users\n');

  for (const scale of SCALES) {
    const report = await runScale(scale);
    allReports.push(report);
    await sleep(2000);
  }

  fs.writeFileSync(
    'tests/load-testing/multi-scale-report.json',
    JSON.stringify({ generatedAt: new Date().toISOString(), scales: allReports }, null, 2)
  );

  console.log(`\n${'='.repeat(60)}`);
  console.log('  COMPLETE MULTI-SCALE REPORT');
  console.log(`${'='.repeat(60)}`);
  console.log(`  File: tests/load-testing/multi-scale-report.json`);
  console.log(`${'='.repeat(60)}\n`);

  process.exit(0);
}

main().catch(e => { console.error(e); process.exit(1); });