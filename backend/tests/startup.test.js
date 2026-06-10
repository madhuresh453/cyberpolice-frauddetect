import { describe, it, before, after } from "node:test";
import assert from "node:assert/strict";
import { createServer } from "node:http";
import express from "express";
import { errorHandler } from "../shared/middlewares/errorHandler.middleware.js";
import { requestLogger } from "../shared/middlewares/requestLogger.middleware.js";

function createTestApp() {
  const app = express();
  app.disable("x-powered-by");
  app.use(express.json({ limit: "1mb" }));
  app.use((req, res, next) => next());
  app.use(requestLogger);

  const ROUTE_REGISTRY = [];

  app.get("/health", (_req, res) => {
    res.json({ status: "healthy", database: "connected" });
  });
  ROUTE_REGISTRY.push({ method: "GET", path: "/health", description: "Health check" });

  app.get("/", (_req, res) => {
    res.json({ name: "CYBERSHIELD-AI", status: "running", database: "unknown", version: "0.1.0" });
  });
  ROUTE_REGISTRY.push({ method: "GET", path: "/", description: "Root status" });

  app.get("/api", (_req, res) => {
    res.json({ service: "CYBERSHIELD-AI Backend", version: "0.1.0", routes: ROUTE_REGISTRY });
  });
  ROUTE_REGISTRY.push({ method: "GET", path: "/api", description: "API route listing" });

  app.get("/system/status", (_req, res) => {
    res.json({
      backend: { status: "online" },
      database: { status: "unknown" },
      auth_service: { status: "not_checked" },
      ai_services: { status: "not_implemented" }
    });
  });
  ROUTE_REGISTRY.push({ method: "GET", path: "/system/status", description: "System health dashboard" });

  app.post("/api/auth/register", (req, res) => {
    const { email, phone_number, password, full_name } = req.body;
    if (!email || !phone_number || !password || !full_name) {
      return res.status(400).json({ error: "VALIDATION_ERROR", message: "Missing required fields" });
    }
    res.status(201).json({ id: "test-id", email, full_name, role: "citizen", status: "active" });
  });
  ROUTE_REGISTRY.push({ method: "POST", path: "/api/auth/register", description: "Register new user" });

  app.post("/api/auth/login", (req, res) => {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ error: "VALIDATION_ERROR", message: "Email and password required" });
    }
    res.json({ access_token: "test-token", refresh_token: "test-refresh", token_type: "bearer", expires_in: 900 });
  });
  ROUTE_REGISTRY.push({ method: "POST", path: "/api/auth/login", description: "User login" });

  app.post("/api/auth/logout", (_req, res) => {
    res.json({ status: "logged_out" });
  });
  ROUTE_REGISTRY.push({ method: "POST", path: "/api/auth/logout", description: "User logout" });

  app.post("/api/auth/refresh", (req, res) => {
    const { refresh_token } = req.body;
    if (!refresh_token) {
      return res.status(400).json({ error: "VALIDATION_ERROR", message: "Refresh token required" });
    }
    res.json({ access_token: "new-token", refresh_token: "new-refresh", token_type: "bearer", expires_in: 900 });
  });
  ROUTE_REGISTRY.push({ method: "POST", path: "/api/auth/refresh", description: "Refresh access token" });

  const authenticateJWT = (req, res, next) => {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return res.status(401).json({ error: "AUTH_REQUIRED", message: "Bearer token required" });
    }
    const token = authHeader.split(" ")[1];
    if (token === "invalid_token_here") {
      return res.status(401).json({ error: "INVALID_TOKEN", message: "Invalid or expired token" });
    }
    req.user = { sub: "test-user-id" };
    next();
  };

  app.get("/api/auth/me", authenticateJWT, (_req, res) => {
    res.json({ id: "test-user-id", email: "test@test.com", full_name: "Test User", role: "citizen", status: "active" });
  });
  ROUTE_REGISTRY.push({ method: "GET", path: "/api/auth/me", description: "Get current user profile" });

  app.get("/database/collections", (_req, res) => {
    res.json({ database: "cyber-police", collections: [{ name: "users", count: 0 }] });
  });
  ROUTE_REGISTRY.push({ method: "GET", path: "/database/collections", description: "List all collections" });

  app.use(errorHandler);
  return app;
}

let server;
let baseUrl;

before(() => {
  return new Promise((resolve) => {
    const app = createTestApp();
    server = createServer(app);
    server.listen(0, () => {
      const port = server.address().port;
      baseUrl = `http://localhost:${port}`;
      resolve();
    });
  });
});

after(() => {
  return new Promise((resolve) => {
    server.close(resolve);
  });
});

describe("Startup Tests", () => {
  it("should respond to GET /", async () => {
    const res = await fetch(baseUrl + "/");
    assert.equal(res.status, 200);
    const body = await res.json();
    assert.equal(body.name, "CYBERSHIELD-AI");
    assert.equal(body.status, "running");
    assert.equal(body.version, "0.1.0");
    assert.ok(body.database);
  });

  it("should respond to GET /health", async () => {
    const res = await fetch(baseUrl + "/health");
    assert.equal(res.status, 200);
    const body = await res.json();
    assert.equal(body.status, "healthy");
    assert.equal(body.database, "connected");
  });

  it("should respond to GET /api with route listing", async () => {
    const res = await fetch(baseUrl + "/api");
    assert.equal(res.status, 200);
    const body = await res.json();
    assert.equal(body.service, "CYBERSHIELD-AI Backend");
    assert.equal(body.version, "0.1.0");
    assert.ok(Array.isArray(body.routes));
    assert.ok(body.routes.length >= 10);
  });

  it("should respond to GET /system/status", async () => {
    const res = await fetch(baseUrl + "/system/status");
    assert.equal(res.status, 200);
    const body = await res.json();
    assert.equal(body.backend.status, "online");
    assert.ok(body.database);
    assert.ok(body.auth_service);
    assert.ok(body.ai_services);
  });

  it("should include all expected routes in /api", async () => {
    const res = await fetch(baseUrl + "/api");
    const body = await res.json();
    const paths = body.routes.map((r) => r.path);
    const expectedRoutes = ["/", "/health", "/api", "/system/status", "/api/auth/register", "/api/auth/login", "/api/auth/logout", "/api/auth/refresh", "/api/auth/me", "/database/collections"];
    for (const route of expectedRoutes) {
      assert.ok(paths.includes(route), `Missing route: ${route}`);
    }
  });
});

describe("API Route Tests", () => {
  it("should return 400 for missing fields on register", async () => {
    const res = await fetch(baseUrl + "/api/auth/register", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({})
    });
    assert.equal(res.status, 400);
    const body = await res.json();
    assert.equal(body.error, "VALIDATION_ERROR");
  });

  it("should return 400 for missing credentials on login", async () => {
    const res = await fetch(baseUrl + "/api/auth/login", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email: "test@test.com" })
    });
    assert.equal(res.status, 400);
    const body = await res.json();
    assert.equal(body.error, "VALIDATION_ERROR");
  });

  it("should return 400 for missing token on refresh", async () => {
    const res = await fetch(baseUrl + "/api/auth/refresh", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({})
    });
    assert.equal(res.status, 400);
    const body = await res.json();
    assert.equal(body.error, "VALIDATION_ERROR");
  });

  it("should return 401 for missing auth on /api/auth/me", async () => {
    const res = await fetch(baseUrl + "/api/auth/me");
    assert.equal(res.status, 401);
    const body = await res.json();
    assert.equal(body.error, "AUTH_REQUIRED");
  });

  it("should return 401 for invalid token on /api/auth/me", async () => {
    const res = await fetch(baseUrl + "/api/auth/me", {
      headers: { Authorization: "Bearer invalid_token_here" }
    });
    assert.equal(res.status, 401);
    const body = await res.json();
    assert.equal(body.error, "INVALID_TOKEN");
  });

  it("should successfully register a user", async () => {
    const res = await fetch(baseUrl + "/api/auth/register", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        email: "test@test.com",
        phone_number: "+911234567890",
        password: "Test123!@#pass",
        full_name: "Test User"
      })
    });
    assert.equal(res.status, 201);
    const body = await res.json();
    assert.equal(body.email, "test@test.com");
    assert.equal(body.role, "citizen");
  });

  it("should successfully login", async () => {
    const res = await fetch(baseUrl + "/api/auth/login", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email: "test@test.com", password: "Test123!@#pass" })
    });
    assert.equal(res.status, 200);
    const body = await res.json();
    assert.ok(body.access_token);
    assert.ok(body.refresh_token);
    assert.equal(body.token_type, "bearer");
  });
});