import mongoose from "mongoose";

// ===== MODELS =====
const Report = mongoose.models.Report || mongoose.model("Report", new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  fraudType: { type: String, enum: ["CALL", "SMS", "WHATSAPP", "UPI", "PHISHING", "REMOTE_ACCESS", "SCREEN_SHARING", "FAKE_APK", "OTHER"], required: true },
  phoneNumber: String,
  description: { type: String, required: true },
  amount: Number,
  status: { type: String, enum: ["PENDING", "REVIEWING", "RESOLVED", "DISMISSED"], default: "PENDING" },
  evidenceUrls: [String],
  location: {
    latitude: Number,
    longitude: Number,
    city: String,
    state: String,
  },
  riskScore: { type: Number, default: 0 },
  metadata: mongoose.Schema.Types.Mixed,
  caseId: String,
  assignedTo: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
  resolvedAt: Date,
}, { timestamps: true }));

const CallLog = mongoose.models.CallLog || mongoose.model("CallLog", new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  phoneNumber: { type: String, required: true },
  callerName: String,
  direction: { type: String, enum: ["incoming", "outgoing"], default: "incoming" },
  status: { type: String, enum: ["safe", "suspicious", "blocked", "fraud"], default: "safe" },
  duration: { type: Number, default: 0 },
  riskScore: { type: Number, default: 0 },
  isFraud: { type: Boolean, default: false },
  transcript: String,
  keywords: [String],
  recordingUrl: String,
  location: String,
  analysisResult: mongoose.Schema.Types.Mixed,
}, { timestamps: true }));

const SmsLog = mongoose.models.SmsLog || mongoose.model("SmsLog", new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  sender: { type: String, required: true },
  message: { type: String, required: true },
  riskScore: { type: Number, default: 0 },
  isFraud: { type: Boolean, default: false },
  fraudType: String,
  suspiciousLinks: [String],
  indicators: [String],
  status: { type: String, enum: ["safe", "suspicious", "blocked"], default: "safe" },
}, { timestamps: true }));

const Threat = mongoose.models.Threat || mongoose.model("Threat", new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
  type: { type: String, required: true },
  severity: { type: String, enum: ["low", "medium", "high", "critical"], default: "medium" },
  title: { type: String, required: true },
  description: String,
  source: String,
  ipAddress: String,
  location: String,
  metadata: mongoose.Schema.Types.Mixed,
  isResolved: { type: Boolean, default: false },
  resolvedAt: Date,
}, { timestamps: true }));

const Transaction = mongoose.models.Transaction || mongoose.model("Transaction", new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  amount: { type: Number, required: true },
  merchantName: String,
  merchantId: String,
  upiId: String,
  transactionType: { type: String, enum: ["UPI", "NEFT", "RTGS", "CARD", "OTHER"], default: "UPI" },
  riskScore: { type: Number, default: 0 },
  isFraudulent: { type: Boolean, default: false },
  status: { type: String, enum: ["PENDING", "COMPLETED", "FAILED", "BLOCKED"], default: "PENDING" },
  location: String,
  deviceInfo: mongoose.Schema.Types.Mixed,
}, { timestamps: true }));

const FamilyMember = mongoose.models.FamilyMember || mongoose.model("FamilyMember", new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  name: { type: String, required: true },
  phoneNumber: { type: String, required: true },
  relation: { type: String, enum: ["father", "mother", "son", "daughter", "spouse", "sibling", "other"], required: true },
  status: { type: String, enum: ["active", "inactive"], default: "active" },
  protectionEnabled: { type: Boolean, default: true },
  riskAlerts: [{
    type: { type: String },
    message: String,
    severity: String,
    timestamp: { type: Date, default: Date.now },
  }],
}, { timestamps: true }));

const Evidence = mongoose.models.Evidence || mongoose.model("Evidence", new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  reportId: { type: mongoose.Schema.Types.ObjectId, ref: "Report" },
  type: { type: String, enum: ["AUDIO", "IMAGE", "VIDEO", "PDF", "SCREENSHOT", "TEXT"], required: true },
  url: { type: String, required: true },
  thumbnailUrl: String,
  fileSize: Number,
  mimeType: String,
  metadata: mongoose.Schema.Types.Mixed,
  isEncrypted: { type: Boolean, default: true },
}, { timestamps: true }));

const Notification = mongoose.models.Notification || mongoose.model("Notification", new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  title: { type: String, required: true },
  message: { type: String, required: true },
  type: { type: String, enum: ["ALERT", "THREAT", "REPORT", "FAMILY", "SYSTEM", "TRAINING"], default: "ALERT" },
  severity: { type: String, enum: ["info", "warning", "critical"], default: "info" },
  data: mongoose.Schema.Types.Mixed,
  read: { type: Boolean, default: false },
  readAt: Date,
}, { timestamps: true }));

const TrainingModule = mongoose.models.TrainingModule || mongoose.model("TrainingModule", new mongoose.Schema({
  title: { type: String, required: true },
  description: String,
  category: { type: String, enum: ["OTP", "KYC", "UPI", "LOAN", "PHISHING", "REMOTE_ACCESS", "GENERAL"], required: true },
  content: { type: String, required: true },
  difficulty: { type: String, enum: ["beginner", "intermediate", "advanced"], default: "beginner" },
  duration: Number,
  quiz: [{
    question: String,
    options: [String],
    correctAnswer: Number,
    explanation: String,
  }],
  badgeReward: String,
  completionCount: { type: Number, default: 0 },
  isActive: { type: Boolean, default: true },
}, { timestamps: true }));

export {
  Report,
  CallLog,
  SmsLog,
  Threat,
  Transaction,
  FamilyMember,
  Evidence,
  Notification,
  TrainingModule,
};