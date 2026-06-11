import { createModel, phoneValidator, objectId } from "./base.js";

export default createModel(
  "WhatsappAnalysis",
  {
    senderNumber: { type: String, required: true, index: true },
    receiverNumber: { type: String, required: true, index: true },
    message: { type: String },
    mediaType: { type: String, enum: ["text", "image", "video", "audio", "document", "sticker", "location", "contact"], default: "text" },
    mediaUrl: { type: String },
    groupName: { type: String },
    groupId: { type: String },
    analysisType: { type: String, enum: ["realtime", "batch", "manual"], required: true },
    status: { type: String, enum: ["pending", "processing", "completed", "failed"], default: "pending", index: true },
    sentiment: { score: { type: Number, min: -1, max: 1 }, label: { type: String } },
    intent: { category: { type: String }, confidence: { type: Number, min: 0, max: 1 } },
    scamIndicators: [{ indicator: String, confidence: Number, description: String }],
    riskScore: { type: Number, min: 0, max: 100, default: 0, index: true },
    riskCategory: { type: String, enum: ["safe", "low", "medium", "high", "critical"], default: "safe" },
    isScam: { type: Boolean, default: false, index: true },
    scamType: { type: String, index: true },
    confidence: { type: Number, min: 0, max: 1 },
    urls: [{ url: String, isMalicious: Boolean, category: String }],
    forwardedCount: { type: Number, default: 0 },
    isForwarded: { type: Boolean, default: false },
    aiModel: { type: String },
    processingTimeMs: { type: Number },
    analyzedAt: { type: Date, default: Date.now }
  },
  {
    collection: "whatsapp_analysis",
    indexes: [
      { fields: { senderNumber: 1, analyzedAt: -1 } },
      { fields: { riskScore: -1 } },
      { fields: { isScam: 1, scamType: 1 } },
      { fields: { groupId: 1 } },
      { fields: { analyzedAt: -1 } }
    ]
  }
);