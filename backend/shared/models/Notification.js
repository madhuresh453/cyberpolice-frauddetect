import { createModel, objectId } from "./base.js";

export default createModel(
  "Notification",
  {
    userId: { type: objectId, ref: "User", required: true, index: true },
    channel: { type: String, enum: ["push", "sms", "email", "websocket", "system"], required: true, index: true },
    title: { type: String, required: true, maxlength: 160 },
    body: { type: String, required: true, maxlength: 2000 },
    payload: { type: Map, of: String, default: {} },
    status: { type: String, enum: ["queued", "sent", "failed", "read"], default: "queued", index: true },
    sentAt: Date,
    readAt: Date
  },
  { collection: "notifications", indexes: [{ fields: { userId: 1, createdAt: -1 } }] }
);
