import { createModel, objectId } from "./base.js";

export default createModel(
  "CampaignDetection",
  {
    campaignId: { type: String, required: true, unique: true, index: true },
    campaignName: { type: String, required: true },
    campaignType: { type: String, enum: ["sms", "whatsapp", "call", "email", "multi_channel"], required: true, index: true },
    fraudType: { type: String, required: true, index: true },
    status: { type: String, enum: ["detected", "investigating", "confirmed", "mitigated", "closed"], default: "detected", index: true },
    severity: { type: String, enum: ["low", "medium", "high", "critical"], required: true, index: true },
    riskScore: { type: Number, min: 0, max: 100, required: true, index: true },
    totalFraudNumbers: { type: Number, default: 0 },
    totalVictims: { type: Number, default: 0 },
    totalReports: { type: Number, default: 0 },
    estimatedLoss: { type: Number, default: 0 },
    fraudNumbers: [{ type: String, index: true }],
    fraudUpiIds: [{ type: String }],
    fraudBankAccounts: [{ type: String }],
    fraudWebsites: [{ type: String }],
    fraudApps: [{ type: String }],
    affectedStates: [{ type: String, index: true }],
    affectedDistricts: [{ type: String, index: true }],
    attackTimeline: [{
      date: { type: Date },
      count: { type: Number },
      type: { type: String }
    }],
    threatActors: [{
      name: { type: String },
      phone: { type: String },
      role: { type: String },
      riskScore: { type: Number }
    }],
    indicators: [{ type: String, description: String, confidence: Number }],
    caseIds: [{ type: objectId, ref: "Case" }],
    firIds: [{ type: objectId, ref: "FIR" }],
    detectedAt: { type: Date, default: Date.now, index: true },
    confirmedAt: { type: Date },
    mitigatedAt: { type: Date },
    firstReportAt: { type: Date },
    lastReportAt: { type: Date, index: true },
    detectionMethod: { type: String, enum: ["ai", "citizen_report", "police", "isp", "government"], default: "ai" },
    aiModel: { type: String },
    aiConfidence: { type: Number, min: 0, max: 1 },
    notes: { type: String, maxlength: 2000 },
    tags: [{ type: String }]
  },
  {
    collection: "campaign_detections",
    indexes: [
      { fields: { campaignId: 1 }, options: { unique: true } },
      { fields: { riskScore: -1 } },
      { fields: { severity: 1, status: 1 } },
      { fields: { campaignType: 1, status: 1 } },
      { fields: { affectedStates: 1 } },
      { fields: { detectedAt: -1 } },
      { fields: { lastReportAt: -1 } },
      { fields: { tags: 1 } }
    ]
  }
);