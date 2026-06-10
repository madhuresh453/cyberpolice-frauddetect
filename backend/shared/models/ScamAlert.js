import { RISK_LEVELS, createModel, objectId, phoneValidator } from "./base.js";

export default createModel(
  "ScamAlert",
  {
    callId: { type: objectId, ref: "Call", index: true },
    citizenId: { type: objectId, ref: "Citizen", required: true, index: true },
    phoneNumber: { type: String, required: true, validate: phoneValidator, index: true },
    alertType: { type: String, required: true, trim: true, index: true },
    riskLevel: { type: String, enum: RISK_LEVELS, required: true, index: true },
    riskScore: { type: Number, required: true, min: 0, max: 100 },
    message: { type: String, required: true, maxlength: 1000 },
    acknowledgedAt: Date
  },
  { collection: "scam_alerts", indexes: [{ fields: { riskLevel: 1, createdAt: -1 } }] }
);
