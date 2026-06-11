import mongoose from "mongoose";
import { createModel, objectId } from "./base.js";

export default createModel(
  "DeepfakeAnalysis",
  {
    citizenId: { type: objectId, ref: "Citizen", index: true },
    caseId: { type: objectId, ref: "Case", index: true },
    analysisType: { type: String, enum: ["voice", "video", "image", "realtime_call"], required: true, index: true },
    status: { type: String, enum: ["pending", "processing", "completed", "failed"], default: "pending", index: true },
    inputSource: { type: String, enum: ["upload", "recording", "stream", "url"], required: true },
    filePath: { type: String },
    fileUrl: { type: String },
    fileSize: { type: Number },
    mimeType: { type: String },
    duration: { type: Number },
    phoneNumber: { type: String, index: true },
    deepfakeScore: { type: Number, min: 0, max: 1, required: true, index: true },
    isDeepfake: { type: Boolean, required: true, index: true },
    confidence: { type: Number, min: 0, max: 1, required: true },
    riskCategory: { type: String, enum: ["safe", "low", "medium", "high", "critical"], default: "safe", index: true },
    voiceAnalysis: {
      pitch: { type: Number },
      formants: [{ type: Number }],
      spectralConsistency: { type: Number },
      prosodyScore: { type: Number },
      breathPattern: { type: Number },
      voicePrint: { type: [Number] },
      speakerMatch: { type: Number },
      naturalness: { type: Number }
    },
    videoAnalysis: {
      faceConsistency: { type: Number },
      blinkPattern: { type: Number },
      lipSync: { type: Number },
      headMovement: { type: Number },
      lightingConsistency: { type: Number },
      borderArtifacts: { type: Number },
      temporalCoherence: { type: Number }
    },
    audioFingerprint: { type: [Number] },
    speakerId: { type: String, index: true },
    speakerVerified: { type: Boolean },
    scamIndicators: [{ indicator: String, confidence: Number, description: String }],
    aiModel: { type: String },
    aiVersion: { type: String },
    processingTimeMs: { type: Number },
    metadata: { type: mongoose.Schema.Types.Mixed, default: {} },
    analyzedAt: { type: Date, default: Date.now }
  },
  {
    collection: "deepfake_analysis",
    indexes: [
      { fields: { analysisType: 1, status: 1 } },
      { fields: { deepfakeScore: -1 } },
      { fields: { isDeepfake: 1, confidence: -1 } },
      { fields: { phoneNumber: 1, analyzedAt: -1 } },
      { fields: { citizenId: 1 } },
      { fields: { speakerId: 1 } },
      { fields: { analyzedAt: -1 } }
    ]
  }
);