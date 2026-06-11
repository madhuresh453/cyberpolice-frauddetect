import { createModel, phoneValidator, objectId } from "./base.js";

export default createModel(
  "FamilyMember",
  {
    citizenId: { type: objectId, ref: "Citizen", required: true, index: true },
    userId: { type: objectId, ref: "User", required: true, index: true },
    name: { type: String, required: true, trim: true },
    phoneNumber: { type: String, required: true, validate: phoneValidator, index: true },
    relation: { type: String, enum: ["spouse", "parent", "child", "sibling", "other"], required: true },
    dateOfBirth: { type: Date },
    gender: { type: String, enum: ["male", "female", "other"] },
    protectionEnabled: { type: Boolean, default: true },
    trustScore: { type: Number, default: 50, min: 0, max: 100 },
    riskCategory: { type: String, enum: ["safe", "low", "medium", "high", "critical"], default: "safe" },
    status: { type: String, enum: ["active", "inactive", "blocked"], default: "active", index: true },
    addedBy: { type: objectId, ref: "User", required: true },
    lastVerifiedAt: { type: Date }
  },
  {
    collection: "family_members",
    indexes: [
      { fields: { citizenId: 1, status: 1 } },
      { fields: { phoneNumber: 1 } },
      { fields: { relation: 1 } },
      { fields: { trustScore: -1 } }
    ]
  }
);