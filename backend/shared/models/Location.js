import { createModel, objectId } from "./base.js";

export default createModel(
  "Location",
  {
    citizenId: { type: objectId, ref: "Citizen", index: true },
    complaintId: { type: objectId, ref: "Complaint", index: true },
    type: { type: String, enum: ["incident", "device", "police_station", "caller_origin"], required: true, index: true },
    address: { type: String, maxlength: 500 },
    district: { type: String, trim: true, index: true },
    state: { type: String, trim: true, index: true },
    coordinates: {
      type: { type: String, enum: ["Point"], default: "Point" },
      coordinates: {
        type: [Number],
        validate: {
          validator: (value) => value.length === 2,
          message: "Coordinates must be [longitude, latitude]"
        }
      }
    }
  },
  { collection: "locations", indexes: [{ fields: { coordinates: "2dsphere" } }, { fields: { state: 1, district: 1 } }] }
);
