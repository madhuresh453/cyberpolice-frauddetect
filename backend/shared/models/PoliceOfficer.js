import { createModel, phoneValidator, objectId } from "./base.js";

export default createModel(
  "PoliceOfficer",
  {
    userId: { type: objectId, ref: "User", required: true, index: true },
    employeeId: { type: String, required: true, unique: true, index: true },
    phoneNumber: { type: String, required: true, validate: phoneValidator, index: true },
    fullName: { type: String, required: true, trim: true },
    rank: { type: String, enum: ["constable", "head_constable", "asi", "si", "inspector", "dsp", "addl_sp", "sp", "dig", "ig", "adgp", "dgp"], required: true, index: true },
    designation: { type: String },
    departmentId: { type: objectId, ref: "PoliceDepartment", required: true, index: true },
    departmentName: { type: String },
    state: { type: String, required: true, index: true },
    district: { type: String, required: true, index: true },
    station: { type: String },
    specialization: [{ type: String, enum: ["cyber_crime", "financial_fraud", "identity_theft", "phishing", "digital_forensics", "general"], index: true }],
    badge: { type: String },
    jurisdictionArea: { type: String },
    assignedCases: { type: Number, default: 0 },
    solvedCases: { type: Number, default: 0 },
    activeCases: { type: Number, default: 0 },
    clearanceRate: { type: Number, default: 0 },
    status: { type: String, enum: ["active", "inactive", "suspended", "transferred"], default: "active", index: true },
    dateOfJoining: { type: Date },
    lastPromotionDate: { type: Date },
    trainingCompleted: [{ type: String, dateCompleted: Date }],
    accessLevel: { type: String, enum: ["basic", "elevated", "admin", "super_admin"], default: "basic", index: true },
    lastActiveAt: { type: Date }
  },
  {
    collection: "police_officers",
    indexes: [
      { fields: { employeeId: 1 }, options: { unique: true } },
      { fields: { departmentId: 1, status: 1 } },
      { fields: { rank: 1, status: 1 } },
      { fields: { state: 1, district: 1 } },
      { fields: { specialization: 1 } },
      { fields: { clearanceRate: -1 } }
    ]
  }
);