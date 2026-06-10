import mongoose from "mongoose";
import { ROLES, createModel, objectId } from "./base.js";

export default createModel(
  "AuditLog",
  {
    actorUserId: { type: objectId, ref: "User", index: true },
    actorRole: { type: String, enum: ROLES, required: true, index: true },
    action: { type: String, required: true, trim: true, index: true },
    resource: { type: String, required: true, trim: true, index: true },
    resourceId: { type: objectId, index: true },
    before: { type: mongoose.Schema.Types.Mixed, default: null },
    after: { type: mongoose.Schema.Types.Mixed, default: null },
    ipAddress: { type: String, trim: true },
    userAgent: { type: String, trim: true },
    requestId: { type: String, trim: true, index: true }
  },
  { collection: "audit_logs", indexes: [{ fields: { resource: 1, resourceId: 1, createdAt: -1 } }] }
);
