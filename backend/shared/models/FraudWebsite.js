import { createModel, objectId } from "./base.js";

export default createModel(
  "FraudWebsite",
  {
    url: { type: String, required: true, unique: true, index: true },
    domain: { type: String, required: true, index: true },
    fraudType: { type: String, required: true, index: true },
    riskScore: { type: Number, min: 0, max: 100, default: 50, index: true },
    riskCategory: { type: String, enum: ["safe", "low", "medium", "high", "critical"], default: "medium", index: true },
    totalReports: { type: Number, default: 0 },
    uniqueReporters: { type: Number, default: 0 },
    estimatedLoss: { type: Number, default: 0 },
    title: { type: String },
    description: { type: String },
    hostingProvider: { type: String },
    registrarInfo: {
      registrar: String,
      registeredDate: Date,
      expiryDate: Date,
      nameservers: [String]
    },
    sslInfo: {
      issuer: String,
      validFrom: Date,
      validTo: Date,
      isExpired: Boolean
    },
    screenshots: [{ url: String, capturedAt: Date }],
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
    collection: "fraud_websites",
    indexes: [
      { fields: { url: 1 }, options: { unique: true } },
      { fields: { domain: 1 } },
      { fields: { riskScore: -1 } },
      { fields: { fraudType: 1, isActive: 1 } },
      { fields: { campaignId: 1 } },
      { fields: { isBlocked: 1 } }
    ]
  }
);