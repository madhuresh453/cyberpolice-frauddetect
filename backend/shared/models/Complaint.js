import { RISK_LEVELS, createModel, objectId, phoneValidator, upiValidator } from "./base.js";

export default createModel(
  "Complaint",
  {
    complaintNumber: { type: String, required: true, unique: true, trim: true },
    citizenId: { type: objectId, ref: "Citizen", required: true, index: true },
    assignedOfficerId: { type: objectId, ref: "PoliceOfficer", index: true },
    scamType: { type: String, required: true, trim: true, index: true },
    riskLevel: { type: String, enum: RISK_LEVELS, default: "medium", index: true },
    accusedNumber: { type: String, validate: phoneValidator, index: true },
    accusedUpiId: { type: String, validate: upiValidator, index: true },
    amountLostPaise: { type: Number, min: 0, default: 0 },
    description: { type: String, required: true, maxlength: 5000 },
    status: { type: String, enum: ["submitted", "triaged", "investigating", "closed"], default: "submitted", index: true },
    submittedAt: { type: Date, default: Date.now, index: true }
  },
  { collection: "complaints", indexes: [{ fields: { status: 1, riskLevel: 1, submittedAt: -1 } }] }
);
