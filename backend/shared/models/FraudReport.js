import { createModel, phoneValidator, upiValidator, objectId } from "./base.js";

export default createModel(
  "FraudReport",
  {
    reportNumber: { type: String, required: true, unique: true, index: true },
    citizenId: { type: objectId, ref: "Citizen", required: true, index: true },
    userId: { type: objectId, ref: "User", required: true, index: true },
    reportType: { type: String, enum: ["call", "sms", "whatsapp", "email", "upi", "website", "app", "deepfake", "other"], required: true, index: true },
    fraudType: { type: String, required: true, index: true },
    status: { type: String, enum: ["submitted", "verified", "investigating", "resolved", "dismissed", "duplicate"], default: "submitted", index: true },
    priority: { type: String, enum: ["low", "medium", "high", "critical"], default: "medium" },
    reportedPhoneNumber: { type: String, validate: phoneValidator, index: true },
    reportedUpiId: { type: String, validate: upiValidator, index: true },
    reportedBankAccount: { type: String },
    reportedWebsite: { type: String },
    reportedApp: { type: String },
    reportedEmail: { type: String },
    description: { type: String, required: true, maxlength: 2000 },
    amount: { type: Number, default: 0 },
    currency: { type: String, default: "INR" },
    location: {
      district: { type: String, index: true },
      state: { type: String, index: true },
      city: String,
      coordinates: {
        type: { type: String, enum: ["Point"] },
        coordinates: { type: [Number] }
      }
    },
    deviceInfo: {
      deviceId: { type: String, index: true },
      platform: String,
      appVersion: String,
      ipAddress: String
    },
    evidenceIds: [{ type: objectId, ref: "EvidenceFile" }],
    caseId: { type: objectId, ref: "Case", index: true },
    firId: { type: objectId, ref: "FIR", index: true },
    aiAnalysis: {
      confidence: { type: Number, min: 0, max: 1 },
      riskScore: { type: Number, min: 0, max: 100 },
      scamType: String,
      indicators: [String],
      recommendation: String,
      analyzedAt: Date
    },
    verifiedBy: { type: objectId, ref: "PoliceOfficer" },
    verifiedAt: { type: Date },
    resolutionNotes: { type: String },
    resolvedAt: { type: Date },
    source: { type: String, enum: ["citizen_app", "citizen_web", "police", "isp", "government", "ai"], default: "citizen_app" },
    tags: [{ type: String }],
    isRepeat: { type: Boolean, default: false },
    relatedReports: [{ type: objectId, ref: "FraudReport" }]
  },
  {
    collection: "fraud_reports",
    indexes: [
      { fields: { reportNumber: 1 }, options: { unique: true } },
      { fields: { citizenId: 1, createdAt: -1 } },
      { fields: { reportType: 1, status: 1 } },
      { fields: { fraudType: 1, status: 1 } },
      { fields: { reportedPhoneNumber: 1 } },
      { fields: { reportedUpiId: 1 } },
      { fields: { status: 1, priority: 1 } },
      { fields: { "location.district": 1, "location.state": 1 } },
      { fields: { "location.coordinates": "2dsphere" } },
      { fields: { "aiAnalysis.riskScore": -1 } },
      { fields: { createdAt: -1 } },
      { fields: { tags: 1 } }
    ]
  }
);