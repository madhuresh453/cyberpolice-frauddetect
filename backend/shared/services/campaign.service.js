import mongoose from "mongoose";

export async function detectCampaigns() {
  try {
    const now = new Date();
    const twentyFourHoursAgo = new Date(now.getTime() - 24 * 60 * 60 * 1000);
    const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);

    // Detect mass SMS attacks (same message body sent to multiple numbers)
    const smsCampaigns = await mongoose.models.SmsLog.aggregate([
      { $match: { receivedAt: { $gte: twentyFourHoursAgo } } },
      { $group: { _id: { from: "$fromNumber", body: { $substrCP: ["$messageBody", 0, 100] } }, count: { $sum: 1 }, numbers: { $addToSet: "$toNumber" }, riskScores: { $push: "$riskScore" } } },
      { $match: { count: { $gte: 5 } } },
      { $sort: { count: -1 } },
      { $limit: 20 }
    ]);

    // Detect mass call attacks
    const callCampaigns = await mongoose.models.TrafficLog.aggregate([
      { $match: { timestamp: { $gte: twentyFourHoursAgo } } },
      { $group: { _id: "$fromNumber", count: { $sum: 1 }, targets: { $addToSet: "$toNumber" }, totalDuration: { $sum: "$duration" } } },
      { $match: { count: { $gte: 10 } } },
      { $sort: { count: -1 } },
      { $limit: 20 }
    ]);

    // Detect WhatsApp mass attacks
    const whatsappCampaigns = await mongoose.models.WhatsappAnalysis.aggregate([
      { $match: { receivedAt: { $gte: twentyFourHoursAgo } } },
      { $group: { _id: { from: "$senderNumber", body: { $substrCP: ["$messageBody", 0, 100] } }, count: { $sum: 1 } } },
      { $match: { count: { $gte: 5 } } },
      { $sort: { count: -1 } },
      { $limit: 20 }
    ]);

    // Detect shared UPI targets
    const upiCampaigns = await mongoose.models.FraudUpiId.aggregate([
      { $match: { updatedAt: { $gte: weekAgo }, reportCount: { $gte: 3 } } },
      { $sort: { reportCount: -1 } },
      { $limit: 20 }
    ]);

    // Detect shared device campaigns
    const deviceCampaigns = await mongoose.models.CallAnalysis.aggregate([
      { $match: { createdAt: { $gte: weekAgo } } },
      { $group: { _id: "$deviceId", numbers: { $addToSet: "$callerNumber" }, count: { $sum: 1 } } },
      { $match: { count: { $gte: 3 } } },
      { $sort: { count: -1 } },
      { $limit: 20 }
    ]);

    // Process and save detected campaigns
    const campaigns = [];

    // Save SMS campaigns
    for (const sms of smsCampaigns) {
      const riskScore = Math.min(100, sms.count * 5 + (sms.riskScores?.reduce((a, b) => a + (b || 0), 0) / sms.riskScores.length || 0) * 0.5);
      const campaign = await mongoose.models.CampaignDetection.findOneAndUpdate(
        { campaignType: "sms", "source.phoneNumber": sms._id.from, "source.messagePattern": sms._id.body },
        {
          campaignName: `Mass SMS Attack - ${sms._id.from}`,
          campaignType: "sms",
          source: { phoneNumber: sms._id.from, messagePattern: sms._id.body },
          riskScore: Math.round(riskScore),
          severity: riskScore > 75 ? "critical" : riskScore > 50 ? "high" : "medium",
          affectedCount: sms.count,
          affectedNumbers: sms.numbers,
          detectedAt: now,
          status: "active",
          updatedAt: now
        },
        { upsert: true, new: true }
      );
      campaigns.push(campaign);
    }

    // Save call campaigns
    for (const call of callCampaigns) {
      const riskScore = Math.min(100, call.count * 3 + Math.min(call.totalDuration / 60, 30));
      const campaign = await mongoose.models.CampaignDetection.findOneAndUpdate(
        { campaignType: "call", "source.phoneNumber": call._id },
        {
          campaignName: `Mass Call Attack - ${call._id}`,
          campaignType: "call",
          source: { phoneNumber: call._id },
          riskScore: Math.round(riskScore),
          severity: riskScore > 75 ? "critical" : riskScore > 50 ? "high" : "medium",
          affectedCount: call.targets.length,
          affectedNumbers: call.targets,
          totalDuration: call.totalDuration,
          detectedAt: now,
          status: "active",
          updatedAt: now
        },
        { upsert: true, new: true }
      );
      campaigns.push(campaign);
    }

    // Save WhatsApp campaigns
    for (const wa of whatsappCampaigns) {
      const riskScore = Math.min(100, wa.count * 5);
      const campaign = await mongoose.models.CampaignDetection.findOneAndUpdate(
        { campaignType: "whatsapp", "source.phoneNumber": wa._id.from },
        {
          campaignName: `Mass WhatsApp Attack - ${wa._id.from}`,
          campaignType: "whatsapp",
          source: { phoneNumber: wa._id.from, messagePattern: wa._id.body },
          riskScore: Math.round(riskScore),
          severity: riskScore > 75 ? "critical" : riskScore > 50 ? "high" : "medium",
          affectedCount: wa.count,
          detectedAt: now,
          status: "active",
          updatedAt: now
        },
        { upsert: true, new: true }
      );
      campaigns.push(campaign);
    }

    // Save UPI campaigns
    for (const upi of upiCampaigns) {
      const riskScore = Math.min(100, upi.reportCount * 10 + (upi.riskScore || 0) * 0.3);
      const campaign = await mongoose.models.CampaignDetection.findOneAndUpdate(
        { campaignType: "upi", "source.upiId": upi.upiId },
        {
          campaignName: `UPI Fraud Campaign - ${upi.upiId}`,
          campaignType: "upi",
          source: { upiId: upi.upiId, bankName: upi.bankName },
          riskScore: Math.round(riskScore),
          severity: riskScore > 75 ? "critical" : riskScore > 50 ? "high" : "medium",
          affectedCount: upi.reportCount,
          detectedAt: now,
          status: "active",
          updatedAt: now
        },
        { upsert: true, new: true }
      );
      campaigns.push(campaign);
    }

    // Update affected states and districts for campaigns
    for (const campaign of campaigns) {
      if (campaign.affectedNumbers?.length > 0) {
        const locationData = await mongoose.models.Citizen.aggregate([
          { $match: { phoneNumber: { $in: campaign.affectedNumbers.slice(0, 100) } } },
          { $group: { _id: { state: "$address.state", district: "$address.district" }, count: { $sum: 1 } } },
          { $sort: { count: -1 } }
        ]);

        const affectedStates = [...new Set(locationData.map(l => l._id.state).filter(Boolean))];
        const affectedDistricts = [...new Set(locationData.map(l => l._id.district).filter(Boolean))];

        await mongoose.models.CampaignDetection.findByIdAndUpdate(campaign._id, {
          affectedStates: affectedStates.slice(0, 10),
          affectedDistricts: affectedDistricts.slice(0, 20)
        });
      }
    }

    return {
      campaigns_detected: campaigns.length,
      details: {
        sms_campaigns: smsCampaigns.length,
        call_campaigns: callCampaigns.length,
        whatsapp_campaigns: whatsappCampaigns.length,
        upi_campaigns: upiCampaigns.length,
        device_campaigns: deviceCampaigns.length
      }
    };
  } catch (error) {
    console.error(JSON.stringify({ level: "error", message: "Campaign detection failed", error: error.message }));
    return { campaigns_detected: 0, error: error.message };
  }
}

export async function getActiveCampaigns(filter = {}) {
  const page = parseInt(filter.page) || 1;
  const limit = parseInt(filter.limit) || 20;
  const skip = (page - 1) * limit;

  const query = { status: "active" };
  if (filter.type) query.campaignType = filter.type;
  if (filter.severity) query.severity = filter.severity;
  if (filter.minRisk) query.riskScore = { $gte: parseInt(filter.minRisk) };

  const [campaigns, total] = await Promise.all([
    mongoose.models.CampaignDetection.find(query)
      .sort({ riskScore: -1, detectedAt: -1 })
      .skip(skip).limit(limit).lean(),
    mongoose.models.CampaignDetection.countDocuments(query)
  ]);

  return {
    data: campaigns.map(c => ({
      id: c._id,
      name: c.campaignName,
      type: c.campaignType,
      risk_score: c.riskScore,
      severity: c.severity,
      affected_count: c.affectedCount,
      affected_states: c.affectedStates || [],
      affected_districts: c.affectedDistricts || [],
      source: c.source,
      detected_at: c.detectedAt,
      status: c.status
    })),
    pagination: { page, limit, total, pages: Math.ceil(total / limit) },
    summary: {
      critical: await mongoose.models.CampaignDetection.countDocuments({ ...query, severity: "critical" }),
      high: await mongoose.models.CampaignDetection.countDocuments({ ...query, severity: "high" }),
      medium: await mongoose.models.CampaignDetection.countDocuments({ ...query, severity: "medium" })
    }
  };
}

export async function getCampaignTimeline(campaignId, hours = 48) {
  const campaign = await mongoose.models.CampaignDetection.findById(campaignId).lean();
  if (!campaign) return { error: "Campaign not found" };

  const since = new Date(Date.now() - hours * 3600000);
  const timeline = [];

  if (campaign.campaignType === "sms" || campaign.campaignType === "whatsapp") {
    const model = campaign.campaignType === "sms" ? mongoose.models.SmsLog : mongoose.models.WhatsappAnalysis;
    const numberField = campaign.campaignType === "sms" ? "fromNumber" : "senderNumber";
    const timeField = campaign.campaignType === "sms" ? "receivedAt" : "receivedAt";

    const data = await model.aggregate([
      { $match: { [numberField]: campaign.source?.phoneNumber, [timeField]: { $gte: since } } },
      { $group: { _id: { $dateToString: { format: "%Y-%m-%d %H:00", date: `$${timeField}` } }, count: { $sum: 1 } } },
      { $sort: { _id: 1 } }
    ]);
    timeline.push(...data.map(d => ({ time: d._id, count: d.count, type: campaign.campaignType })));
  }

  if (campaign.campaignType === "call") {
    const data = await mongoose.models.TrafficLog.aggregate([
      { $match: { fromNumber: campaign.source?.phoneNumber, timestamp: { $gte: since } } },
      { $group: { _id: { $dateToString: { format: "%Y-%m-%d %H:00", date: "$timestamp" } }, count: { $sum: 1 } } },
      { $sort: { _id: 1 } }
    ]);
    timeline.push(...data.map(d => ({ time: d._id, count: d.count, type: "call" })));
  }

  return {
    campaign: {
      id: campaign._id,
      name: campaign.campaignName,
      type: campaign.campaignType,
      severity: campaign.severity,
      risk_score: campaign.riskScore
    },
    timeline,
    period_hours: hours
  };
}

export async function getThreatActorAnalysis() {
  const weekAgo = new Date(Date.now() - 7 * 86400000);

  const topSources = await mongoose.models.CampaignDetection.aggregate([
    { $match: { detectedAt: { $gte: weekAgo }, status: "active" } },
    { $group: { _id: "$campaignType", count: { $sum: 1 }, totalAffected: { $sum: "$affectedCount" }, avgRisk: { $avg: "$riskScore" } } },
    { $sort: { totalAffected: -1 } }
  ]);

  const topNumbers = await mongoose.models.FraudReport.aggregate([
    { $match: { createdAt: { $gte: weekAgo } } },
    { $group: { _id: "$metadata.phoneNumber", count: { $sum: 1 } } },
    { $match: { count: { $gte: 3 } } },
    { $sort: { count: -1 } },
    { $limit: 20 }
  ]);

  return {
    threat_actors_by_type: topSources.map(s => ({
      type: s._id,
      active_campaigns: s.count,
      total_affected: s.totalAffected,
      average_risk: Math.round(s.avgRisk)
    })),
    top_threat_numbers: topNumbers.map(n => ({
      phone: n._id,
      report_count: n.count
    })),
    analysis_period: "7d"
  };
}

export async function getFraudStatistics() {
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  const [dailyStats, typeBreakdown, stateStats, overallTotals] = await Promise.all([
    mongoose.models.FraudStatistic.aggregate([
      { $match: { date: { $gte: new Date(today.getTime() - 30 * 86400000) } } },
      { $group: { _id: { $dateToString: { format: "%Y-%m-%d", date: "$date" } }, count: { $sum: 1 } } },
      { $sort: { _id: 1 } }
    ]),
    mongoose.models.FraudStatistic.aggregate([
      { $group: { _id: "$fraudType", count: { $sum: "$count" } } },
      { $sort: { count: -1 } }
    ]),
    mongoose.models.HeatmapData.aggregate([
      { $group: { _id: "$state", count: { $sum: "$count" }, avgRisk: { $avg: "$riskScore" } } },
      { $sort: { count: -1 } },
      { $limit: 10 }
    ]),
    mongoose.models.FraudReport.aggregate([
      { $group: { _id: null, total: { $sum: 1 }, byType: { $addToSet: "$reportType" } } }
    ])
  ]);

  return {
    daily_stats: dailyStats.map(d => ({ date: d._id, count: d.count })),
    fraud_type_breakdown: typeBreakdown.map(t => ({ type: t._id, count: t.count })),
    top_affected_states: stateStats.map(s => ({ state: s._id, count: s.count, avg_risk: Math.round(s.avgRisk) })),
    overall: overallTotals[0] ? { total_reports: overallTotals[0].total, types: [...new Set(overallTotals[0].byType)] } : { total_reports: 0, types: [] }
  };
}