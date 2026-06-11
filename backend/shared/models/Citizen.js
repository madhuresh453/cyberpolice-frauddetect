import { createModel, phoneValidator, upiValidator, objectId } from "./base.js";

export default createModel(
  "Citizen",
  {
    userId: { type: objectId, ref: "User", required: true, index: true },
    aadhaarHash: { type: String, required: true, unique: true, index: true },
    phoneNumber: { type: String, required: true, unique: true, validate: phoneValidator, index: true },
    alternativePhone: { type: String, validate: phoneValidator },
    email: { type: String, lowercase: true, trim: true },
    fullName: { type: String, required: true, trim: true },
    dateOfBirth: { type: Date },
    gender: { type: String, enum: ["male", "female", "other"] },
    address: {
      street: String,
      city: String,
      district: { type: String, index: true },
      state: { type: String, index: true },
      pincode: String,
      country: { type: String, default: "India" },
      coordinates: {
        type: { type: String, enum: ["Point"] },
        coordinates: { type: [Number] }
      }
    },
    upiId: { type: String, sparse: true, validate: upiValidator, index: true },
    deviceIds: [{ type: String, index: true }],
    trustScore: { type: Number, default: 50, min: 0, max: 100, index: true },
    riskCategory: { type: String, enum: ["safe", "low", "medium", "high", "critical"], default: "safe", index: true },
    verificationStatus: { type: String, enum: ["unverified", "pending", "verified", "rejected"], default: "unverified", index: true },
    kycStatus: { type: String, enum: ["not_started", "pending", "completed", "failed"], default: "not_started" },
    totalReports: { type: Number, default: 0 },
    activeFamilyMembers: { type: Number, default: 0 },
    emergencyContact: {
      name: String,
      phone: String,
      relation: String
    },
    preferences: {
      language: { type: String, default: "en" },
      notifications: { type: Boolean, default: true },
      familyProtection: { type: Boolean, default: false },
      autoBlock: { type: Boolean, default: false }
    },
    accountStatus: { type: String, enum: ["active", "suspended", "deactivated"], default: "active", index: true },
    lastActiveAt: { type: Date },
    registeredAt: { type: Date, default: Date.now }
  },
  {
    collection: "citizens",
    indexes: [
      { fields: { phoneNumber: 1 }, options: { unique: true } },
      { fields: { aadhaarHash: 1 }, options: { unique: true } },
      { fields: { upiId: 1 }, options: { sparse: true } },
      { fields: { district: 1, state: 1 } },
      { fields: { trustScore: -1 } },
      { fields: { riskCategory: 1, trustScore: -1 } },
      { fields: { "address.coordinates": "2dsphere" } },
      { fields: { deviceIds: 1 } },
      { fields: { createdAt: -1 } },
      { fields: { accountStatus: 1, createdAt: -1 } }
    ]
  }
);