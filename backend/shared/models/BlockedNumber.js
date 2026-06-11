import { createModel, phoneValidator, objectId } from "./base.js";

export default createModel(
  "BlockedNumber",
  {
    citizenId: { type: objectId, ref: "Citizen", required: true, index: true },
    phoneNumber: { type: String, required: true, validate: phoneValidator, index: true },
    reason: { type: String, enum: ["spam", "fraud", "harassment", "scam", "phishing", "other"], required: true, index: true },
    description: { type: String, maxlength: 500 },
    source: { type: String, enum: ["citizen", "police", "isp", "ai", "government"], default: "citizen" },
    fraudType: { type: String, index: true },
    riskScore: { type: Number, min: 0, max: 100, default: 50 },
    totalReports: { type: Number, default: 1 },
    blockScope: { type: String, enum: ["personal", "family", "national"], default: "personal" },
    status: { type: String, enum: ["active", "expired", "revoked"], default: "active", index: true },
    blockedAt: { type: Date, default: Date.now },
    expiresAt: { type: Date, index: true },
    evidenceIds: [{ type: objectId, ref: "EvidenceFile" }]
  },
  {
    collection: "blocked_numbers",
    indexes: [
      { fields: { phoneNumber: 1, citizenId: 1 }, options: { unique: true } },
      { fields: { reason: 1, status: 1 } },
      { fields: { riskScore: -1 } },
      { fields: { totalReports: -1 } },
      { fields: { blockScope: 1, status: 1 } }
    ]
  }
);