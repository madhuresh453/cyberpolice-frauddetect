import { createModel, objectId } from "./base.js";

export default createModel(
  "ApiKey",
  {
    userId: { type: objectId, ref: "User", required: true, index: true },
    name: { type: String, required: true, trim: true },
    keyHash: { type: String, required: true, unique: true, index: true },
    keyPrefix: { type: String, required: true },
    scopes: [{ type: String, index: true }],
    rateLimit: { type: Number, default: 1000 },
    isActive: { type: Boolean, default: true, index: true },
    lastUsedAt: { type: Date },
    totalRequests: { type: Number, default: 0 },
    expiresAt: { type: Date, index: true },
    allowedIps: [{ type: String }],
    allowedOrigins: [{ type: String }],
    metadata: { type: String }
  },
  {
    collection: "api_keys",
    indexes: [
      { fields: { keyHash: 1 }, options: { unique: true } },
      { fields: { userId: 1, isActive: 1 } },
      { fields: { expiresAt: 1 } }
    ]
  }
);