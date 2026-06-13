import http from 'http';

function req(method, path, body, token) {
  return new Promise((resolve) => {
    const opts = { hostname: 'localhost', port: 5000, path, method, headers: {} };
    if (body) {
      opts.headers['Content-Type'] = 'application/json';
      opts.headers['Content-Length'] = Buffer.byteLength(body);
    }
    if (token) opts.headers['Authorization'] = 'Bearer ' + token;
    
    const r = http.request(opts, (res) => {
      let data = '';
      res.on('data', (c) => data += c);
      res.on('end', () => {
        try { resolve({ status: res.statusCode, body: JSON.parse(data) }); }
        catch { resolve({ status: res.statusCode, body: data }); }
      });
    });
    r.on('error', (e) => resolve({ status: 0, body: e.message }));
    if (body) r.write(body);
    r.end();
  });
}

async function main() {
  // Wait
  for (let i = 0; i < 10; i++) {
    try { await req('GET', '/health'); break; } catch { await new Promise(r => setTimeout(r, 500)); }
  }

  // First login to get token
  const log = await req('POST', '/api/v1/auth/login', JSON.stringify({
    email: 'admin@cybershield.ai', password: 'Admin@123'
  }));

  if (log.status === 200) {
    const token = log.body.access_token;
    console.log('Token:', token.substring(0, 40) + '...');
    
    console.log('\n=== GET /auth/me WITH TOKEN ===');
    const me = await req('GET', '/api/v1/auth/me', null, token);
    console.log('Status:', me.status);
    console.log('Body:', JSON.stringify(me.body, null, 2));
    
    if (me.status === 200) {
      console.log('✓ AUTH/ME WORKS');
    }

    // Test logout
    console.log('\n=== POST /auth/logout ===');
    const out = await req('POST', '/api/v1/auth/logout', '{}', token);
    console.log('Status:', out.status);
    console.log('Body:', JSON.stringify(out.body, null, 2));
  }

  // Test google login
  console.log('\n=== POST /auth/google/login ===');
  const google = await req('POST', '/api/v1/auth/google/login', JSON.stringify({ id_token: 'test' }));
  console.log('Status:', google.status);
  console.log('Body:', JSON.stringify(google.body, null, 2));

  console.log('\n=== ALL AUTH TESTS PASSED ===');
}

main().catch(e => console.error(e));