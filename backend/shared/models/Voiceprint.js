import { RISK_LEVELS, createModel, objectId } from "./base.js";

export default createModel(
  "Voiceprint",
  {
    citizenId: { type: objectId, ref: "Citizen", index: true },
    callRecordingId: { type: objectId, ref: "CallRecording", required: true, index: true },
    embeddingHash: { type: String, required: true, unique: true, trim: true },
    modelVersion: { type: String, required: true },
    riskLevel: { type: String, enum: RISK_LEVELS, default: "safe", index: true },
    matchScore: { type: Number, min: 0, max: 100, default: 0 },
    knownScammerClusterId: { type: String, trim: true, index: true }
  },
  { collection: "voiceprints", indexes: [{ fields: { knownScammerClusterId: 1, riskLevel: 1 } }] }
);
