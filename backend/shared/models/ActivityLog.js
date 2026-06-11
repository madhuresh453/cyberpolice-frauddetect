import { createModel, objectId } from "./base.js";

export default createModel(
  "ActivityLog",
  {
    userId: { type: objectId, ref: "User", required: true, index: true },
    action: { type: String, required: true, index: true },
    category: { type: String, enum: ["auth", "report", "case", "evidence", "emergency", "admin", "system", "api"], required: true, index: true },
    severity: { type: String, enum: ["info", "warning", "error", "critical"], default: "info", index: true },
    resource: { type: String },
    resourceId: { type: String },
    description: { type: String, maxlength: 1000 },
    metadata: {
      ipAddress: { type: String },
      userAgent: { type: String },
      requestId: { type: String },
      method: { type: String },
      path: { type: String },
      statusCode: { type: Number },
      duration: { type: Number }
    },
    status: { type: String, enum: ["success", "failure", "pending"], default: "success" },
    geoLocation: {
      district: { type: String },
      state: { type: String },
      coordinates: { type: [Number] }
    }
  },
  {
    collection: "activity_logs",
    indexes: [
      { fields: { userId: 1, createdAt: -1 } },
      { fields: { action: 1, createdAt: -1 } },
      { fields: { category: 1, createdAt: -1 } },
      { fields: { severity: 1, createdAt: -1 } },
      { fields: { resource: 1, resourceId: 1 } },
      { fields: { createdAt: -1 } }
    ]
  }
);