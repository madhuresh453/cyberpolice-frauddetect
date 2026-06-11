import { createModel, upiValidator, objectId } from "./base.js";

export default createModel(
  "FraudUpiId",
  {
    upiId: { type: String, required: true, unique: true, index: true, validate: upiValidator },
    fraudType: { type: String, required: true, index: true },
    riskScore: { type: Number, min: 0, max: 100, default: 50, index: true },
    riskCategory: { type: String, enum: ["safe", "low", "medium", "high", "critical"], default: "medium", index: true },
    totalReports: { type: Number, default: 0 },
    uniqueReporters: { type: Number, default: 0 },
    totalVictims: { type: Number, default: 0 },
    estimatedLoss: { type: Number, default: 0 },
    bankName: { type: String, index: true },
    accountHolderName: { type: String },
    linkedPhone: { type: String, index: true },
    vpa: { type: String },
    ifsc: { type: String },
    states: [{ type: String, index: true }],
    districts: [{ type: String, index: true }],
    firstReportedAt: { type: Date, default: Date.now },
    lastReportedAt: { type: Date, default: Date.now },
    reportIds: [{ type: objectId, ref: "FraudReport" }],
    caseIds: [{ type: objectId, ref: "Case" }],
    campaignId: { type: String, index: true },
    isActive: { type: Boolean, default: true, index: true },
    blockStatus: { type: String, enum: ["active", "pending", "blocked", "expired"], default: "pending" },
    frozenAt: { type: Date },
    tags: [{ type: String }]
  },
  {
    collection: "fraud_upi_ids",
    indexes: [
      { fields: { upiId: 1 }, options: { unique: true } },
      { fields: { riskScore: -1 } },
      { fields: { riskCategory: 1, riskScore: -1 } },
      { fields: { bankName: 1 } },
      { fields: { fraudType: 1, isActive: 1 } },
      { fields: { campaignId: 1 } },
      { fields: { lastReportedAt: -1 } }
    ]
  }
);