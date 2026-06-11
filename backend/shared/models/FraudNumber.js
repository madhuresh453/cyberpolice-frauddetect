import { createModel, phoneValidator, objectId } from "./base.js";

export default createModel(
  "FraudNumber",
  {
    phoneNumber: { type: String, required: true, unique: true, index: true },
    fraudType: { type: String, required: true, index: true },
    riskScore: { type: Number, min: 0, max: 100, default: 50, index: true },
    riskCategory: { type: String, enum: ["safe", "low", "medium", "high", "critical"], default: "medium", index: true },
    totalReports: { type: Number, default: 0, index: true },
    uniqueReporters: { type: Number, default: 0 },
    totalVictims: { type: Number, default: 0 },
    estimatedLoss: { type: Number, default: 0 },
    carrierInfo: {
      carrier: String,
      circle: String,
      type: { type: String, enum: ["prepaid", "postpaid", "unknown"] },
      ported: { type: Boolean, default: false }
    },
    callerName: { type: String },
    callerType: { type: String, enum: ["individual", "business", "government", "unknown"], default: "unknown" },
    states: [{ type: String, index: true }],
    districts: [{ type: String, index: true }],
    firstReportedAt: { type: Date, default: Date.now },
    lastReportedAt: { type: Date, default: Date.now },
    reportIds: [{ type: objectId, ref: "FraudReport" }],
    caseIds: [{ type: objectId, ref: "Case" }],
    campaignId: { type: String, index: true },
    isActive: { type: Boolean, default: true, index: true },
    blockStatus: { type: String, enum: ["active", "pending", "blocked", "expired"], default: "pending", index: true },
    blockedAt: { type: Date },
    lastActivityAt: { type: Date },
    tags: [{ type: String }]
  },
  {
    collection: "fraud_numbers",
    indexes: [
      { fields: { phoneNumber: 1 }, options: { unique: true } },
      { fields: { riskScore: -1 } },
      { fields: { riskCategory: 1, riskScore: -1 } },
      { fields: { totalReports: -1 } },
      { fields: { fraudType: 1, isActive: 1 } },
      { fields: { blockStatus: 1 } },
      { fields: { campaignId: 1 } },
      { fields: { states: 1 } },
      { fields: { districts: 1 } },
      { fields: { lastReportedAt: -1 } },
      { fields: { tags: 1 } }
    ]
  }
);