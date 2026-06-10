import { createModel, objectId } from "./base.js";

export default createModel(
  "CallRecording",
  {
    callId: { type: objectId, ref: "Call", required: true, unique: true, index: true },
    storageUri: { type: String, required: true, trim: true },
    sha256: { type: String, required: true, match: /^[a-f0-9]{64}$/, unique: true },
    encryptionKeyId: { type: String, required: true, select: false },
    durationSeconds: { type: Number, min: 0, required: true },
    transcript: { type: String, default: "" },
    language: { type: String, default: "en" }
  },
  { collection: "call_recordings", indexes: [{ fields: { language: 1, createdAt: -1 } }] }
);
