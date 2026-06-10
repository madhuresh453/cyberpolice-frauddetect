import { createModel, objectId, phoneValidator } from "./base.js";

export default createModel(
  "FIRReport",
  {
    firNumber: { type: String, required: true, unique: true, trim: true },
    complaintId: { type: objectId, ref: "Complaint", index: true },
    citizenId: { type: objectId, ref: "Citizen", required: true, index: true },
    officerId: { type: objectId, ref: "PoliceOfficer", required: true, index: true },
    accusedNumber: { type: String, validate: phoneValidator, index: true },
    policeStation: { type: String, required: true, trim: true },
    sections: { type: [String], default: [] },
    narrative: { type: String, required: true, maxlength: 10000 },
    documentUri: { type: String, trim: true },
    digitalSignatureHash: { type: String, match: /^[a-f0-9]{64}$/ },
    filedAt: { type: Date, required: true, index: true }
  },
  { collection: "fir_reports", indexes: [{ fields: { policeStation: 1, filedAt: -1 } }] }
);
