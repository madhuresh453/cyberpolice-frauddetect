import http from 'http';

function req(method, path, body) {
  return new Promise((resolve, reject) => {
    const opts = { hostname: 'localhost', port: 5000, path, method, headers: {} };
    if (body) {
      opts.headers = { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(body) };
    }
    const r = http.request(opts, (res) => {
      let data = '';
      res.on('data', (c) => data += c);
      res.on('end', () => {
        try { resolve({ status: res.statusCode, body: JSON.parse(data) }); }
        catch { resolve({ status: res.statusCode, body: data }); }
      });
    });
    r.on('error', (e) => reject(e));
    if (body) r.write(body);
    r.end();
  });
}

async function main() {
  // Wait for server
  for (let i = 0; i < 15; i++) {
    try { await req('GET', '/health'); console.log('Server ready'); break; }
    catch { await new Promise(r => setTimeout(r, 1000)); }
  }

  // Test register with new user
  console.log('\n=== REGISTER NEW USER ===');
  const reg = await req('POST', '/api/v1/auth/register', JSON.stringify({
    email: 'admin@cybershield.ai',
    phone_number: '+919999999999',
    password: 'Admin@123',
    full_name: 'Admin User',
    user_type: 'citizen'
  }));
  console.log(`Status: ${reg.status}`);
  console.log(JSON.stringify(reg.body, null, 2));

  // Test login with correct credentials
  console.log('\n=== LOGIN WITH CORRECT CREDENTIALS ===');
  const log = await req('POST', '/api/v1/auth/login', JSON.stringify({
    email: 'admin@cybershield.ai',
    password: 'Admin@123'
  }));
  console.log(`Status: ${log.status}`);
  console.log(JSON.stringify(log.body, null, 2));
  
  if (log.status === 200) {
    console.log('✓ LOGIN SUCCESS - JWT received');
  }

  // Test /auth/me with JWT
  if (log.status === 200 && log.body.access_token) {
    console.log('\n=== GET /auth/me ===');
    const me = await req('GET', '/api/v1/auth/me', null, log.body.access_token);
    console.log(`Status: ${me.status}`);
    console.log(JSON.stringify(me.body, null, 2));
  }

  // Test refresh
  if (log.status === 200 && log.body.refresh_token) {
    console.log('\n=== REFRESH TOKEN ===');
    const ref = await req('POST', '/api/v1/auth/refresh', JSON.stringify({
      refresh_token: log.body.refresh_token
    }));
    console.log(`Status: ${ref.status}`);
    console.log(JSON.stringify(ref.body, null, 2));
  }

  console.log('\n=== DONE ===');
}

main().catch(e => console.error(e));