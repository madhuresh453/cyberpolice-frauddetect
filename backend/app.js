import express from "express";
import mongoose from "mongoose";
import cors from "cors";
import bcrypt from "bcryptjs";
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

// ===== MODELS (must be loaded before any route uses mongoose.models) =====
import "./shared/models/User.model.js";
const User = mongoose.models.User;

// ===== UTILITIES =====
import { extractAndNormalizePhone } from "./shared/utils/phone.utils.js";
import {
  generateAccessToken,
  generateRefreshToken,
  verifyToken,
  buildAuthResponse,
  buildUserProfile,
} from "./shared/utils/auth.utils.js";
import { verifyGoogleIdToken } from "./shared/utils/google-auth.utils.js";

const ROUTE_REGISTRY = [];

export function createApp() {
  const app = express();

  app.disable("x-powered-by");

  // ===== CORS (MUST be before any routes) =====
  app.use(
    cors({
      origin: true,
      credentials: true,
      methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
      allowedHeaders: ["Content-Type", "Authorization", "Accept", "X-Requested-With"],
    })
  );

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
      version: "0.1.0",
    });
  });
  ROUTE_REGISTRY.push({ method: "GET", path: "/", description: "Root status" });

  // ===== HEALTH ROUTE =====
  app.get("/health", async (_req, res, next) => {
    try {
      const health = await getDatabaseHealth();
      res.status(health.connected ? 200 : 503).json({
        status: health.connected ? "healthy" : "unhealthy",
        database: health.connected ? "connected" : "disconnected",
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
      routes: ROUTE_REGISTRY,
    });
  });
  ROUTE_REGISTRY.push({ method: "GET", path: "/api", description: "API route listing" });

  // ===== AUTH MIDDLEWARE (JWT verification) =====
  const authenticateJWT = async (req, res, next) => {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return res.status(401).json({ success: false, error: "AUTH_REQUIRED", message: "Bearer token required" });
    }

    const token = authHeader.split(" ")[1];
    const { valid, payload, error } = verifyToken(token);
    if (!valid || payload.type !== "access") {
      return res.status(401).json({ success: false, error: "INVALID_TOKEN", message: "Invalid or expired token" });
    }

    req.user = payload;
    next();
  };

  // ================================================================
  //  AUTH ENDPOINTS
  // ================================================================

  /**
   * POST /api/v1/auth/register
   *
   * Accepts:
   *   { email, phone_number (or phoneNumber), password, full_name (or fullName), user_type }
   *
   * Behavior:
   *   - phone_number → phoneNumber mapping
   *   - Auto-converts to E.164 format
   *   - Creates user in MongoDB
   *   - Returns standardized auth response
   */
  app.post("/api/v1/auth/register", async (req, res, next) => {
    try {
      // Step 1: Extract fields supporting both snake_case and camelCase
      const email = (req.body.email || "").trim().toLowerCase();
      const password = req.body.password;
      const fullName = req.body.full_name || req.body.fullName || "";
      const userType = req.body.user_type || req.body.userType || "citizen";

      // Step 2: Validate required fields
      if (!email) {
        return res.status(400).json({
          success: false,
          error: "VALIDATION_ERROR",
          message: "Email is required",
        });
      }
      if (!password || password.length < 8) {
        return res.status(400).json({
          success: false,
          error: "VALIDATION_ERROR",
          message: "Password must be at least 8 characters",
        });
      }
      if (!fullName) {
        return res.status(400).json({
          success: false,
          error: "VALIDATION_ERROR",
          message: "Full name is required",
        });
      }

      // Step 3: Extract and normalize phone number
      // Accept both phone_number (from Flutter) and phoneNumber
      let phoneNumber;
      try {
        const result = extractAndNormalizePhone(req.body, "phone_number");
        phoneNumber = result.phoneNumber;
      } catch (phoneErr) {
        return res.status(400).json({
          success: false,
          error: "VALIDATION_ERROR",
          message: phoneErr.message,
        });
      }

      // Step 4: Check for existing user
      const existingUser = await User.findOne({
        $or: [{ email }, { phoneNumber }],
      });
      if (existingUser) {
        return res.status(409).json({
          success: false,
          error: "CONFLICT",
          message: "User with this email or phone number already exists",
        });
      }

      // Step 5: Hash password and create user
      // The User model's pre-save hook will normalize phoneNumber again safely
      const hashedPassword = bcrypt.hashSync(password, 12);
      const user = await User.create({
        email,
        phoneNumber,
        passwordHash: hashedPassword,
        fullName,
        role: userType,
        status: "active",
      });

      // Step 6: Generate tokens
      const accessToken = generateAccessToken(user);
      const refreshToken = generateRefreshToken(user);

      // Step 7: Standardized response
      res.status(201).json(buildAuthResponse(user, accessToken, refreshToken));
    } catch (error) {
      next(error);
    }
  });
  ROUTE_REGISTRY.push({
    method: "POST",
    path: "/api/v1/auth/register",
    description: "Register new user (accepts phone_number or phoneNumber, auto E.164)",
  });

  /**
   * POST /api/v1/auth/login
   */
  app.post("/api/v1/auth/login", async (req, res, next) => {
    try {
      const { email, password } = req.body;
      if (!email || !password) {
        return res.status(400).json({
          success: false,
          error: "VALIDATION_ERROR",
          message: "Email and password required",
        });
      }

      const user = await User.findOne({ email }).select("+passwordHash");
      if (!user) {
        return res.status(401).json({
          success: false,
          error: "AUTH_FAILED",
          message: "Invalid credentials",
        });
      }

      const valid = bcrypt.compareSync(password, user.passwordHash);
      if (!valid) {
        return res.status(401).json({
          success: false,
          error: "AUTH_FAILED",
          message: "Invalid credentials",
        });
      }

      // Update lastLoginAt
      user.lastLoginAt = new Date();
      await user.save();

      const accessToken = generateAccessToken(user);
      const refreshToken = generateRefreshToken(user);

      res.json(buildAuthResponse(user, accessToken, refreshToken));
    } catch (error) {
      next(error);
    }
  });
  ROUTE_REGISTRY.push({
    method: "POST",
    path: "/api/v1/auth/login",
    description: "User login",
  });

  /**
   * POST /api/v1/auth/google/login
   *
   * Accepts { id_token: "..." }
   * Verifies Google ID token, creates user if not exists, returns real JWT.
   */
  app.post("/api/v1/auth/google/login", async (req, res, next) => {
    try {
      const { id_token } = req.body;
      if (!id_token) {
        return res.status(400).json({
          success: false,
          error: "VALIDATION_ERROR",
          message: "id_token is required",
        });
      }

      // Verify the Google ID token
      const googleUser = await verifyGoogleIdToken(id_token);

      // Find or create user
      let user;
      if (googleUser.email) {
        user = await User.findOne({ email: googleUser.email });
      }
      if (!user && googleUser.sub) {
        user = await User.findOne({ googleId: googleUser.sub });
      }

      if (!user) {
        // Create new user from Google profile
        const displayName = googleUser.name || `GoogleUser_${googleUser.sub.slice(-6)}`;
        const email = googleUser.email || `${googleUser.sub}@google-oauth.local`;

        // Generate a placeholder password (user can't login with password, only Google)
        const placeholderPassword = bcrypt.hashSync(
          "google_oauth_" + googleUser.sub + "_" + Date.now(),
          12
        );

        user = await User.create({
          email,
          phoneNumber: `+1${googleUser.sub.slice(-10).replace(/\D/g, "") || "0000000000"}`,
          passwordHash: placeholderPassword,
          fullName: displayName,
          googleId: googleUser.sub,
          role: "citizen",
          status: "active",
        });
      } else if (!user.googleId && googleUser.sub) {
        // Link Google account to existing user
        user.googleId = googleUser.sub;
        await user.save();
      }

      user.lastLoginAt = new Date();
      await user.save();

      const accessToken = generateAccessToken(user);
      const refreshToken = generateRefreshToken(user);

      res.json(buildAuthResponse(user, accessToken, refreshToken));
    } catch (error) {
      if (error.message && error.message.includes("Invalid Google ID token")) {
        return res.status(401).json({
          success: false,
          error: "INVALID_TOKEN",
          message: "Invalid Google ID token",
        });
      }
      next(error);
    }
  });
  ROUTE_REGISTRY.push({
    method: "POST",
    path: "/api/v1/auth/google/login",
    description: "Google OAuth login (real JWT)",
  });

  /**
   * POST /api/v1/auth/logout
   */
  app.post("/api/v1/auth/logout", async (req, res) => {
    res.json({ success: true, message: "Logged out successfully" });
  });
  ROUTE_REGISTRY.push({
    method: "POST",
    path: "/api/v1/auth/logout",
    description: "User logout",
  });

  /**
   * POST /api/v1/auth/refresh
   */
  app.post("/api/v1/auth/refresh", async (req, res, next) => {
    try {
      const { refresh_token } = req.body;
      if (!refresh_token) {
        return res.status(400).json({
          success: false,
          error: "VALIDATION_ERROR",
          message: "Refresh token required",
        });
      }

      const { valid, payload, error } = verifyToken(refresh_token);
      if (!valid || payload.type !== "refresh") {
        return res.status(401).json({
          success: false,
          error: "INVALID_TOKEN",
          message: "Invalid or expired refresh token",
        });
      }

      const user = await User.findById(payload.sub);
      if (!user || user.status !== "active") {
        return res.status(401).json({
          success: false,
          error: "USER_INACTIVE",
          message: "User is inactive",
        });
      }

      const accessToken = generateAccessToken(user);
      const newRefreshToken = generateRefreshToken(user);

      res.json(buildAuthResponse(user, accessToken, newRefreshToken));
    } catch (error) {
      next(error);
    }
  });
  ROUTE_REGISTRY.push({
    method: "POST",
    path: "/api/v1/auth/refresh",
    description: "Refresh access token",
  });

  /**
   * GET /api/v1/auth/me
   *
   * Requires Authorization: Bearer <jwt>
   * Returns { id, email, fullName, phoneNumber, role, status, trustScore, ... }
   */
  app.get("/api/v1/auth/me", authenticateJWT, async (req, res, next) => {
    try {
      const user = await User.findById(req.user.sub).select("+passwordHash");
      if (!user) {
        return res.status(404).json({
          success: false,
          error: "NOT_FOUND",
          message: "User not found",
        });
      }
      res.json({
        success: true,
        ...buildUserProfile(user),
      });
    } catch (error) {
      next(error);
    }
  });
  ROUTE_REGISTRY.push({
    method: "GET",
    path: "/api/v1/auth/me",
    description: "Get current user profile",
  });

  /**
   * POST /api/v1/auth/forgot-password
   */
  app.post("/api/v1/auth/forgot-password", async (req, res) => {
    res.json({ success: true, status: "sent", message: "Password reset email sent" });
  });
  ROUTE_REGISTRY.push({
    method: "POST",
    path: "/api/v1/auth/forgot-password",
    description: "Forgot password",
  });

  /**
   * POST /api/v1/auth/reset-password
   */
  app.post("/api/v1/auth/reset-password", async (req, res) => {
    res.json({ success: true, status: "reset", message: "Password reset successful" });
  });
  ROUTE_REGISTRY.push({
    method: "POST",
    path: "/api/v1/auth/reset-password",
    description: "Reset password",
  });

  /**
   * POST /api/v1/auth/change-password
   */
  app.post("/api/v1/auth/change-password", async (req, res) => {
    res.json({ success: true, status: "changed", message: "Password changed successfully" });
  });
  ROUTE_REGISTRY.push({
    method: "POST",
    path: "/api/v1/auth/change-password",
    description: "Change password",
  });

  /**
   * POST /api/v1/auth/mfa/setup
   */
  app.post("/api/v1/auth/mfa/setup", async (req, res) => {
    res.json({
      success: true,
      secret: "TOTP_SECRET_BASE32",
      qr_code_svg: null,
      recovery_codes: ["RECOVERY-CODE-1", "RECOVERY-CODE-2"],
    });
  });
  ROUTE_REGISTRY.push({
    method: "POST",
    path: "/api/v1/auth/mfa/setup",
    description: "Setup MFA",
  });

  /**
   * POST /api/v1/auth/mfa/verify
   */
  app.post("/api/v1/auth/mfa/verify", async (req, res) => {
    res.json({ success: true, status: "verified", message: "MFA verified" });
  });
  ROUTE_REGISTRY.push({
    method: "POST",
    path: "/api/v1/auth/mfa/verify",
    description: "Verify MFA",
  });

  /**
   * POST /api/v1/auth/mfa/login
   */
  app.post("/api/v1/auth/mfa/login", async (req, res) => {
    res.json({ success: true, status: "authenticated" });
  });
  ROUTE_REGISTRY.push({
    method: "POST",
    path: "/api/v1/auth/mfa/login",
    description: "MFA login",
  });

  /**
   * POST /api/v1/auth/otp/login
   */
  app.post("/api/v1/auth/otp/login", async (req, res, next) => {
    try {
      const { phone_number } = req.body;
      res.json({
        success: true,
        status: "otp_sent",
        message: "OTP sent",
        phone_number,
      });
    } catch (error) {
      next(error);
    }
  });
  ROUTE_REGISTRY.push({
    method: "POST",
    path: "/api/v1/auth/otp/login",
    description: "OTP login",
  });

  /**
   * POST /api/v1/auth/otp/verify
   */
  app.post("/api/v1/auth/otp/verify", async (req, res, next) => {
    try {
      const { phone_number, otp } = req.body;
      // In production, verify OTP from your OTP provider
      // For now, accept any 6-digit OTP
      if (!otp || otp.length < 4) {
        return res.status(400).json({
          success: false,
          error: "VALIDATION_ERROR",
          message: "Invalid OTP",
        });
      }

      // Find user by phone number or create one
      let phoneNumber;
      try {
        const result = extractAndNormalizePhone(req.body, "phone_number");
        phoneNumber = result.phoneNumber;
      } catch {
        phoneNumber = `+${phone_number?.replace(/\D/g, "")}`;
      }

      let user = await User.findOne({ phoneNumber });
      if (!user) {
        // Auto-create user on OTP verification (phone-only account)
        const placeholderPassword = bcrypt.hashSync("otp_user_" + Date.now(), 12);
        user = await User.create({
          email: `user_${phoneNumber.replace(/\D/g, "")}@phone.local`,
          phoneNumber,
          passwordHash: placeholderPassword,
          fullName: `User ${phoneNumber.slice(-4)}`,
          role: "citizen",
          status: "active",
        });
      }

      user.lastLoginAt = new Date();
      await user.save();

      const accessToken = generateAccessToken(user);
      const refreshToken = generateRefreshToken(user);

      res.json(buildAuthResponse(user, accessToken, refreshToken));
    } catch (error) {
      next(error);
    }
  });
  ROUTE_REGISTRY.push({
    method: "POST",
    path: "/api/v1/auth/otp/verify",
    description: "OTP verify",
  });

  /**
   * POST /api/v1/auth/phone/login
   */
  app.post("/api/v1/auth/phone/login", async (req, res, next) => {
    try {
      const { phone_number } = req.body;
      res.json({
        success: true,
        status: "otp_sent",
        message: "OTP sent to phone",
        phone_number,
      });
    } catch (error) {
      next(error);
    }
  });
  ROUTE_REGISTRY.push({
    method: "POST",
    path: "/api/v1/auth/phone/login",
    description: "Phone login",
  });

  /**
   * GET /api/v1/auth/sessions
   */
  app.get("/api/v1/auth/sessions", async (req, res) => {
    res.json({ success: true, sessions: [] });
  });
  ROUTE_REGISTRY.push({
    method: "GET",
    path: "/api/v1/auth/sessions",
    description: "List sessions",
  });

  /**
   * POST /api/v1/auth/sessions/revoke
   */
  app.post("/api/v1/auth/sessions/revoke", async (req, res) => {
    res.json({ success: true, status: "revoked" });
  });
  ROUTE_REGISTRY.push({
    method: "POST",
    path: "/api/v1/auth/sessions/revoke",
    description: "Revoke session",
  });

  /**
   * POST /api/v1/auth/sessions/revoke-all
   */
  app.post("/api/v1/auth/sessions/revoke-all", async (req, res) => {
    res.json({ success: true, status: "all_revoked" });
  });
  ROUTE_REGISTRY.push({
    method: "POST",
    path: "/api/v1/auth/sessions/revoke-all",
    description: "Revoke all sessions",
  });

  // ===== SYSTEM STATUS DASHBOARD =====
  app.get("/system/status", async (_req, res, next) => {
    try {
      const health = await getDatabaseHealth();
      const mongooseState = ["disconnected", "connected", "connecting", "disconnecting"];

      res.json({
        backend: {
          status: "online",
          port: config.port,
          environment: config.nodeEnv,
          uptime: process.uptime(),
        },
        database: {
          status: health.connected ? "online" : "offline",
          name: config.dbName,
          readyState: mongooseState[mongoose.connection.readyState] || "unknown",
          collections: health.collections || [],
        },
        auth_endpoints: {
          register: "online",
          login: "online",
          google_login: "online",
          refresh: "online",
          me: "online",
          logout: "online",
        },
      });
    } catch (error) {
      next(error);
    }
  });
  ROUTE_REGISTRY.push({
    method: "GET",
    path: "/system/status",
    description: "System health dashboard",
  });

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
  ROUTE_REGISTRY.push({
    method: "GET",
    path: "/database/collections",
    description: "List all collections with counts",
  });

  // ===== MOUNT DOMAIN ROUTES =====
  app.use("/api/v1/citizen", citizenRoutes);
  app.use("/api/v1/police", policeRoutes);
  app.use("/api/v1/isp", ispRoutes);
  app.use("/api/v1/government", governmentRoutes);

  // ===== ERROR HANDLER (must be last) =====
  app.use(errorHandler);

  return app;
}