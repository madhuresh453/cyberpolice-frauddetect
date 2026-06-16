/**
 * RAKSAAR (CyberShield AI) - Security Middleware
 * Fixes V-01 through V-16: Rate limiting, headers, CORS, sanitization
 */
import helmet from "helmet";
import cors from "cors";
import rateLimit from "express-rate-limit";
import mongoSanitize from "express-mongo-sanitize";
import { config } from "../database/database.config.js";

// ===== V-02: Security Headers (helmet - 12 headers) =====
export const securityHeaders = helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'", "'unsafe-inline'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", "data:", "https:"],
      connectSrc: ["'self'", "https://api.bhashini.gov.in"],
      fontSrc: ["'self'"],
      objectSrc: ["'none'"],
      mediaSrc: ["'self'"],
      frameSrc: ["'none'"],
    },
  },
  crossOriginEmbedderPolicy: false,
  crossOriginResourcePolicy: { policy: "cross-origin" },
});

// ===== V-03: Restricted CORS =====
const ALLOWED_ORIGINS = [
  "http://localhost:3000",
  "http://localhost:5000",
  "http://localhost:8080",
  "https://raksaar.gov.in",
  "https://police.raksaar.gov.in",
  "https://app.raksaar.gov.in",
];

export const corsMiddleware = cors({
  origin: (origin, callback) => {
    if (!origin || ALLOWED_ORIGINS.includes(origin) || config.nodeEnv === "development") {
      callback(null, true);
    } else {
      callback(new Error("CORS: Origin not allowed"));
    }
  },
  credentials: true,
  methods: ["GET", "POST", "PUT", "PATCH", "DELETE"],
  allowedHeaders: ["Content-Type", "Authorization", "Accept", "X-Requested-With"],
  maxAge: 86400,
});

// ===== V-01: Tiered Rate Limiting =====
export const globalRateLimit = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 1000,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: "RATE_LIMITED", message: "Too many requests. Try again later." },
});

export const authRateLimit = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 20,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: "RATE_LIMITED", message: "Too many auth attempts. Try again later." },
});

export const apiRateLimit = rateLimit({
  windowMs: 60 * 1000,
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: "RATE_LIMITED", message: "API rate limit exceeded." },
});

// ===== V-04: NoSQL Injection Prevention =====
export const sanitizeInput = mongoSanitize({
  replaceWith: "_",
  onSanitize: ({ req, key }) => {
    console.warn(`Sanitized malicious input: ${key} in ${req.path}`);
  },
});

// ===== V-11: File Upload Validation =====
const ALLOWED_MIME_TYPES = [
  "audio/wav", "audio/mpeg", "audio/mp4", "audio/ogg",
  "image/jpeg", "image/png", "image/webp",
  "application/pdf", "application/json",
  "video/mp4",
];

const MAGIC_BYTES = {
  "audio/wav": [0x52, 0x49, 0x46, 0x46],
  "audio/mpeg": [0x49, 0x44, 0x33],
  "image/jpeg": [0xFF, 0xD8, 0xFF],
  "image/png": [0x89, 0x50, 0x4E, 0x47],
  "application/pdf": [0x25, 0x50, 0x44, 0x46],
};

export function validateFileUpload(req, res, next) {
  if (!req.file) return next();

  // Size check (50MB max)
  if (req.file.size > 50 * 1024 * 1024) {
    return res.status(413).json({ error: "FILE_TOO_LARGE", message: "File exceeds 50MB limit" });
  }

  // MIME type check
  if (!ALLOWED_MIME_TYPES.includes(req.file.mimetype)) {
    return res.status(415).json({ error: "UNSUPPORTED_FILE_TYPE", message: `Unsupported type: ${req.file.mimetype}` });
  }

  // Magic bytes check (prevent MIME spoofing)
  const magic = MAGIC_BYTES[req.file.mimetype];
  if (magic) {
    const buffer = req.file.buffer.slice(0, magic.length);
    const matches = magic.every((byte, i) => buffer[i] === byte);
    if (!matches) {
      return res.status(415).json({ error: "FILE_SPOOFING", message: "File type mismatch detected" });
    }
  }

  next();
}

// ===== V-06: Password Policy Validation =====
export function validatePasswordStrength(password) {
  const errors = [];
  if (!password || password.length < 8) errors.push("Minimum 8 characters required");
  if (!/[A-Z]/.test(password)) errors.push("Must contain an uppercase letter");
  if (!/[a-z]/.test(password)) errors.push("Must contain a lowercase letter");
  if (!/[0-9]/.test(password)) errors.push("Must contain a number");
  if (!/[!@#$%^&*(),.?":{}|<>]/.test(password)) errors.push("Must contain a special character");
  return { valid: errors.length === 0, errors };
}

// ===== V-12: Session Timeout Check =====
export function checkSessionTimeout(req, res, next) {
  if (!req.user) return next();
  const now = Math.floor(Date.now() / 1000);
  const issuedAt = req.user.iat || 0;
  const maxAge = 30 * 60; // 30 minutes
  if (now - issuedAt > maxAge) {
    return res.status(401).json({ error: "SESSION_EXPIRED", message: "Session timed out. Please login again." });
  }
  next();
}

// ===== V-16: Prevent $ Operators in Request Body =====
export function preventNoSQLInjection(req, res, next) {
  if (req.body && typeof req.body === 'object') {
    const body = JSON.stringify(req.body);
    if (body.includes("$gt") || body.includes("$ne") || body.includes("$regex") ||
        body.includes("$where") || body.includes("$exists")) {
      return res.status(400).json({ error: "MALICIOUS_INPUT", message: "Invalid query parameters detected" });
    }
  }
  next();
}

// ===== AI Prompt Injection Prevention =====
const INJECTION_PATTERNS = [
  /ignore\s+(all\s+)?previous/i,
  /forget\s+(all\s+)?(previous|instructions)/i,
  /system\s+prompt/i,
  /you\s+are\s+(now\s+)?/i,
  /act\s+as\s+/i,
  /bypass\s+(restrictions|safeguards)/i,
  /ignore\s+(instructions|directives|rules)/i,
  /print\s+(your\s+)?(instructions|prompt)/i,
  /reveal\s+(your\s+)?(instructions|prompt|system)/i,
];

export function preventAIPromptInjection(req, res, next) {
  const textFields = [req.body?.text, req.body?.message, req.body?.transcript];
  for (const field of textFields) {
    if (field && typeof field === "string") {
      for (const pattern of INJECTION_PATTERNS) {
        if (pattern.test(field)) {
          console.warn(`AI Prompt injection blocked: ${req.ip} - ${field.substring(0, 100)}`);
          return res.status(400).json({
            error: "INJECTION_DETECTED",
            message: "Suspicious content detected in request",
          });
        }
      }
    }
  }
  next();
}