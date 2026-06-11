import { createModel, objectId } from "./base.js";

export default createModel(
  "FraudApp",
  {
    packageName: { type: String, required: true, unique: true, index: true },
    appName: { type: String, required: true },
    fraudType: { type: String, required: true, index: true },
    riskScore: { type: Number, min: 0, max: 100, default: 50, index: true },
    riskCategory: { type: String, enum: ["safe", "low", "medium", "high", "critical"], default: "medium", index: true },
    totalReports: { type: Number, default: 0 },
    uniqueReporters: { type: Number, default: 0 },
    estimatedLoss: { type: Number, default: 0 },
    platform: { type: String, enum: ["android", "ios", "web", "windows", "all"], required: true },
    version: { type: String },
    developer: { type: String },
    storeUrl: { type: String },
    description: { type: String },
    permissions: [{ type: String }],
    isActive: { type: Boolean, default: true, index: true },
    isBlocked: { type: Boolean, default: false, index: true },
    blockedAt: { type: Date },
    campaignId: { type: String, index: true },
    reportIds: [{ type: objectId, ref: "FraudReport" }],
    caseIds: [{ type: objectId, ref: "Case" }],
    lastReportedAt: { type: Date, default: Date.now },
    tags: [{ type: String }]
  },
  {
    collection: "fraud_apps",
    indexes: [
      { fields: { packageName: 1 }, options: { unique: true } },
      { fields: { riskScore: -1 } },
      { fields: { fraudType: 1, isActive: 1 } },
      { fields: { platform: 1 } },
      { fields: { campaignId: 1 } },
      { fields: { isBlocked: 1 } }
    ]
  }
);