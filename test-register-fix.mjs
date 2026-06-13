import http from "http";

const BASE_URL = "http://localhost:5000";

function request(method, path, data) {
  return new Promise((resolve, reject) => {
    const body = data ? JSON.stringify(data) : undefined;
    const opts = {
      hostname: "localhost",
      port: 5000,
      path,
      method,
      headers: {
        "Content-Type": "application/json",
        ...(body ? { "Content-Length": Buffer.byteLength(body) } : {}),
      },
    };

    const req = http.request(opts, (res) => {
      let responseBody = "";
      res.on("data", (chunk) => (responseBody += chunk));
      res.on("end", () => {
        try {
          resolve({
            status: res.statusCode,
            headers: res.headers,
            data: JSON.parse(responseBody),
          });
        } catch {
          resolve({ status: res.statusCode, data: responseBody });
        }
      });
    });

    req.on("error", reject);
    if (body) req.write(body);
    req.end();
  });
}

async function main() {
  console.log("=== TEST 1: Register with raw phone number (6239015723) ===");
  const registerResult = await request("POST", "/api/v1/auth/register", {
    email: "testuser" + Date.now() + "@example.com",
    phone_number: "6239015723",
    password: "TestPass123",
    full_name: "Test User",
  });
  console.log("Status:", registerResult.status);
  console.log("Body:", JSON.stringify(registerResult.data, null, 2));

  if (registerResult.status === 201) {
    const accessToken = registerResult.data.accessToken;
    const userId = registerResult.data.user?.id;

    console.log("\n=== TEST 2: GET /api/v1/auth/me with JWT ===");
    const meResult = await new Promise((resolve, reject) => {
      const opts = {
        hostname: "localhost",
        port: 5000,
        path: "/api/v1/auth/me",
        method: "GET",
        headers: {
          Authorization: `Bearer ${accessToken}`,
        },
      };
      const req = http.request(opts, (res) => {
        let body = "";
        res.on("data", (chunk) => (body += chunk));
        res.on("end", () => {
          try {
            resolve({ status: res.statusCode, data: JSON.parse(body) });
          } catch {
            resolve({ status: res.statusCode, data: body });
          }
        });
      });
      req.on("error", reject);
      req.end();
    });
    console.log("Status:", meResult.status);
    console.log("Body:", JSON.stringify(meResult.data, null, 2));

    // Verify phone number is stored in E.164
    const phoneInResponse = registerResult.data.user?.phoneNumber;
    if (phoneInResponse === "+916239015723") {
      console.log("\n✅ PASS: Phone number stored as +916239015723");
    } else {
      console.log(`\n❌ FAIL: Expected +916239015723, got ${phoneInResponse}`);
    }

    // Verify /me returns all required fields
    const meData = meResult.data;
    const requiredFields = ["id", "email", "fullName", "phoneNumber", "role", "status"];
    const missingFields = requiredFields.filter((f) => !meData[f]);
    if (missingFields.length === 0) {
      console.log("✅ PASS: /me returns all required fields:", requiredFields);
    } else {
      console.log(`❌ FAIL: /me missing fields: ${missingFields}`);
    }
  }

  console.log("\n=== TEST 3: Login ===");
  const loginResult = await request("POST", "/api/v1/auth/login", {
    email: registerResult.data?.user?.email || "testuser@example.com",
    password: "TestPass123",
  });
  console.log("Status:", loginResult.status);
  console.log("Body:", JSON.stringify(loginResult.data, null, 2));

  console.log("\n=== TEST 4: Google Login (development mode) ===");
  const googleResult = await request("POST", "/api/v1/auth/google/login", {
    id_token: "test_google_token_for_development",
  });
  console.log("Status:", googleResult.status);
  const googleData = googleResult.data;
  if (googleData?.success && googleData?.accessToken?.startsWith("ey")) {
    console.log("✅ PASS: Google login returns real JWT (starts with 'ey')");
  } else {
    console.log("❌ FAIL: Google login did not return real JWT");
    console.log("   accessToken:", googleData?.accessToken?.substring(0, 30));
  }

  console.log("\n=== TEST 5: Refresh Token ===");
  const refreshResult = await request("POST", "/api/v1/auth/refresh", {
    refresh_token: registerResult.data?.refreshToken || loginResult.data?.refreshToken,
  });
  console.log("Status:", refreshResult.status);
  if (refreshResult.data?.success && refreshResult.data?.accessToken?.startsWith("ey")) {
    console.log("✅ PASS: Refresh returns new real JWT");
  } else {
    console.log("Body:", JSON.stringify(refreshResult.data, null, 2));
  }

  // Summary
  console.log("\n=== SUMMARY ===");
  console.log("Register (raw phone):", registerResult.status === 201 ? "✅ PASS" : "❌ FAIL");
  console.log("/me with JWT:", meResult?.status === 200 ? "✅ PASS" : "❌ FAIL");
  console.log("Login:", loginResult.status === 200 ? "✅ PASS" : "❌ FAIL");
  console.log("Google login:", googleResult.status === 200 ? "✅ PASS" : "❌ FAIL");
  console.log("Refresh:", refreshResult.status === 200 ? "✅ PASS" : "❌ FAIL");
}

main().catch(console.error);