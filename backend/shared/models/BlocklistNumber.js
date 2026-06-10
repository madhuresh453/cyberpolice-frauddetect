import { RISK_LEVELS, createModel, phoneValidator } from "./base.js";

export default createModel(
  "BlocklistNumber",
  {
    phoneNumber: { type: String, required: true, unique: true, validate: phoneValidator },
    reason: { type: String, required: true, maxlength: 1000 },
    riskLevel: { type: String, enum: RISK_LEVELS, default: "high", index: true },
    source: { type: String, enum: ["police", "isp", "ai", "citizen", "system"], required: true, index: true },
    expiresAt: { type: Date, index: true },
    blockedAt: { type: Date, default: Date.now, index: true }
  },
  { collection: "blocklist_numbers", indexes: [{ fields: { riskLevel: 1, blockedAt: -1 } }] }
);
