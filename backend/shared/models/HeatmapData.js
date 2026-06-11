import { createModel, objectId } from "./base.js";

export default createModel(
  "HeatmapData",
  {
    period: { type: String, enum: ["daily", "weekly", "monthly", "quarterly", "yearly"], required: true, index: true },
    periodStart: { type: Date, required: true, index: true },
    periodEnd: { type: Date, required: true },
    state: { type: String, required: true, index: true },
    district: { type: String, index: true },
    city: { type: String },
    coordinates: {
      type: { type: String, enum: ["Point"] },
      coordinates: { type: [Number] }
    },
    metrics: {
      totalReports: { type: Number, default: 0 },
      totalCalls: { type: Number, default: 0 },
      totalSms: { type: Number, default: 0 },
      totalFraud: { type: Number, default: 0 },
      totalVictims: { type: Number, default: 0 },
      estimatedLoss: { type: Number, default: 0 },
      recoveredAmount: { type: Number, default: 0 },
      activeCampaigns: { type: Number, default: 0 },
      blockedNumbers: { type: Number, default: 0 },
      frozenAccounts: { type: Number, default: 0 }
    },
    fraudTypes: [{
      type: { type: String },
      count: { type: Number },
      loss: { type: Number }
    }],
    topFraudNumbers: [{ number: String, reports: Number, riskScore: Number }],
    topFraudUpiIds: [{ upiId: String, reports: Number, loss: Number }],
    trend: { type: String, enum: ["increasing", "stable", "decreasing"], default: "stable" },
    previousPeriodComparison: {
      reportChange: { type: Number },
      lossChange: { type: Number },
      percentageChange: { type: Number }
    },
    calculatedAt: { type: Date, default: Date.now }
  },
  {
    collection: "heatmap_data",
    indexes: [
      { fields: { period: 1, periodStart: -1, state: 1 } },
      { fields: { state: 1, district: 1, periodStart: -1 } },
      { fields: { periodStart: -1 } },
      { fields: { coordinates: "2dsphere" } },
      { fields: { "metrics.totalReports": -1 } }
    ]
  }
);