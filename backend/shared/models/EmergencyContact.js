import { createModel, phoneValidator, objectId } from "./base.js";

export default createModel(
  "EmergencyContact",
  {
    citizenId: { type: objectId, ref: "Citizen", required: true, index: true },
    name: { type: String, required: true, trim: true },
    phoneNumber: { type: String, required: true, validate: phoneValidator, index: true },
    alternativePhone: { type: String, validate: phoneValidator },
    email: { type: String },
    relation: { type: String, enum: ["spouse", "parent", "child", "sibling", "friend", "colleague", "neighbor", "other"], required: true },
    isPrimary: { type: Boolean, default: false },
    notifyOnSos: { type: Boolean, default: true },
    notifyOnLocation: { type: Boolean, default: false },
    notifyOnFraud: { type: Boolean, default: true },
    status: { type: String, enum: ["active", "inactive", "blocked"], default: "active", index: true },
    lastNotifiedAt: { type: Date },
    totalNotifications: { type: Number, default: 0 },
    address: { type: String },
    verified: { type: Boolean, default: false },
    verifiedAt: { type: Date }
  },
  {
    collection: "emergency_contacts",
    indexes: [
      { fields: { citizenId: 1, status: 1 } },
      { fields: { phoneNumber: 1 } },
      { fields: { relation: 1 } }
    ]
  }
);