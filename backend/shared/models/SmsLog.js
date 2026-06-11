import { createModel, phoneValidator, objectId } from "./base.js";

export default createModel(
  "SmsLog",
  {
    senderNumber: { type: String, required: true, index: true },
    receiverNumber: { type: String, required: true, index: true },
    message: { type: String, required: true },
    messageHash: { type: String, index: true },
    timestamp: { type: Date, required: true, index: true },
    direction: { type: String, enum: ["inbound", "outbound"], required: true },
    messageId: { type: String },
    parts: { type: Number, default: 1 },
    characterCount: { type: Number, default: 0 },
    ispId: { type: objectId, ref: "IspOperator", index: true },
    carrier: { type: String },
    location: {
      district: { type: String, index: true },
      state: { type: String, index: true }
    },
    deviceId: { type: String, index: true },
    riskScore: { type: Number, min: 0, max: 100, default: 0 },
    isFlagged: { type: Boolean, default: false, index: true },
    flagReason: { type: String },
    fraudIndicators: [{ type: String }],
    containsUrl: { type: Boolean, default: false },
    urls: [{ type: String }],
    containsKeywords: [{ type: String }],
    language: { type: String },
    category: { type: String, enum: ["legitimate", "spam", "fraud", "phishing", "promotional", "otp", "transactional", "unknown"], default: "unknown", index: true }
  },
  {
    collection: "sms_logs",
    indexes: [
      { fields: { senderNumber: 1, timestamp: -1 } },
      { fields: { receiverNumber: 1, timestamp: -1 } },
      { fields: { timestamp: -1 } },
      { fields: { isFlagged: 1, riskScore: -1 } },
      { fields: { category: 1 } },
      { fields: { messageHash: 1 } },
      { fields: { deviceId: 1 } }
    ]
  }
);