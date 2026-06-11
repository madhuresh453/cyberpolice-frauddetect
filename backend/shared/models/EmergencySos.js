import { createModel, phoneValidator, objectId } from "./base.js";

export default createModel(
  "EmergencySos",
  {
    citizenId: { type: objectId, ref: "Citizen", required: true, index: true },
    userId: { type: objectId, ref: "User", required: true },
    sessionId: { type: objectId, ref: "EmergencySession", index: true },
    triggerType: { type: String, enum: ["manual", "panic_button", "voice_command", "gesture", "auto_detection"], required: true },
    status: { type: String, enum: ["active", "acknowledged", "responding", "resolved", "false_alarm"], default: "active", index: true },
    priority: { type: String, enum: ["high", "critical"], default: "critical", index: true },
    location: {
      district: { type: String, index: true },
      state: { type: String, index: true },
      city: String,
      address: String,
      coordinates: {
        type: { type: String, enum: ["Point"] },
        coordinates: { type: [Number] }
      }
    },
    deviceInfo: {
      deviceId: String,
      platform: String,
      batteryLevel: Number,
      ipAddress: String
    },
    description: { type: String, maxlength: 500 },
    evidenceIds: [{ type: objectId, ref: "EvidenceFile" }],
    assignedStation: { type: objectId, ref: "PoliceDepartment" },
    assignedOfficer: { type: objectId, ref: "PoliceOfficer", index: true },
    respondedAt: { type: Date },
    resolvedAt: { type: Date },
    responseTime: { type: Number },
    contactedNumbers: [{
      number: { type: String },
      name: { type: String },
      relation: { type: String },
      notified: { type: Boolean, default: false },
      notifiedAt: { type: Date }
    }],
    notifications: [{
      channel: { type: String, enum: ["sms", "call", "push", "email"] },
      sent: { type: Boolean, default: false },
      sentAt: { type: Date },
      status: { type: String }
    }]
  },
  {
    collection: "emergency_sos",
    indexes: [
      { fields: { citizenId: 1, createdAt: -1 } },
      { fields: { status: 1, priority: 1 } },
      { fields: { assignedOfficer: 1, status: 1 } },
      { fields: { "location.coordinates": "2dsphere" } },
      { fields: { createdAt: -1 } }
    ]
  }
);