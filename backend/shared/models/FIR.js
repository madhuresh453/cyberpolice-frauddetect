import { createModel, phoneValidator, objectId } from "./base.js";

export default createModel(
  "FIR",
  {
    firNumber: { type: String, required: true, unique: true, index: true },
    caseId: { type: objectId, ref: "Case", required: true, index: true },
    citizenId: { type: objectId, ref: "Citizen", required: true, index: true },
    complainantName: { type: String, required: true },
    complainantPhone: { type: String, required: true, validate: phoneValidator },
    complainantAddress: { type: String },
    accusedName: { type: String },
    accusedPhone: { type: String, validate: phoneValidator },
    accusedDetails: { type: String },
    offense: { type: String, required: true },
    offenseSection: { type: String, required: true },
    offenseDescription: { type: String, required: true },
    ipcSections: [{ type: String }],
    bnsSections: [{ type: String }],
    placeOfOffense: { type: String, required: true },
    dateOfOffense: { type: Date, required: true },
    dateOfReport: { type: Date, default: Date.now },
    status: {
      type: String,
      enum: ["registered", "under_investigation", "charge_sheet_filed", "closed", "transferred"],
      default: "registered",
      index: true
    },
    priority: { type: String, enum: ["low", "medium", "high", "critical"], default: "medium" },
    assignedOfficer: { type: objectId, ref: "PoliceOfficer", index: true },
    departmentId: { type: objectId, ref: "PoliceDepartment", index: true },
    district: { type: String, required: true, index: true },
    state: { type: String, required: true, index: true },
    estimatedLoss: { type: Number, default: 0 },
    recoveredAmount: { type: Number, default: 0 },
    evidenceIds: [{ type: objectId, ref: "EvidenceFile" }],
    relatedFirs: [{ type: objectId, ref: "FIR" }],
    isCompoundable: { type: Boolean, default: false },
    isNonCompoundable: { type: Boolean, default: true },
    remarks: { type: String, maxlength: 2000 },
    timeline: [{
      action: String,
      performedBy: { type: objectId, ref: "User" },
      timestamp: { type: Date, default: Date.now },
      details: String
    }]
  },
  {
    collection: "firs",
    indexes: [
      { fields: { firNumber: 1 }, options: { unique: true } },
      { fields: { caseId: 1 } },
      { fields: { citizenId: 1 } },
      { fields: { status: 1, dateOfReport: -1 } },
      { fields: { district: 1, state: 1 } },
      { fields: { assignedOfficer: 1 } },
      { fields: { dateOfReport: -1 } },
      { fields: { offenseSection: 1 } }
    ]
  }
);