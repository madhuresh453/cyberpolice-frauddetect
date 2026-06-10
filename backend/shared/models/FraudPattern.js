import { RISK_LEVELS, createModel } from "./base.js";

export default createModel(
  "FraudPattern",
  {
    patternCode: { type: String, required: true, unique: true, trim: true },
    name: { type: String, required: true, trim: true },
    category: { type: String, required: true, trim: true, index: true },
    riskLevel: { type: String, enum: RISK_LEVELS, required: true, index: true },
    keywords: { type: [String], default: [], index: true },
    languages: { type: [String], default: ["en"] },
    indicators: { type: Map, of: String, default: {} },
    active: { type: Boolean, default: true, index: true }
  },
  { collection: "fraud_patterns", indexes: [{ fields: { category: 1, active: 1, riskLevel: 1 } }] }
);
