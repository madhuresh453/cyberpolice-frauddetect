import { createModel, objectId } from "./base.js";

export default createModel(
  "PoliceDepartment",
  {
    name: { type: String, required: true, trim: true },
    code: { type: String, required: true, unique: true, index: true },
    type: { type: String, enum: ["state", "district", "city", "cyber_cell", "special_unit"], required: true, index: true },
    state: { type: String, required: true, index: true },
    district: { type: String, required: true, index: true },
    city: { type: String },
    address: {
      street: String,
      city: String,
      district: String,
      state: String,
      pincode: String,
      coordinates: {
        type: { type: String, enum: ["Point"] },
        coordinates: { type: [Number] }
      }
    },
    contactInfo: {
      phone: String,
      email: String,
      fax: String,
      website: String
    },
    jurisdiction: {
      states: [String],
      districts: [String],
      statesC: [String]
    },
    headOfficer: { type: objectId, ref: "PoliceOfficer" },
    totalOfficers: { type: Number, default: 0 },
    activeCases: { type: Number, default: 0 },
    totalCasesHandled: { type: Number, default: 0 },
    clearanceRate: { type: Number, default: 0 },
    status: { type: String, enum: ["active", "inactive", "merged"], default: "active", index: true },
    operationalHours: {
      open: String,
      close: String,
      twentyFourSeven: { type: Boolean, default: true }
    }
  },
  {
    collection: "police_departments",
    indexes: [
      { fields: { code: 1 }, options: { unique: true } },
      { fields: { state: 1, district: 1 } },
      { fields: { type: 1, status: 1 } },
      { fields: { "address.coordinates": "2dsphere" } }
    ]
  }
);