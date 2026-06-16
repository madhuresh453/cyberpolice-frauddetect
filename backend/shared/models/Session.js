import { createModel, objectId } from "./base.js";

export default createModel(
  "Session",
  {
    userId: { type: objectId, ref: "User", required: true, index: true },
    token: { type: String, required: false },
    type: { type: String, enum: ["access", "refresh", "otp", "password_reset"], default: "access" },
    ipAddress: { type: String },
    userAgent: { type: String },
    deviceInfo: {
      deviceId: { type: String },
      platform: { type: String },
      browser: { type: String },
      os: { type: String }
    },
    location: {
      district: { type: String },
      state: { type: String },
      country: { type: String, default: "India" }
    },
    isActive: { type: Boolean, default: true, index: true },
    expiresAt: { type: Date, required: true, index: true },
    lastActivityAt: { type: Date, default: Date.now, index: true },
    revokedAt: { type: Date },
    revokedBy: { type: objectId, ref: "User" },
    revokeReason: { type: String }
  },
  {
    collection: "sessions",
    indexes: [
      { fields: { token: 1 }, options: { unique: true, partialFilterExpression: { token: { $type: "string" } } } },
      { fields: { userId: 1, isActive: 1 } },
      { fields: { expiresAt: 1 } },
      { fields: { lastActivityAt: -1 } }
    ]
  }
);