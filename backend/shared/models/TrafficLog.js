import { createModel, phoneValidator, objectId } from "./base.js";

export default createModel(
  "TrafficLog",
  {
    phoneNumber: { type: String, required: true, index: true },
    calledNumber: { type: String, required: true, index: true },
    direction: { type: String, enum: ["inbound", "outbound"], required: true },
    callType: { type: String, enum: ["voice", "video", "data"], required: true },
    duration: { type: Number, default: 0 },
    startTime: { type: Date, required: true, index: true },
    endTime: { type: Date },
    cellTower: { type: String },
    location: {
      district: { type: String, index: true },
      state: { type: String, index: true },
      coordinates: {
        type: { type: String, enum: ["Point"] },
        coordinates: { type: [Number] }
      }
    },
    deviceId: { type: String, index: true },
    imsi: { type: String },
    imei: { type: String },
    ispId: { type: objectId, ref: "IspOperator", index: true },
    carrier: { type: String },
    riskScore: { type: Number, min: 0, max: 100, default: 0 },
    isFlagged: { type: Boolean, default: false, index: true },
    flagReason: { type: String },
    fraudIndicators: [{ type: String }],
    metadata: {
      networkType: String,
      signalStrength: Number,
      roaming: Boolean
    }
  },
  {
    collection: "traffic_logs",
    indexes: [
      { fields: { phoneNumber: 1, startTime: -1 } },
      { fields: { calledNumber: 1, startTime: -1 } },
      { fields: { startTime: -1 } },
      { fields: { isFlagged: 1, riskScore: -1 } },
      { fields: { "location.district": 1, "location.state": 1 } },
      { fields: { deviceId: 1 } },
      { fields: { ispId: 1, startTime: -1 } }
    ]
  }
);