import { createModel, objectId, phoneValidator } from "./base.js";

export default createModel(
  "PoliceOfficer",
  {
    userId: { type: objectId, ref: "User", required: true, unique: true, index: true },
    badgeNumber: { type: String, required: true, unique: true, trim: true },
    rank: { type: String, required: true, trim: true },
    stationName: { type: String, required: true, trim: true, index: true },
    state: { type: String, required: true, trim: true, index: true },
    district: { type: String, required: true, trim: true, index: true },
    contactNumber: { type: String, validate: phoneValidator },
    permissions: { type: [String], default: [] }
  },
  { collection: "police_officers", indexes: [{ fields: { state: 1, district: 1, stationName: 1 } }] }
);
