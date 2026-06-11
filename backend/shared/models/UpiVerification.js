import { createModel, upiValidator, objectId } from "./base.js";

export default createModel(
  "UpiVerification",
  {
    citizenId: { type: objectId, ref: "Citizen", required: true, index: true },
    upiId: { type: String, required: true, validate: upiValidator, index: true },
    status: { type: String, enum: ["pending", "verified", "failed", "expired"], default: "pending", index: true },
    verificationType: { type: String, enum: ["penny_drop", "name_match", "bank_verify", "npci_verify"], required: true },
    accountHolderName: { type: String },
    bankName: { type: String },
    ifsc: { type: String },
    accountStatus: { type: String, enum: ["active", "inactive", "frozen", "dormant"] },
    riskScore: { type: Number, min: 0, max: 100, default: 0 },
    isFraud: { type: Boolean, default: false },
    verifiedAt: { type: Date },
    expiresAt: { type: Date, index: true },
    verificationRef: { type: String },
    lastCheckedAt: { type: Date },
    checkCount: { type: Number, default: 0 }
  },
  {
    collection: "upi_verifications",
    indexes: [
      { fields: { upiId: 1, status: 1 } },
      { fields: { citizenId: 1 } },
      { fields: { status: 1 } },
      { fields: { riskScore: -1 } },
      { fields: { expiresAt: 1 } }
    ]
  }
);