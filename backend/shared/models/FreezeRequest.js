import { createModel, phoneValidator, objectId } from "./base.js";

export default createModel(
  "FreezeRequest",
  {
    citizenId: { type: objectId, ref: "Citizen", index: true },
    caseId: { type: objectId, ref: "Case", index: true },
    firId: { type: objectId, ref: "FIR", index: true },
    requestedBy: { type: objectId, ref: "PoliceOfficer", required: true, index: true },
    requestType: { type: String, enum: ["bank_account", "upi", "sim", "device"], required: true, index: true },
    targetAccount: { type: String, required: true, index: true },
    targetIfsc: { type: String },
    targetBank: { type: String },
    targetUpiId: { type: String },
    reason: { type: String, required: true },
    evidence: [{ type: objectId, ref: "EvidenceFile" }],
    status: { type: String, enum: ["pending", "approved", "rejected", "executed", "expired", "reversed"], default: "pending", index: true },
    priority: { type: String, enum: ["low", "medium", "high", "critical"], default: "high" },
    approvedBy: { type: objectId, ref: "PoliceOfficer" },
    approvedAt: { type: Date },
    rejectedAt: { type: Date },
    rejectionReason: { type: String },
    executedAt: { type: Date },
    executedBy: { type: String },
    expiryDate: { type: Date, index: true },
    duration: { type: Number },
    amount: { type: Number },
    estimatedLoss: { type: Number },
    bankReference: { type: String },
    statusHistory: [{
      status: String,
      timestamp: { type: Date, default: Date.now },
      performedBy: { type: objectId, ref: "User" },
      notes: String
    }]
  },
  {
    collection: "freeze_requests",
    indexes: [
      { fields: { targetAccount: 1, status: 1 } },
      { fields: { requestedBy: 1, status: 1 } },
      { fields: { status: 1, priority: 1 } },
      { fields: { caseId: 1 } },
      { fields: { requestType: 1, status: 1 } },
      { fields: { expiryDate: 1 } }
    ]
  }
);