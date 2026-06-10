import { createModel, phoneValidator } from "./base.js";

export default createModel(
  "WhitelistNumber",
  {
    phoneNumber: { type: String, required: true, unique: true, validate: phoneValidator },
    organizationName: { type: String, required: true, trim: true, index: true },
    category: { type: String, enum: ["bank", "government", "police", "healthcare", "utility", "other"], required: true, index: true },
    verifiedBy: { type: String, required: true, trim: true },
    verifiedAt: { type: Date, default: Date.now, index: true }
  },
  { collection: "whitelist_numbers", indexes: [{ fields: { category: 1, organizationName: 1 } }] }
);
