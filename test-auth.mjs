import http from 'http';

const registerData = JSON.stringify({
  email: "citizen@test.com",
  phone_number: "+919876543210",
  password: "Citizen@123",
  full_name: "Test Citizen",
  user_type: "citizen"
});

const loginData = JSON.stringify({
  email: "citizen@test.com",
  password: "Citizen@123"
});

function makeRequest(method, path, body) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'localhost',
      port: 5000,
      path,
      method,
      headers: { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(body) }
    };
    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => {
        try { resolve({ status: res.statusCode, body: JSON.parse(data) }); }
        catch { resolve({ status: res.statusCode, body: data }); }
      });
    });
    req.on('error', (err) => reject(err));
    req.write(body);
    req.end();
  });
}

async function main() {
  // Wait for server
  for (let i = 0; i < 30; i++) {
    try {
      await new Promise((r) => {
        const req = http.get('http://localhost:5000/health', r);
        req.on('error', r);
        req.setTimeout(1000, () => { req.destroy(); r(); });
      });
      console.log('Server detected!');
      break;
    } catch { 
      await new Promise(r => setTimeout(r, 1000));
    }
  }

  console.log('\n=== REGISTER TEST ===');
  const reg = await makeRequest('POST', '/api/v1/auth/register', registerData);
  console.log(`Status: ${reg.status}`);
  console.log(`Response:`, JSON.stringify(reg.body, null, 2));
  
  if (reg.status === 201) {
    console.log('\n✓ REGISTRATION SUCCESS');
    console.log('\n=== LOGIN TEST ===');
    const log = await makeRequest('POST', '/api/v1/auth/login', loginData);
    console.log(`Status: ${log.status}`);
    console.log(`Response:`, JSON.stringify(log.body, null, 2));
    console.log(log.status === 200 ? '\n✓ LOGIN SUCCESS' : '\n✗ LOGIN FAILED');
  } else {
    console.log('\n✗ REGISTRATION FAILED');
  }
  
  console.log('\n=== LOGIN WITH WRONG PASSWORD ===');
  const bad = await makeRequest('POST', '/api/v1/auth/login', JSON.stringify({ email: "citizen@test.com", password: "wrong" }));
  console.log(`Status: ${bad.status}`, bad.status === 401 ? '✓ Correct' : '✗ Wrong');
}

main().catch(err => console.error('Fatal:', err));