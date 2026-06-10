import mongoose from "mongoose";
import { RISK_LEVELS, createModel, objectId } from "./base.js";

export default createModel(
  "AIPrediction",
  {
    entityType: { type: String, enum: ["call", "sms", "whatsapp", "upi", "voice", "pattern"], required: true, index: true },
    entityId: { type: objectId, required: true, index: true },
    modelName: { type: String, required: true, trim: true },
    modelVersion: { type: String, required: true, trim: true },
    riskLevel: { type: String, enum: RISK_LEVELS, required: true, index: true },
    riskScore: { type: Number, required: true, min: 0, max: 100 },
    confidence: { type: Number, required: true, min: 0, max: 100 },
    features: { type: Map, of: mongoose.Schema.Types.Mixed, default: {} },
    explanation: { type: String, default: "" }
  },
  { collection: "ai_predictions", indexes: [{ fields: { entityType: 1, entityId: 1 } }] }
);
