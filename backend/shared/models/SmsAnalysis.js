import { createModel, phoneValidator, objectId } from "./base.js";

export default createModel(
  "SmsAnalysis",
  {
    smsLogId: { type: objectId, ref: "SmsLog", index: true },
    senderNumber: { type: String, required: true, index: true },
    receiverNumber: { type: String, required: true, index: true },
    message: { type: String, required: true },
    analysisType: { type: String, enum: ["realtime", "batch"], required: true },
    status: { type: String, enum: ["pending", "processing", "completed", "failed"], default: "pending", index: true },
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
    urls: [{ url: String, isMalicious: Boolean, category: String }],
    phoneNumbers: [{ number: String, context: String }],
    keywords: [{ type: String }],
    entities: [{ type: { type: String }, value: { type: String }, confidence: { type: Number } }],
    aiModel: { type: String },
    processingTimeMs: { type: Number },
    analyzedAt: { type: Date, default: Date.now }
  },
  {
    collection: "sms_analysis",
    indexes: [
      { fields: { senderNumber: 1, analyzedAt: -1 } },
      { fields: { riskScore: -1 } },
      { fields: { isScam: 1, scamType: 1 } },
      { fields: { analyzedAt: -1 } }
    ]
  }
);