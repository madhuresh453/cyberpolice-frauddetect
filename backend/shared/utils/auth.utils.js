import jwt from "jsonwebtoken";
import { config } from "../database/database.config.js";

/**
 * Generate an access token for a user.
 */
export function generateAccessToken(user) {
  return jwt.sign(
    {
      sub: user._id.toString(),
      email: user.email,
      role: user.role,
      type: "access",
    },
    config.jwtSecret,
    { expiresIn: "15m" }
  );
}

/**
 * Generate a refresh token for a user.
 */
export function generateRefreshToken(user) {
  return jwt.sign(
    {
      sub: user._id.toString(),
      type: "refresh",
    },
    config.jwtSecret,
    { expiresIn: "30d" }
  );
}

/**
 * Verify a JWT token.
 * @returns {{ valid: boolean, payload: object|null, error: string|null }}
 */
export function verifyToken(token) {
  try {
    const payload = jwt.verify(token, config.jwtSecret);
    return { valid: true, payload, error: null };
  } catch (err) {
    return { valid: false, payload: null, error: err.message };
  }
}

/**
 * Build a standardized auth response.
 *
 * All auth endpoints must return this shape:
 * {
 *   success: true,
 *   accessToken: "...",
 *   refreshToken: "...",
 *   user: { id, email, phoneNumber, fullName, role, status, ... }
 * }
 */
export function buildAuthResponse(user, accessToken, refreshToken) {
  return {
    success: true,
    accessToken,
    refreshToken,
    user: {
      id: user._id.toString(),
      email: user.email,
      phoneNumber: user.phoneNumber,
      fullName: user.fullName,
      role: user.role,
      status: user.status,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    },
  };
}

/**
 * Build a standardized user profile response for /auth/me and similar endpoints.
 */
export function buildUserProfile(user) {
  return {
    id: user._id.toString(),
    email: user.email,
    phoneNumber: user.phoneNumber,
    fullName: user.fullName,
    role: user.role,
    status: user.status,
    trustScore: null, // To be populated from trust score service
    createdAt: user.createdAt,
    updatedAt: user.updatedAt,
    lastLoginAt: user.lastLoginAt || null,
  };
}