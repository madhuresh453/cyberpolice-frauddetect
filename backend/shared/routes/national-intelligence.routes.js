/**
 * RAKSAAR (CyberShield AI) - National Fraud Intelligence (Phase 15)
 * Fraud Number/UPI/Domain/Wallet databases, Threat Feed, Heatmap, Trending Scams
 */
import { Router } from "express";
import mongoose from "mongoose";
import { authenticateJWT, requireRole } from "../middlewares/auth.middleware.js";
import { getFraudNetwork, getFraudClusters, getRepeatOffenders } from "../services/neo4j-graph.service.js";

const router = Router();

// ===== FRAUD DATABASE SEARCH =====

router.get("/fraud-numbers", authenticateJWT, requireRole("police", "admin", "super_admin"), async (req, res, next) => {
  try {
    const { search, page = 1, limit = 50, minRisk } = req.query;
    const filter = {};
    if (search) filter.phoneNumber = { $regex: search.replace(/\D/g, ""), $options: "i" };
    if (minRisk) filter.riskScore = { $gte: parseInt(minRisk) };

    const [data, total] = await Promise.all([
      mongoose.models.FraudNumber.find(filter).sort({ riskScore: -1 }).skip((page - 1) * limit).limit(parseInt(limit)).lean(),
      mongoose.models.FraudNumber.countDocuments(filter),
    ]);

    res.json({ success: true, data, pagination: { page, limit, total, pages: Math.ceil(total / limit) } });
  } catch (error) { next(error); }
});

router.get("/fraud-upis", authenticateJWT, requireRole("police", "admin", "super_admin"), async (req, res, next) => {
  try {
    const { search, page = 1, limit = 50, minRisk } = req.query;
    const filter = {};
    if (search) filter.upiId = { $regex: search, $options: "i" };
    if (minRisk) filter.riskScore = { $gte: parseInt(minRisk) };

    const [data, total] = await Promise.all([
      mongoose.models.FraudUpiId.find(filter).sort({ riskScore: -1 }).skip((page - 1) * limit).limit(parseInt(limit)).lean(),
      mongoose.models.FraudUpiId.countDocuments(filter),
    ]);

    res.json({ success: true, data, pagination: { page, limit, total, pages: Math.ceil(total / limit) } });
  } catch (error) { next(error); }
});

router.get("/fraud-domains", authenticateJWT, requireRole("police", "admin", "super_admin"), async (req, res, next) => {
  try {
    const { search, page = 1, limit = 50 } = req.query;
    const filter = {};
    if (search) filter.url = { $regex: search, $options: "i" };

    const [data, total] = await Promise.all([
      mongoose.models.FraudWebsite.find(filter).sort({ riskScore: -1 }).skip((page - 1) * limit).limit(parseInt(limit)).lean(),
      mongoose.models.FraudWebsite.countDocuments(filter),
    ]);

    res.json({ success: true, data, pagination: { page, limit, total, pages: Math.ceil(total / limit) } });
  } catch (error) { next(error); }
});

// ===== NATIONAL HEATMAP =====

router.get("/heatmap", authenticateJWT, async (req, res, next) => {
  try {
    const { district, state, fraud_type, days = 30 } = req.query;
    const dateFilter = { createdAt: { $gte: new Date(Date.now() - parseInt(days) * 86400000) } };
    const filter = { ...dateFilter };
    if (district) filter.district = district;
    if (state) filter.state = state;
    if (fraud_type) filter.reportType = fraud_type;

    const [heatmapData, topDistricts, fraudByType, dailyTrend] = await Promise.all([
      mongoose.models.HeatmapData.find(filter).sort({ count: -1 }).limit(500).lean(),
      mongoose.models.FraudReport.aggregate([
        { $match: dateFilter },
        { $group: { _id: "$district", count: { $sum: 1 }, avgRisk: { $avg: "$riskScore" } } },
        { $sort: { count: -1 } },
        { $limit: 20 },
      ]),
      mongoose.models.FraudReport.aggregate([
        { $match: dateFilter },
        { $group: { _id: "$reportType", count: { $sum: 1 } } },
        { $sort: { count: -1 } },
      ]),
      mongoose.models.FraudReport.aggregate([
        { $match: dateFilter },
        { $group: { _id: { $dateToString: { format: "%Y-%m-%d", date: "$createdAt" } }, count: { $sum: 1 } } },
        { $sort: { _id: 1 } },
        { $limit: 90 },
      ]),
    ]);

    res.json({
      success: true,
      data: {
        heatmap: heatmapData.map(h => ({
          district: h.district, state: h.state,
          lat: h.coordinates?.lat, lng: h.coordinates?.lng,
          count: h.count, risk: h.riskScore,
        })),
        topDistricts: topDistricts.map(d => ({ district: d._id, count: d.count, avgRisk: Math.round(d.avgRisk || 0) })),
        fraudByType: fraudByType.map(f => ({ type: f._id, count: f.count })),
        dailyTrend: dailyTrend.map(d => ({ date: d._id, count: d.count })),
        period: `${days}d`,
      },
    });
  } catch (error) { next(error); }
});

// ===== TRENDING SCAMS =====

router.get("/trending", authenticateJWT, async (req, res, next) => {
  try {
    const sevenDaysAgo = new Date(Date.now() - 7 * 86400000);
    const thirtyDaysAgo = new Date(Date.now() - 30 * 86400000);

    const [recentScams, topScamTypes, topNumbers, repeatOffenders] = await Promise.all([
      mongoose.models.FraudReport.find({ createdAt: { $gte: sevenDaysAgo } })
        .sort({ createdAt: -1 }).limit(20).lean(),
      mongoose.models.FraudReport.aggregate([
        { $match: { createdAt: { $gte: sevenDaysAgo } } },
        { $group: { _id: "$reportType", count: { $sum: 1 } } },
        { $sort: { count: -1 } },
      ]),
      mongoose.models.FraudNumber.find().sort({ riskScore: -1 }).limit(10).lean(),
      getRepeatOffenders(3),
    ]);

    res.json({
      success: true,
      data: {
        recentScams: recentScams.map(r => ({ id: r._id, type: r.reportType, risk: r.riskScore, date: r.createdAt })),
        trendingTypes: topScamTypes.map(t => ({ type: t._id, count: t.count })),
        topFraudNumbers: topNumbers.map(n => ({ phone: n.phoneNumber, risk: n.riskScore, reports: n.reportsCount })),
        repeatOffenders: repeatOffenders.offenders || [],
      },
    });
  } catch (error) { next(error); }
});

// ===== GRAPH NETWORK ENDPOINTS =====

router.get("/network/:phoneNumber", authenticateJWT, requireRole("police", "admin"), async (req, res, next) => {
  try {
    const { phoneNumber } = req.params;
    const depth = parseInt(req.query.depth) || 2;
    const network = await getFraudNetwork(phoneNumber, depth);
    res.json({ success: true, data: network });
  } catch (error) { next(error); }
});

router.get("/clusters", authenticateJWT, requireRole("police", "admin"), async (req, res, next) => {
  try {
    const minSize = parseInt(req.query.minSize) || 3;
    const clusters = await getFraudClusters(minSize);
    res.json({ success: true, data: clusters });
  } catch (error) { next(error); }
});

router.get("/offenders", authenticateJWT, requireRole("police", "admin"), async (req, res, next) => {
  try {
    const minReports = parseInt(req.query.minReports) || 3;
    const offenders = await getRepeatOffenders(minReports);
    res.json({ success: true, data: offenders });
  } catch (error) { next(error); }
});

export default router;