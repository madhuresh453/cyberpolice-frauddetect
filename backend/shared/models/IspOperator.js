import { createModel, objectId } from "./base.js";

export default createModel(
  "IspOperator",
  {
    userId: { type: objectId, ref: "User", required: true, index: true },
    companyName: { type: String, required: true, trim: true },
    licenseNumber: { type: String, required: true, unique: true, index: true },
    contactEmail: { type: String, required: true },
    contactPhone: { type: String, required: true },
    companyType: { type: String, enum: ["isp", "telecom", "mobile_operator", "virtual_operator"], required: true, index: true },
    states: [{ type: String, index: true }],
    districts: [{ type: String, index: true }],
    totalSubscribers: { type: Number, default: 0 },
    activeSubscribers: { type: Number, default: 0 },
    fraudNumbersDetected: { type: Number, default: 0 },
    spamCallsBlocked: { type: Number, default: 0 },
    spamSmsBlocked: { type: Number, default: 0 },
    complianceScore: { type: Number, min: 0, max: 100, default: 50 },
    lastComplianceCheck: { type: Date },
    status: { type: String, enum: ["active", "inactive", "suspended", "pending_approval"], default: "pending_approval", index: true },
    approvedBy: { type: objectId, ref: "User" },
    approvedAt: { type: Date },
    lastReportAt: { type: Date }
  },
  {
    collection: "isp_operators",
    indexes: [
      { fields: { licenseNumber: 1 }, options: { unique: true } },
      { fields: { companyType: 1, status: 1 } },
      { fields: { states: 1 } },
      { fields: { complianceScore: -1 } },
      { fields: { status: 1 } }
    ]
  }
);