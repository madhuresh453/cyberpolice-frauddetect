import { createModel, phoneValidator, objectId } from "./base.js";

export default createModel(
  "EmergencySession",
  {
    citizenId: { type: objectId, ref: "Citizen", required: true, index: true },
    sosId: { type: objectId, ref: "EmergencySos", required: true, index: true },
    status: { type: String, enum: ["active", "monitoring", "responding", "resolved", "expired"], default: "active", index: true },
    startLocation: {
      district: { type: String },
      state: { type: String },
      coordinates: {
        type: { type: String, enum: ["Point"] },
        coordinates: { type: [Number] }
      }
    },
    currentLocation: {
      district: { type: String },
      state: { type: String },
      coordinates: {
        type: { type: String, enum: ["Point"] },
        coordinates: { type: [Number] }
      }
    },
    locationHistory: [{
      coordinates: { type: [Number] },
      timestamp: { type: Date },
      accuracy: { type: Number }
    }],
    audioRecording: { type: String },
    videoRecording: { type: String },
    autoRecordingEnabled: { type: Boolean, default: false },
    duration: { type: Number },
    devices: [{ deviceId: String, platform: String, batteryLevel: Number }],
    notifications: [{
      type: { type: String, enum: ["sms", "call", "push", "email"] },
      recipient: String,
      sentAt: Date,
      status: String
    }],
    resolvedBy: { type: objectId, ref: "PoliceOfficer" },
    resolvedAt: { type: Date },
    resolutionNotes: { type: String }
  },
  {
    collection: "emergency_sessions",
    indexes: [
      { fields: { citizenId: 1, createdAt: -1 } },
      { fields: { sosId: 1 } },
      { fields: { status: 1 } },
      { fields: { "startLocation.coordinates": "2dsphere" } }
    ]
  }
);