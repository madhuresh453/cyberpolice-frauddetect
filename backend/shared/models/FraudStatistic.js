import { createModel, objectId } from "./base.js";

export default createModel(
  "FraudStatistic",
  {
    period: { type: String, enum: ["daily", "weekly", "monthly", "quarterly", "yearly"], required: true, index: true },
    periodStart: { type: Date, required: true, index: true },
    periodEnd: { type: Date, required: true },
    state: { type: String, index: true },
    district: { type: String, index: true },
    summary: {
      totalReports: { type: Number, default: 0 },
      verifiedReports: { type: Number, default: 0 },
      dismissedReports: { type: Number, default: 0 },
      totalCases: { type: Number, default: 0 },
      resolvedCases: { type: Number, default: 0 },
      totalFirs: { type: Number, default: 0 },
      totalFraudNumbers: { type: Number, default: 0 },
      totalFraudUpiIds: { type: Number, default: 0 },
      totalFraudBankAccounts: { type: Number, default: 0 },
      totalFraudWebsites: { type: Number, default: 0 },
      totalFraudApps: { type: Number, default: 0 },
      estimatedTotalLoss: { type: Number, default: 0 },
      totalRecovered: { type: Number, default: 0 },
      totalVictims: { type: Number, default: 0 },
      totalBlockedNumbers: { type: Number, default: 0 },
      totalFrozenAccounts: { type: Number, default: 0 }
    },
    fraudTypeBreakdown: [{
      type: { type: String },
      count: { type: Number },
      loss: { type: Number },
      percentage: { type: Number }
    }],
    channelBreakdown: [{
      channel: { type: String },
      count: { type: Number },
      percentage: { type: Number }
    }],
    topDistricts: [{ district: String, state: String, count: Number, loss: Number }],
    topFraudNumbers: [{ number: String, reports: Number, riskScore: Number }],
    topFraudUpiIds: [{ upiId: String, reports: Number, loss: Number }],
    trend: {
      reportTrend: { type: String, enum: ["increasing", "stable", "decreasing"] },
      lossTrend: { type: String, enum: ["increasing", "stable", "decreasing"] },
      reportChangePercent: { type: Number },
      lossChangePercent: { type: Number }
    },
    calculatedAt: { type: Date, default: Date.now }
  },
  {
    collection: "fraud_statistics",
    indexes: [
      { fields: { period: 1, periodStart: -1, state: 1 } },
      { fields: { state: 1, district: 1, periodStart: -1 } },
      { fields: { periodStart: -1 } }
    ]
  }
);