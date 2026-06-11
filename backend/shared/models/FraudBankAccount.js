import { createModel, objectId } from "./base.js";

export default createModel(
  "FraudBankAccount",
  {
    accountNumber: { type: String, required: true, index: true },
    ifsc: { type: String, required: true, index: true },
    bankName: { type: String, required: true, index: true },
    accountHolderName: { type: String },
    branch: { type: String },
    fraudType: { type: String, required: true, index: true },
    riskScore: { type: Number, min: 0, max: 100, default: 50, index: true },
    riskCategory: { type: String, enum: ["safe", "low", "medium", "high", "critical"], default: "medium", index: true },
    totalReports: { type: Number, default: 0 },
    uniqueReporters: { type: Number, default: 0 },
    totalVictims: { type: Number, default: 0 },
    estimatedLoss: { type: Number, default: 0 },
    freezeStatus: { type: String, enum: ["none", "requested", "frozen", "unfrozen", "rejected"], default: "none", index: true },
    frozenAt: { type: Date },
    frozenBy: { type: objectId, ref: "PoliceOfficer" },
    unfrozenAt: { type: Date },
    linkedPhone: { type: String, index: true },
    linkedUpiIds: [{ type: String }],
    states: [{ type: String, index: true }],
    districts: [{ type: String, index: true }],
    firstReportedAt: { type: Date, default: Date.now },
    lastReportedAt: { type: Date, default: Date.now },
    reportIds: [{ type: objectId, ref: "FraudReport" }],
    caseIds: [{ type: objectId, ref: "Case" }],
    campaignId: { type: String, index: true },
    isActive: { type: Boolean, default: true, index: true },
    tags: [{ type: String }]
  },
  {
    collection: "fraud_bank_accounts",
    indexes: [
      { fields: { accountNumber: 1, ifsc: 1 }, options: { unique: true } },
      { fields: { bankName: 1 } },
      { fields: { riskScore: -1 } },
      { fields: { riskCategory: 1, riskScore: -1 } },
      { fields: { freezeStatus: 1 } },
      { fields: { fraudType: 1, isActive: 1 } },
      { fields: { campaignId: 1 } },
      { fields: { linkedPhone: 1 } },
      { fields: { lastReportedAt: -1 } }
    ]
  }
);