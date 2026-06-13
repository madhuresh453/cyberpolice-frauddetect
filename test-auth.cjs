// Test script for auth endpoints
const http = require('http');

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
      path: path,
      method: method,
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(body)
      }
    };

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, body: JSON.parse(data) });
        } catch {
          resolve({ status: res.statusCode, body: data });
        }
      });
    });

    req.on('error', (err) => reject(err));
    req.write(body);
    req.end();
  });
}

async function main() {
  console.log('\n=== REGISTER TEST ===');
  try {
    const reg = await makeRequest('POST', '/api/v1/auth/register', registerData);
    console.log(`Status: ${reg.status}`);
    console.log(`Response:`, JSON.stringify(reg.body, null, 2));
    
    if (reg.status === 201) {
      console.log('\n✓ REGISTRATION SUCCESS');
      
      console.log('\n=== LOGIN TEST ===');
      const log = await makeRequest('POST', '/api/v1/auth/login', loginData);
      console.log(`Status: ${log.status}`);
      console.log(`Response:`, JSON.stringify(log.body, null, 2));
      
      if (log.status === 200) {
        console.log('\n✓ LOGIN SUCCESS');
      } else {
        console.log('\n✗ LOGIN FAILED');
      }
    } else {
      console.log('\n✗ REGISTRATION FAILED');
    }
  } catch (err) {
    console.error('Request failed:', err.message);
  }
}

main();