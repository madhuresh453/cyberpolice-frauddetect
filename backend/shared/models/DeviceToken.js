import { createModel, objectId } from "./base.js";

export default createModel(
  "DeviceToken",
  {
    userId: { type: objectId, ref: "User", required: true, index: true },
    token: { type: String, required: true, unique: true, trim: true },
    platform: { type: String, enum: ["android", "ios", "web"], required: true, index: true },
    deviceId: { type: String, required: true, trim: true, index: true },
    appVersion: { type: String, trim: true },
    lastSeenAt: { type: Date, default: Date.now, index: true }
  },
  { collection: "device_tokens", indexes: [{ fields: { userId: 1, platform: 1 } }] }
);
