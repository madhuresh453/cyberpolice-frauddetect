import { RISK_LEVELS, createModel, phoneValidator } from "./base.js";

export default createModel(
  "ISPReport",
  {
    operatorCode: { type: String, required: true, trim: true, index: true },
    reportNumber: { type: String, required: true, unique: true, trim: true },
    phoneNumber: { type: String, required: true, validate: phoneValidator, index: true },
    riskLevel: { type: String, enum: RISK_LEVELS, required: true, index: true },
    action: { type: String, enum: ["observed", "blocked", "unblocked", "escalated"], required: true, index: true },
    metadata: { type: Map, of: String, default: {} },
    reportedAt: { type: Date, default: Date.now, index: true }
  },
  { collection: "isp_reports", indexes: [{ fields: { operatorCode: 1, reportedAt: -1 } }] }
);
