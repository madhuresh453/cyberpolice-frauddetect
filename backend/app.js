import express from "express";
import mongoose from "mongoose";
import { databaseHealthMiddleware } from "./shared/middlewares/databaseHealth.middleware.js";
import { errorHandler } from "./shared/middlewares/errorHandler.middleware.js";
import { requestLogger } from "./shared/middlewares/requestLogger.middleware.js";
import healthRoutes from "./shared/routes/health.routes.js";
import citizenRoutes from "./shared/routes/citizen.routes.js";
import policeRoutes from "./shared/routes/police.routes.js";
import ispRoutes from "./shared/routes/isp.routes.js";
import governmentRoutes from "./shared/routes/government.routes.js";
import { getDatabaseHealth } from "./shared/database/healthcheck.js";
import { connectRedis } from "./shared/database/redis.js";
import { connectNeo4j } from "./shared/services/neo4j.service.js";
import { config } from "./shared/database/database.config.js";

const ROUTE_REGISTRY = [];

export function createApp() {
  const app = express();

  app.disable("x-powered-by");

  // Increase limit for evidence uploads
  app.use(express.json({ limit: "10mb" }));
  app.use(express.urlencoded({ extended: true, limit: "10mb" }));
  app.use(requestLogger);
  app.use(databaseHealthMiddleware);
  app.use(healthRoutes);

  // Connect Redis and Neo4j asynchronously (non-blocking)
  connectRedis().catch(() => {});
  connectNeo4j().catch(() => {});

  // ===== ROOT ROUTE =====
  app.get("/", async (_req, res) => {
    const health = await getDatabaseHealth();
    res.json({
      name: "CYBERSHIELD-AI",
      status: "running",
      database: health.connected ? "connected" : "disconnected",
      version: "0.1.0"
    });
  });
  ROUTE_REGISTRY.push({ method: "GET", path: "/", description: "Root status" });

  // ===== HEALTH ROUTE (complementary to health.routes.js) =====
  app.get("/health", async (_req, res, next) => {
    try {
      const health = await getDatabaseHealth();
      res.status(health.connected ? 200 : 503).json({
        status: health.connected ? "healthy" : "unhealthy",
        database: health.connected ? "connected" : "disconnected"
      });
    } catch (error) {
      next(error);
    }
  });
  ROUTE_REGISTRY.push({ method: "GET", path: "/health", description: "Health check" });

  // ===== API ROUTE LISTING =====
  app.get("/api", (_req, res) => {
    res.json({
      service: "CYBERSHIELD-AI Backend",
      version: "0.1.0",
      routes: ROUTE_REGISTRY
    });
  });
  ROUTE_REGISTRY.push({ method: "GET", path: "/api", description: "API route listing" });

  // ===== SYSTEM STATUS DASHBOARD =====
  app.get("/system/status", async (_req, res, next) => {
    try {
      const health = await getDatabaseHealth();
      const authServiceStatus = await checkAuthService();
      const mongooseState = ["disconnected", "connected", "connecting", "disconnecting"];

      res.json({
        backend: {
          status: "online",
          port: config.port,
          environment: config.nodeEnv,
          uptime: process.uptime()
        },
        database: {
          status: health.connected ? "online" : "offline",
          name: config.dbName,
          readyState: mongooseState[mongoose.connection.readyState] || "unknown",
          collections: health.collections || []
        },
        auth_service: authServiceStatus,
        ai_services: {
          status: "not_implemented",
          services: [
            "speech-to-text",
            "scam-classification",
            "deepfake-detection",
            "keyword-engine",
            "intent-analysis",
            "sentiment-analysis",
            "fraud-pattern-engine",
            "risk-scoring-engine"
          ]
        }
      });
    } catch (error) {
      next(error);
    }
  });
  ROUTE_REGISTRY.push({ method: "GET", path: "/system/status", description: "System health dashboard" });

  // ===== AUTH ROUTES (Express native auth endpoints) =====
  app.post("/api/auth/register", async (req, res, next) => {
    try {
      const { email, phone_number, password, full_name, user_type } = req.body;

      if (!email || !phone_number || !password || !full_name) {
        return res.status(400).json({ error: "VALIDATION_ERROR", message: "Missing required fields" });
      }

      const existingUser = await mongoose.models.User.findOne({
        $or: [{ email }, { phoneNumber: phone_number }]
      });

      if (existingUser) {
        return res.status(409).json({ error: "CONFLICT", message: "User already exists" });
      }

      const bcrypt = await import("bcrypt");
      const hashedPassword = await bcrypt.hash(password, 12);
      const role = user_type || "citizen";

      const user = await mongoose.models.User.create({
        email,
        phoneNumber: phone_number,
        passwordHash: hashedPassword,
        fullName: full_name,
        role,
        status: "active"
      });

      res.status(201).json({
        id: user._id.toString(),
        email: user.email,
        phone_number: user.phoneNumber,
        full_name: user.fullName,
        role: user.role,
        status: user.status,
        created_at: user.createdAt
      });
    } catch (error) {
      next(error);
    }
  });
  ROUTE_REGISTRY.push({ method: "POST", path: "/api/auth/register", description: "Register new user" });

  app.post("/api/auth/login", async (req, res, next) => {
    try {
      const { email, password } = req.body;
      if (!email || !password) {
        return res.status(400).json({ error: "VALIDATION_ERROR", message: "Email and password required" });
      }

      const user = await mongoose.models.User.findOne({ email }).select("+passwordHash");
      if (!user) {
        return res.status(401).json({ error: "AUTH_FAILED", message: "Invalid credentials" });
      }

      const bcrypt = await import("bcrypt");
      const valid = await bcrypt.compare(password, user.passwordHash);
      if (!valid) {
        return res.status(401).json({ error: "AUTH_FAILED", message: "Invalid credentials" });
      }

      const jwt = await import("jsonwebtoken");
      const accessToken = jwt.sign(
        { sub: user._id.toString(), email: user.email, role: user.role },
        config.jwtSecret,
        { expiresIn: "15m" }
      );

      const refreshToken = jwt.sign(
        { sub: user._id.toString(), type: "refresh" },
        config.jwtSecret,
        { expiresIn: "30d" }
      );

      res.json({
        access_token: accessToken,
        refresh_token: refreshToken,
        token_type: "bearer",
        expires_in: 900
      });
    } catch (error) {
      next(error);
    }
  });
  ROUTE_REGISTRY.push({ method: "POST", path: "/api/auth/login", description: "User login" });

  app.post("/api/auth/logout", async (req, res) => {
    res.json({ status: "logged_out" });
  });
  ROUTE_REGISTRY.push({ method: "POST", path: "/api/auth/logout", description: "User logout" });

  app.post("/api/auth/refresh", async (req, res, next) => {
    try {
      const { refresh_token } = req.body;
      if (!refresh_token) {
        return res.status(400).json({ error: "VALIDATION_ERROR", message: "Refresh token required" });
      }

      const jwt = await import("jsonwebtoken");
      const payload = jwt.verify(refresh_token, config.jwtSecret);

      if (payload.type !== "refresh") {
        return res.status(401).json({ error: "INVALID_TOKEN", message: "Invalid token type" });
      }

      const user = await mongoose.models.User.findById(payload.sub);
      if (!user || user.status !== "active") {
        return res.status(401).json({ error: "USER_INACTIVE", message: "User is inactive" });
      }

      const accessToken = jwt.sign(
        { sub: user._id.toString(), email: user.email, role: user.role },
        config.jwtSecret,
        { expiresIn: "15m" }
      );

      const newRefreshToken = jwt.sign(
        { sub: user._id.toString(), type: "refresh" },
        config.jwtSecret,
        { expiresIn: "30d" }
      );

      res.json({
        access_token: accessToken,
        refresh_token: newRefreshToken,
        token_type: "bearer",
        expires_in: 900
      });
    } catch (error) {
      next(error);
    }
  });
  ROUTE_REGISTRY.push({ method: "POST", path: "/api/auth/refresh", description: "Refresh access token" });

  // ===== AUTH MIDDLEWARE (JWT verification) =====
  const authenticateJWT = async (req, res, next) => {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return res.status(401).json({ error: "AUTH_REQUIRED", message: "Bearer token required" });
    }

    try {
      const jwt = await import("jsonwebtoken");
      const token = authHeader.split(" ")[1];
      const payload = jwt.verify(token, config.jwtSecret);
      req.user = payload;
      next();
    } catch (error) {
      return res.status(401).json({ error: "INVALID_TOKEN", message: "Invalid or expired token" });
    }
  };

  app.get("/api/auth/me", authenticateJWT, async (req, res, next) => {
    try {
      const user = await mongoose.models.User.findById(req.user.sub);
      if (!user) {
        return res.status(404).json({ error: "NOT_FOUND", message: "User not found" });
      }
      res.json({
        id: user._id.toString(),
        email: user.email,
        phone_number: user.phoneNumber,
        full_name: user.fullName,
        role: user.role,
        status: user.status,
        last_login_at: user.updatedAt
      });
    } catch (error) {
      next(error);
    }
  });
  ROUTE_REGISTRY.push({ method: "GET", path: "/api/auth/me", description: "Get current user profile" });

  // ===== DATABASE VALIDATION ROUTE =====
  app.get("/database/collections", async (_req, res, next) => {
    try {
      if (mongoose.connection.readyState !== 1) {
        return res.status(503).json({ error: "DATABASE_UNAVAILABLE", message: "MongoDB not connected" });
      }
      const collections = await mongoose.connection.db.listCollections().toArray();
      const collectionData = [];
      for (const col of collections) {
        const count = await mongoose.connection.db.collection(col.name).countDocuments();
        collectionData.push({ name: col.name, count });
      }
      res.json({ database: config.dbName, collections: collectionData });
    } catch (error) {
      next(error);
    }
  });
  ROUTE_REGISTRY.push({ method: "GET", path: "/database/collections", description: "List all collections with counts" });

  // ===== MOUNT DOMAIN ROUTES =====
  app.use("/api/v1/citizen", citizenRoutes);
  ROUTE_REGISTRY.push(
    { method: "POST", path: "/api/v1/citizen/report/call", description: "Report fraudulent call" },
    { method: "POST", path: "/api/v1/citizen/report/sms", description: "Report fraudulent SMS" },
    { method: "POST", path: "/api/v1/citizen/report/whatsapp", description: "Report fraudulent WhatsApp message" },
    { method: "GET", path: "/api/v1/citizen/trust-score/:number", description: "Get trust score for a number" },
    { method: "GET", path: "/api/v1/citizen/history", description: "Get report history" },
    { method: "POST", path: "/api/v1/citizen/block-number", description: "Block a number" },
    { method: "POST", path: "/api/v1/citizen/emergency-sos", description: "Send SOS alert" },
    { method: "GET", path: "/api/v1/citizen/family-protection", description: "Get family protection status" },
    { method: "POST", path: "/api/v1/citizen/evidence/upload", description: "Upload evidence" }
  );

  app.use("/api/v1/police", policeRoutes);
  ROUTE_REGISTRY.push(
    { method: "GET", path: "/api/v1/police/cases", description: "List all cases" },
    { method: "POST", path: "/api/v1/police/cases", description: "Create new case" },
    { method: "GET", path: "/api/v1/police/firs", description: "List all FIRs" },
    { method: "POST", path: "/api/v1/police/firs", description: "Create new FIR" },
    { method: "GET", path: "/api/v1/police/evidence", description: "List all evidence" },
    { method: "GET", path: "/api/v1/police/analytics", description: "Get fraud analytics" },
    { method: "GET", path: "/api/v1/police/heatmap", description: "Get fraud heatmap" },
    { method: "GET", path: "/api/v1/police/fraud-network", description: "Get fraud network data" },
    { method: "POST", path: "/api/v1/police/bank-freeze", description: "Request bank account freeze" },
    { method: "POST", path: "/api/v1/police/deepfake-analysis", description: "Submit deepfake analysis" }
  );

  app.use("/api/v1/isp", ispRoutes);
  ROUTE_REGISTRY.push(
    { method: "GET", path: "/api/v1/isp/number-intelligence", description: "Get number intelligence" },
    { method: "GET", path: "/api/v1/isp/sms-firewall", description: "Get SMS firewall data" },
    { method: "GET", path: "/api/v1/isp/traffic-analysis", description: "Get traffic analysis" },
    { method: "GET", path: "/api/v1/isp/blocked-numbers", description: "Get blocked numbers" },
    { method: "GET", path: "/api/v1/isp/fraud-campaigns", description: "Get fraud campaigns" },
    { method: "GET", path: "/api/v1/isp/threat-feed", description: "Get threat feed" }
  );

  app.use("/api/v1/government", governmentRoutes);
  ROUTE_REGISTRY.push(
    { method: "GET", path: "/api/v1/government/national-dashboard", description: "National fraud dashboard" },
    { method: "GET", path: "/api/v1/government/state-dashboard", description: "State fraud dashboard" },
    { method: "GET", path: "/api/v1/government/district-dashboard", description: "District fraud dashboard" },
    { method: "GET", path: "/api/v1/government/fraud-trends", description: "Fraud trend analysis" },
    { method: "GET", path: "/api/v1/government/economic-impact", description: "Economic impact analysis" }
  );

  // ===== ERROR HANDLER (must be last) =====
  app.use(errorHandler);

  return app;
}

async function checkAuthService() {
  try {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 2000);
    const response = await fetch("http://localhost:5000/health", { signal: controller.signal });
    clearTimeout(timeout);
    if (response.ok) {
      return { status: "online", type: "fastapi" };
    }
    return { status: "offline", type: "fastapi" };
  } catch {
    return { status: "offline", type: "fastapi" };
  }
}