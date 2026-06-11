import { createModel, objectId } from "./base.js";

export default createModel(
  "ThreatCampaign",
  {
    campaignId: { type: String, required: true, unique: true, index: true },
    name: { type: String, required: true },
    description: { type: String },
    threatType: { type: String, enum: ["sms_fraud", "call_fraud", "phishing", "upi_fraud", "bank_fraud", "identity_theft", "deepfake", "multi_vector"], required: true, index: true },
    severity: { type: String, enum: ["low", "medium", "high", "critical"], required: true, index: true },
    status: { type: String, enum: ["active", "monitoring", "mitigated", "closed"], default: "active", index: true },
    confidence: { type: Number, min: 0, max: 1 },
    indicators: [{
      type: { type: String },
      value: { type: String },
      confidence: { type: Number },
      description: { type: String }
    }],
    affectedStates: [{ type: String, index: true }],
    affectedDistricts: [{ type: String }],
    totalVictims: { type: Number, default: 0 },
    estimatedLoss: { type: Number, default: 0 },
    fraudNumbers: [{ type: String }],
    fraudUpiIds: [{ type: String }],
    fraudBankAccounts: [{ type: String }],
    fraudWebsites: [{ type: String }],
    threatActors: [{ name: String, phone: String, role: String }],
    mitreMapping: { type: String },
    iocIds: [{ type: objectId, ref: "IocFeed" }],
    caseIds: [{ type: objectId, ref: "Case" }],
    detectedAt: { type: Date, default: Date.now, index: true },
    lastActivityAt: { type: Date, index: true },
    mitigatedAt: { type: Date },
    tags: [{ type: String }]
  },
  {
    collection: "threat_campaigns",
    indexes: [
      { fields: { campaignId: 1 }, options: { unique: true } },
      { fields: { severity: 1, status: 1 } },
      { fields: { threatType: 1, status: 1 } },
      { fields: { detectedAt: -1 } },
      { fields: { lastActivityAt: -1 } }
    ]
  }
);