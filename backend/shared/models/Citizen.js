import { createModel, objectId, phoneValidator } from "./base.js";

export default createModel(
  "Citizen",
  {
    userId: { type: objectId, ref: "User", required: true, unique: true, index: true },
    phoneNumber: { type: String, required: true, unique: true, validate: phoneValidator },
    aadhaarHash: { type: String, trim: true, select: false },
    preferredLanguage: { type: String, default: "en", minlength: 2, maxlength: 12 },
    state: { type: String, trim: true, maxlength: 80, index: true },
    district: { type: String, trim: true, maxlength: 120, index: true },
    emergencyContacts: [{ name: String, phoneNumber: { type: String, validate: phoneValidator } }],
    consent: {
      version: { type: String, required: true },
      acceptedAt: { type: Date, required: true }
    }
  },
  { collection: "citizens", indexes: [{ fields: { state: 1, district: 1 } }] }
);
