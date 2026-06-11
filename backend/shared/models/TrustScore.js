import { createModel, objectId } from "./base.js";

export default createModel(
  "TrustScore",
  {
    citizenId: { type: objectId, ref: "Citizen", required: true, index: true },
    phoneNumber: { type: String, required: true, index: true },
    score: { type: Number, min: 0, max: 100, required: true, index: true },
    previousScore: { type: Number, min: 0, max: 100 },
    riskCategory: { type: String, enum: ["safe", "low", "medium", "high", "critical"], required: true, index: true },
    reasoning: { type: String, maxlength: 1000 },
    factors: {
      citizenReports: { type: Number, default: 0 },
      policeCases: { type: Number, default: 0 },
      bankFreezes: { type: Number, default: 0 },
      upiComplaints: { type: Number, default: 0 },
      spamReports: { type: Number, default: 0 },
      threatIntelMatches: { type: Number, default: 0 },
      deepfakeFlags: { type: Number, default: 0 },
      familyVerification: { type: Number, default: 0 },
      positiveSignals: { type: Number, default: 0 }
    },
    historicalTrend: [{
      score: { type: Number },
      date: { type: Date },
      change: { type: Number },
      reason: { type: String }
    }],
    calculatedAt: { type: Date, default: Date.now, index: true },
    algorithm: { type: String, default: "v1" },
    version: { type: String, default: "1.0" },
    isAnomaly: { type: Boolean, default: false },
    anomalyType: { type: String },
    confidence: { type: Number, min: 0, max: 1 },
    nextScheduleCheck: { type: Date }
  },
  {
    collection: "trust_scores",
    indexes: [
      { fields: { citizenId: 1, calculatedAt: -1 } },
      { fields: { phoneNumber: 1 } },
      { fields: { score: -1 } },
      { fields: { riskCategory: 1, score: -1 } },
      { fields: { isAnomaly: 1 } },
      { fields: { nextScheduleCheck: 1 } }
    ]
  }
);