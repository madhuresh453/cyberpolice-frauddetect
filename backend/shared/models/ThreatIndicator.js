import { createModel, objectId } from "./base.js";

export default createModel(
  "ThreatIndicator",
  {
    indicatorType: { type: String, enum: ["phone", "ip", "domain", "url", "hash", "email", "upi", "bank_account", "sim", "device", "keyword", "pattern"], required: true, index: true },
    indicatorValue: { type: String, required: true, index: true },
    threatLevel: { type: String, enum: ["info", "low", "medium", "high", "critical"], required: true, index: true },
    source: { type: String, enum: ["citizen_report", "police", "isp", "ai", "government", "third_party"], required: true, index: true },
    description: { type: String },
    confidence: { type: Number, min: 0, max: 1, default: 0.5 },
    hitCount: { type: Number, default: 0, index: true },
    lastHitAt: { type: Date },
    isActive: { type: Boolean, default: true, index: true },
    relatedCampaigns: [{ type: objectId, ref: "ThreatCampaign" }],
    relatedCases: [{ type: objectId, ref: "Case" }],
    tags: [{ type: String }],
    expiresAt: { type: Date, index: true },
    metadata: { type: String }
  },
  {
    collection: "threat_indicators",
    indexes: [
      { fields: { indicatorType: 1, indicatorValue: 1 }, options: { unique: true } },
      { fields: { threatLevel: 1, isActive: 1 } },
      { fields: { source: 1 } },
      { fields: { hitCount: -1 } },
      { fields: { expiresAt: 1 } }
    ]
  }
);