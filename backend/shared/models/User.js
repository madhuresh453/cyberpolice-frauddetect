import { ROLES, STATUS_VALUES, createModel, phoneValidator } from "./base.js";

export default createModel(
  "User",
  {
    email: { type: String, lowercase: true, trim: true, unique: true, sparse: true, index: true },
    phoneNumber: { type: String, unique: true, sparse: true, validate: phoneValidator, index: true },
    passwordHash: { type: String, required: true, select: false },
    fullName: { type: String, required: true, trim: true, minlength: 2, maxlength: 160 },
    role: { type: String, enum: ROLES, required: true, index: true },
    roles: { type: [String], enum: ROLES, default: [] },
    status: { type: String, enum: STATUS_VALUES, default: "active", index: true },
    lastLoginAt: { type: Date, default: null },
    mfaEnabled: { type: Boolean, default: false }
  },
  { collection: "users", indexes: [{ fields: { role: 1, status: 1 } }] }
);
