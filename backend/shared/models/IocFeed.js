import { createModel, objectId } from "./base.js";

export default createModel(
  "IocFeed",
  {
    indicator: { type: String, required: true, index: true },
    type: { type: String, enum: ["phone", "ip", "domain", "url", "hash", "email", "upi", "bank_account", "imei", "app_package"], required: true, index: true },
    threatType: { type: String, required: true, index: true },
    severity: { type: String, enum: ["low", "medium", "high", "critical"], required: true, index: true },
    confidence: { type: Number, min: 0, max: 1, required: true },
    source: { type: String, required: true, index: true },
    sourceReference: { type: String },
    description: { type: String },
    firstSeen: { type: Date, default: Date.now, index: true },
    lastSeen: { type: Date, default: Date.now, index: true },
    expiryDate: { type: Date, index: true },
    isActive: { type: Boolean, default: true, index: true },
    totalHits: { type: Number, default: 0 },
    affectedStates: [{ type: String }],
    campaignId: { type: String, index: true },
    caseIds: [{ type: objectId, ref: "Case" }],
    tags: [{ type: String }],
    mitigationActions: [{ action: String, timestamp: Date, performedBy: { type: objectId, ref: "User" } }],
    relatedIocs: [{ type: objectId, ref: "IocFeed" }]
  },
  {
    collection: "ioc_feeds",
    indexes: [
      { fields: { indicator: 1, type: 1 }, options: { unique: true } },
      { fields: { type: 1, isActive: 1 } },
      { fields: { severity: 1, isActive: 1 } },
      { fields: { firstSeen: -1 } },
      { fields: { lastSeen: -1 } },
      { fields: { campaignId: 1 } },
      { fields: { tags: 1 } }
    ]
  }
);