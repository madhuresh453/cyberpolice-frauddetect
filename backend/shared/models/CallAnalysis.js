import { createModel, phoneValidator, objectId } from "./base.js";

export default createModel(
  "CallAnalysis",
  {
    callLogId: { type: objectId, ref: "TrafficLog", index: true },
    phoneNumber: { type: String, required: true, index: true },
    calledNumber: { type: String, required: true, index: true },
    analysisType: { type: String, enum: ["realtime", "post_call", "batch"], required: true },
    status: { type: String, enum: ["pending", "processing", "completed", "failed"], default: "pending", index: true },
    duration: { type: Number },
    recordingPath: { type: String },
    transcript: { type: String },
    language: { type: String },
    sentiment: {
      score: { type: Number, min: -1, max: 1 },
      label: { type: String, enum: ["positive", "negative", "neutral"] }
    },
    intent: {
      category: { type: String },
      confidence: { type: Number, min: 0, max: 1 },
      subcategory: { type: String }
    },
    scamIndicators: [{
      indicator: { type: String },
      confidence: { type: Number, min: 0, max: 1 },
      description: { type: String }
    }],
    riskScore: { type: Number, min: 0, max: 100, default: 0, index: true },
    riskCategory: { type: String, enum: ["safe", "low", "medium", "high", "critical"], default: "safe" },
    isScam: { type: Boolean, default: false, index: true },
    scamType: { type: String, index: true },
    confidence: { type: Number, min: 0, max: 1 },
    aiModel: { type: String },
    aiVersion: { type: String },
    processingTimeMs: { type: Number },
    keywords: [{ type: String }],
    entities: [{
      type: { type: String },
      value: { type: String },
      confidence: { type: Number }
    }],
    audioFeatures: {
      rmsEnergy: { type: Number },
      pitch: { type: Number },
      speakingRate: { type: Number },
      silenceRatio: { type: Number },
      spectralCentroid: { type: Number }
    },
    analyzedAt: { type: Date, default: Date.now }
  },
  {
    collection: "call_analysis",
    indexes: [
      { fields: { phoneNumber: 1, analyzedAt: -1 } },
      { fields: { calledNumber: 1, analyzedAt: -1 } },
      { fields: { riskScore: -1 } },
      { fields: { isScam: 1, scamType: 1 } },
      { fields: { status: 1 } },
      { fields: { analyzedAt: -1 } }
    ]
  }
);