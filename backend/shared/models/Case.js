import { createModel, phoneValidator, objectId } from "./base.js";

export default createModel(
  "Case",
  {
    caseNumber: { type: String, required: true, unique: true, index: true },
    title: { type: String, required: true, trim: true },
    description: { type: String, required: true, maxlength: 2000 },
    type: { type: String, enum: ["cyber_fraud", "identity_theft", "phishing", "upi_fraud", "insurance_fraud", "bank_fraud", "sim_swap", "deepfake", "romance_scam", "tech_support_scam", "other"], required: true, index: true },
    status: { type: String, enum: ["open", "under_investigation", "evidence_collection", "closed", "resolved", "transferred", "reopened"], default: "open", index: true },
    priority: { type: String, enum: ["low", "medium", "high", "critical"], default: "medium", index: true },
    severity: { type: String, enum: ["minor", "moderate", "serious", "grave", "heinous"] },
    citizenId: { type: objectId, ref: "Citizen", required: true, index: true },
    complainantPhone: { type: String, validate: phoneValidator, index: true },
    complainantName: { type: String },
    assignedOfficer: { type: objectId, ref: "PoliceOfficer", index: true },
    departmentId: { type: objectId, ref: "PoliceDepartment", index: true },
    firId: { type: objectId, ref: "FIR", index: true },
    fraudNumbers: [{ type: String, index: true }],
    fraudUpiIds: [{ type: String, index: true }],
    fraudBankAccounts: [{ type: String }],
    fraudWebsites: [String],
    fraudApps: [String],
    estimatedLoss: { type: Number, default: 0 },
    recoveredAmount: { type: Number, default: 0 },
    currency: { type: String, default: "INR" },
    location: {
      district: { type: String, index: true },
      state: { type: String, index: true },
      city: String,
      coordinates: {
        type: { type: String, enum: ["Point"] },
        coordinates: { type: [Number] }
      }
    },
    evidenceIds: [{ type: objectId, ref: "EvidenceFile" }],
    timeline: [{
      action: String,
      performedBy: { type: objectId, ref: "User" },
      timestamp: { type: Date, default: Date.now },
      details: String,
      status: String
    }],
    tags: [{ type: String }],
    riskScore: { type: Number, min: 0, max: 100, default: 50, index: true },
    isNetworkCase: { type: Boolean, default: false },
    networkId: { type: String, index: true },
    connectedCases: [{ type: objectId, ref: "Case" }],
    resolutionNotes: { type: String },
    resolvedAt: { type: Date },
    closedAt: { type: Date }
  },
  {
    collection: "cases",
    indexes: [
      { fields: { caseNumber: 1 }, options: { unique: true } },
      { fields: { type: 1, status: 1 } },
      { fields: { priority: 1, status: 1 } },
      { fields: { citizenId: 1, status: 1 } },
      { fields: { assignedOfficer: 1, status: 1 } },
      { fields: { "location.district": 1, "location.state": 1 } },
      { fields: { "location.coordinates": "2dsphere" } },
      { fields: { fraudNumbers: 1 } },
      { fields: { riskScore: -1 } },
      { fields: { estimatedLoss: -1 } },
      { fields: { networkId: 1 } },
      { fields: { tags: 1 } },
      { fields: { createdAt: -1 } }
    ]
  }
);