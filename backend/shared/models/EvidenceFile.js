import { createModel, objectId } from "./base.js";

export default createModel(
  "EvidenceFile",
  {
    citizenId: { type: objectId, ref: "Citizen", index: true },
    caseId: { type: objectId, ref: "Case", index: true },
    firId: { type: objectId, ref: "FIR", index: true },
    reportId: { type: objectId, ref: "FraudReport", index: true },
    uploadedBy: { type: objectId, ref: "User", required: true },
    fileType: {
      type: String,
      enum: ["screenshot", "audio", "video", "document", "call_recording", "sms_export", "chat_export", "image"],
      required: true,
      index: true
    },
    fileName: { type: String, required: true },
    originalName: { type: String, required: true },
    mimeType: { type: String, required: true },
    fileSize: { type: Number, required: true },
    storagePath: { type: String, required: true },
    storageProvider: { type: String, enum: ["local", "s3", "gcs", "azure"], default: "local" },
    hash: { type: String, required: true },
    hashAlgorithm: { type: String, default: "sha256" },
    description: { type: String, maxlength: 1000 },
    tags: [{ type: String }],
    analysisStatus: { type: String, enum: ["pending", "processing", "completed", "failed"], default: "pending" },
    analysisResult: {
      type: { type: String },
      confidence: { type: Number },
      findings: { type: [String] },
      deepfakeScore: { type: Number },
      scamIndicators: { type: [String] }
    },
    chainOfCustody: [{
      action: { type: String, enum: ["uploaded", "accessed", "modified", "verified", "shared", "deleted"] },
      performedBy: { type: objectId, ref: "User" },
      timestamp: { type: Date, default: Date.now },
      details: { type: String },
      ipAddress: { type: String }
    }],
    accessLevel: { type: String, enum: ["public", "restricted", "confidential", "classified"], default: "restricted" },
    status: { type: String, enum: ["active", "archived", "deleted"], default: "active", index: true },
    retentionDays: { type: Number, default: 365 },
    expiresAt: { type: Date, index: true }
  },
  {
    collection: "evidence_files",
    indexes: [
      { fields: { citizenId: 1, status: 1 } },
      { fields: { caseId: 1, status: 1 } },
      { fields: { firId: 1 } },
      { fields: { fileType: 1, status: 1 } },
      { fields: { hash: 1 }, options: { unique: true } },
      { fields: { analysisStatus: 1 } },
      { fields: { accessLevel: 1 } },
      { fields: { tags: 1 } }
    ]
  }
);