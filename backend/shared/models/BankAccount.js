import { createModel, objectId } from "./base.js";

export default createModel(
  "BankAccount",
  {
    citizenId: { type: objectId, ref: "Citizen", required: true, index: true },
    userId: { type: objectId, ref: "User", required: true },
    accountNumber: { type: String, required: true, index: true },
    ifsc: { type: String, required: true },
    bankName: { type: String, required: true, index: true },
    branch: { type: String },
    accountType: { type: String, enum: ["savings", "current", "salary", "nre", "nro"], default: "savings" },
    accountHolderName: { type: String, required: true },
    isPrimary: { type: Boolean, default: false },
    isVerified: { type: Boolean, default: false },
    verifiedAt: { type: Date },
    linkedUpiIds: [{ type: String }],
    status: { type: String, enum: ["active", "inactive", "frozen", "blocked"], default: "active", index: true },
    frozenAt: { type: Date },
    freezeReason: { type: String },
    totalTransactions: { type: Number, default: 0 },
    flaggedTransactions: { type: Number, default: 0 },
    riskScore: { type: Number, min: 0, max: 100, default: 0 },
    lastTransactionAt: { type: Date }
  },
  {
    collection: "bank_accounts",
    indexes: [
      { fields: { citizenId: 1, status: 1 } },
      { fields: { accountNumber: 1 } },
      { fields: { bankName: 1 } },
      { fields: { status: 1 } },
      { fields: { riskScore: -1 } }
    ]
  }
);