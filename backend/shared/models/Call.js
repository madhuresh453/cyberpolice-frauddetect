import { RISK_LEVELS, createModel, objectId, phoneValidator } from "./base.js";

export default createModel(
  "Call",
  {
    citizenId: { type: objectId, ref: "Citizen", required: true, index: true },
    callerNumber: { type: String, required: true, validate: phoneValidator, index: true },
    receiverNumber: { type: String, required: true, validate: phoneValidator, index: true },
    direction: { type: String, enum: ["incoming", "outgoing"], required: true },
    startedAt: { type: Date, required: true, index: true },
    endedAt: Date,
    durationSeconds: { type: Number, min: 0, default: 0 },
    riskLevel: { type: String, enum: RISK_LEVELS, default: "safe", index: true },
    status: { type: String, enum: ["ringing", "answered", "missed", "blocked", "ended"], index: true }
  },
  { collection: "calls", indexes: [{ fields: { callerNumber: 1, startedAt: -1 } }] }
);
