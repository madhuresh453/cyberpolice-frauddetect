import { createModel, objectId } from "./base.js";

export default createModel(
  "RefreshToken",
  {
    userId: { type: objectId, ref: "User", required: true, index: true },
    token: { type: String, required: true },
    family: { type: String, index: true },
    ipAddress: { type: String },
    userAgent: { type: String },
    isActive: { type: Boolean, default: true, index: true },
    expiresAt: { type: Date, required: true, index: true },
    usedAt: { type: Date },
    revokedAt: { type: Date },
    revokeReason: { type: String }
  },
  {
    collection: "refresh_tokens",
    indexes: [
      { fields: { token: 1 }, options: { unique: true, partialFilterExpression: { token: { $type: "string" } } } },
      { fields: { userId: 1, isActive: 1 } },
      { fields: { expiresAt: 1 } },
      { fields: { family: 1 } }
    ]
  }
);