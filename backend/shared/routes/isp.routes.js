import { Router } from "express";
import mongoose from "mongoose";
import { authenticateJWT, requireRole } from "../middlewares/auth.middleware.js";

const router = Router();

// GET /number-intelligence - Get intelligence data for a phone number
router.get("/number-intelligence", authenticateJWT, requireRole("isp", "admin"), async (req, res, next) => {
  try {
    const { phone_number } = req.query;
    if (!phone_number) {
      return res.status(400).json({ error: "VALIDATION_ERROR", message: "Phone number required" });
    }
    const [fraudNumber, trafficLogs, smsLogs, blockedStatus, reports, trustScore] = await Promise.all([
      mongoose.models.FraudNumber.findOne({ phoneNumber: phone_number }).lean(),
      mongoose.models.TrafficLog.find({ $or: [{ fromNumber: phone_number }, { toNumber: phone_number }] })
        .sort({ timestamp: -1 }).limit(50).lean(),
      mongoose.models.SmsLog.find({ $or: [{ fromNumber: phone_number }, { toNumber: phone_number }] })
        .sort({ receivedAt: -1 }).limit(50).lean(),
      mongoose.models.BlockedNumber.findOne({ phoneNumber: phone_number }).lean(),
      mongoose.models.FraudReport.countDocuments({ "metadata.phoneNumber": phone_number }),
      mongoose.models.TrustScore.findOne({ phoneNumber: phone_number }).lean()
    ]);

    res.json({
      phone_number,
      risk_score: fraudNumber?.riskScore || 0,
      risk_category: fraudNumber?.riskCategory || "unknown",
      fraud_type: fraudNumber?.fraudType || "none",
      is_blocked: !!blockedStatus,
      blocked_reason: blockedStatus?.reason,
      total_reports: reports,
      trust_score: trustScore?.score || 50,
      traffic_volume: trafficLogs.length,
      sms_volume: smsLogs.length,
      last_activity: trafficLogs[0]?.timestamp || smsLogs[0]?.receivedAt || null,
      report_count: fraudNumber?.reportCount || 0,
      first_reported: fraudNumber?.firstReportedAt,
      last_reported: fraudNumber?.lastReportedAt
    });
  } catch (error) { next(error); }
});

// GET /sms-firewall - Get SMS firewall data
router.get("/sms-firewall", authenticateJWT, requireRole("isp", "admin"), async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 50;
    const skip = (page - 1) * limit;
    const { status, classification, from_date, to_date } = req.query;

    const filter = {};
    if (status) filter.status = status;
    if (classification) filter.classification = classification;
    if (from_date || to_date) {
      filter.receivedAt = {};
      if (from_date) filter.receivedAt.$gte = new Date(from_date);
      if (to_date) filter.receivedAt.$lte = new Date(to_date);
    }

    const [logs, total] = await Promise.all([
      mongoose.models.SmsLog.find(filter)
        .sort({ receivedAt: -1 }).skip(skip).limit(limit).lean(),
      mongoose.models.SmsLog.countDocuments(filter)
    ]);

    res.json({
      data: logs.map(l => ({
        id: l._id, from: l.fromNumber, to: l.toNumber,
        message_preview: l.messageBody?.substring(0, 100),
        classification: l.classification, status: l.status,
        risk_score: l.riskScore, received_at: l.receivedAt
      })),
      pagination: { page, limit, total, pages: Math.ceil(total / limit) },
      summary: {
        total_blocked: await mongoose.models.SmsLog.countDocuments({ status: "blocked" }),
        total_suspicious: await mongoose.models.SmsLog.countDocuments({ classification: "suspicious" }),
        total_fraud: await mongoose.models.SmsLog.countDocuments({ classification: "fraud" })
      }
    });
  } catch (error) { next(error); }
});

// GET /traffic-analysis - Get traffic analysis data
router.get("/traffic-analysis", authenticateJWT, requireRole("isp", "admin"), async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 50;
    const skip = (page - 1) * limit;
    const { status, direction, from_date, to_date } = req.query;

    const filter = {};
    if (status) filter.status = status;
    if (direction) filter.direction = direction;
    if (from_date || to_date) {
      filter.timestamp = {};
      if (from_date) filter.timestamp.$gte = new Date(from_date);
      if (to_date) filter.timestamp.$lte = new Date(to_date);
    }

    const [logs, total] = await Promise.all([
      mongoose.models.TrafficLog.find(filter)
        .sort({ timestamp: -1 }).skip(skip).limit(limit).lean(),
      mongoose.models.TrafficLog.countDocuments(filter)
    ]);

    // Aggregations
    const [topCallers, topReceivers, hourlyVolume] = await Promise.all([
      mongoose.models.TrafficLog.aggregate([
        { $group: { _id: "$fromNumber", count: { $sum: 1 }, totalDuration: { $sum: "$duration" } } },
        { $sort: { count: -1 } }, { $limit: 20 }
      ]),
      mongoose.models.TrafficLog.aggregate([
        { $group: { _id: "$toNumber", count: { $sum: 1 } } },
        { $sort: { count: -1 } }, { $limit: 20 }
      ]),
      mongoose.models.TrafficLog.aggregate([
        { $group: { _id: { $hour: "$timestamp" }, count: { $sum: 1 } } },
        { $sort: { _id: 1 } }
      ])
    ]);

    res.json({
      data: logs.map(l => ({
        id: l._id, from: l.fromNumber, to: l.toNumber,
        duration: l.duration, direction: l.direction,
        status: l.status, risk_score: l.riskScore,
        timestamp: l.timestamp
      })),
      pagination: { page, limit, total, pages: Math.ceil(total / limit) },
      analytics: {
        top_callers: topCallers.map(c => ({ number: c._id, count: c.count, total_duration: c.totalDuration })),
        top_receivers: topReceivers.map(r => ({ number: r._id, count: r.count })),
        hourly_volume: hourlyVolume.map(h => ({ hour: h._id, count: h.count }))
      }
    });
  } catch (error) { next(error); }
});

// GET /blocked-numbers - Get blocked numbers list
router.get("/blocked-numbers", authenticateJWT, requireRole("isp", "admin"), async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 50;
    const skip = (page - 1) * limit;
    const { status, reason } = req.query;

    const filter = {};
    if (status) filter.status = status;
    if (reason) filter.reason = { $regex: reason, $options: "i" };

    const [numbers, total] = await Promise.all([
      mongoose.models.BlockedNumber.find(filter)
        .populate("userId", "fullName email")
        .sort({ blockedAt: -1 }).skip(skip).limit(limit).lean(),
      mongoose.models.BlockedNumber.countDocuments(filter)
    ]);

    res.json({
      data: numbers.map(n => ({
        id: n._id, phone_number: n.phoneNumber, reason: n.reason,
        blocked_by: n.userId, blocked_at: n.blockedAt, status: n.status || "active"
      })),
      pagination: { page, limit, total, pages: Math.ceil(total / limit) },
      total_blocked: await mongoose.models.BlockedNumber.countDocuments({ status: "active" })
    });
  } catch (error) { next(error); }
});

// GET /fraud-campaigns - Get detected fraud campaigns
router.get("/fraud-campaigns", authenticateJWT, requireRole("isp", "admin"), async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;
    const { status, severity } = req.query;

    const filter = {};
    if (status) filter.status = status;
    if (severity) filter.severity = severity;

    const [campaigns, total] = await Promise.all([
      mongoose.models.CampaignDetection.find(filter)
        .sort({ riskScore: -1 }).skip(skip).limit(limit).lean(),
      mongoose.models.CampaignDetection.countDocuments(filter)
    ]);

    res.json({
      data: campaigns.map(c => ({
        id: c._id, name: c.campaignName, type: c.campaignType,
        risk_score: c.riskScore, severity: c.severity,
        affected_count: c.affectedCount, affected_states: c.affectedStates,
        affected_districts: c.affectedDistricts, status: c.status,
        started_at: c.startedAt, detected_at: c.detectedAt
      })),
      pagination: { page, limit, total, pages: Math.ceil(total / limit) }
    });
  } catch (error) { next(error); }
});

// GET /threat-feed - Get threat intelligence feed
router.get("/threat-feed", authenticateJWT, requireRole("isp", "admin"), async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 50;
    const skip = (page - 1) * limit;
    const { type, severity, status } = req.query;

    const filter = {};
    if (type) filter.indicatorType = type;
    if (severity) filter.severity = severity;
    if (status) filter.status = status;

    const [indicators, total] = await Promise.all([
      mongoose.models.ThreatIndicator.find(filter)
        .sort({ confidence: -1 }).skip(skip).limit(limit).lean(),
      mongoose.models.ThreatIndicator.countDocuments(filter)
    ]);

    const [recentCampaigns, topIocs] = await Promise.all([
      mongoose.models.ThreatCampaign.find().sort({ detectedAt: -1 }).limit(10).lean(),
      mongoose.models.ThreatIndicator.aggregate([
        { $group: { _id: "$indicatorType", count: { $sum: 1 }, avgConfidence: { $avg: "$confidence" } } },
        { $sort: { count: -1 } }
      ])
    ]);

    res.json({
      data: indicators.map(i => ({
        id: i._id, type: i.indicatorType, value: i.indicatorValue,
        severity: i.severity, confidence: i.confidence,
        source: i.source, status: i.status,
        first_seen: i.firstSeen, last_seen: i.lastSeen
      })),
      pagination: { page, limit, total, pages: Math.ceil(total / limit) },
      summary: {
        active_campaigns: recentCampaigns.map(c => ({
          id: c._id, name: c.campaignName, type: c.campaignType,
          risk_score: c.riskScore, affected: c.affectedCount
        })),
        ioc_breakdown: topIocs.map(i => ({ type: i._id, count: i.count, avg_confidence: Math.round(i.avgConfidence) }))
      }
    });
  } catch (error) { next(error); }
});

export default router;