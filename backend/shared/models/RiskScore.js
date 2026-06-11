import { createModel, objectId } from "./base.js";

export default createModel(
  "RiskScore",
  {
    entityType: { type: String, enum: ["phone", "upi", "bank_account", "device", "citizen", "campaign", "website", "app"], required: true, index: true },
    entityId: { type: String, required: true, index: true },
    score: { type: Number, min: 0, max: 100, required: true, index: true },
    previousScore: { type: Number, min: 0, max: 100 },
    riskCategory: { type: String, enum: ["safe", "low", "medium", "high", "critical"], required: true, index: true },
    factors: {
      reportCount: { type: Number, default: 0 },
      caseCount: { type: Number, default: 0 },
      fraudTypeCount: { type: Number, default: 0 },
      geographicSpread: { type: Number, default: 0 },
      temporalPattern: { type: Number, default: 0 },
      networkRisk: { type: Number, default: 0 },
      aiRisk: { type: Number, default: 0 },
      threatIntelRisk: { type: Number, default: 0 }
    },
    calculatedAt: { type: Date, default: Date.now, index: true },
    algorithm: { type: String, default: "v1" },
    confidence: { type: Number, min: 0, max: 1 },
    trend: { type: String, enum: ["increasing", "stable", "decreasing"], default: "stable" },
    nextReviewAt: { type: Date, index: true }
  },
  {
    collection: "risk_scores",
    indexes: [
      { fields: { entityType: 1, entityId: 1 }, options: { unique: true } },
      { fields: { score: -1 } },
      { fields: { riskCategory: 1, score: -1 } },
      { fields: { calculatedAt: -1 } },
      { fields: { nextReviewAt: 1 } }
    ]
  }
);