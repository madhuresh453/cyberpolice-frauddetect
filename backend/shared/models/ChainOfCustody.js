import { createModel, objectId } from "./base.js";

export default createModel(
  "ChainOfCustody",
  {
    evidenceId: { type: objectId, ref: "EvidenceFile", required: true, index: true },
    action: {
      type: String,
      enum: ["uploaded", "verified", "analyzed", "transferred", "accessed", "archived", "submitted_to_court"],
      required: true,
      index: true
    },
    actionBy: { type: objectId, ref: "User", required: true, index: true },
    actionByRole: { type: String, required: true },
    previousHandler: { type: objectId, ref: "User" },
    newHandler: { type: objectId, ref: "User" },
    location: String,
    reason: String,
    notes: String,
    digitalSignature: String,
    hashVerification: String,
    metadata: { type: Map, of: String },
    timestamp: { type: Date, default: Date.now, index: true }
  },
  {
    collection: "chain_of_custody",
    indexes: [
      { fields: { evidenceId: 1, timestamp: -1 } },
      { fields: { actionBy: 1, timestamp: -1 } },
      { fields: { action: 1, timestamp: -1 } },
      { fields: { timestamp: -1 } },
      { fields: { evidenceId: 1, action: 1 } }
    ]
  }
);