import { Router } from "express";
import mongoose from "mongoose";
import { authenticateJWT, requireRole } from "../middlewares/auth.middleware.js";

const router = Router();

// GET /national-dashboard - National level fraud analytics
router.get("/national-dashboard", authenticateJWT, requireRole("admin"), async (req, res, next) => {
  try {
    const days = parseInt(req.query.days) || 30;
    const dateFilter = { createdAt: { $gte: new Date(Date.now() - days * 86400000) } };

    const [
      totalReports, totalCases, totalFirs, totalFreezeRequests,
      fraudByState, fraudByType, reportTrend, topFraudNumbers,
      totalCitizens, activeOfficers, totalIspOperators
    ] = await Promise.all([
      mongoose.models.FraudReport.countDocuments(dateFilter),
      mongoose.models.Case.countDocuments(dateFilter),
      mongoose.models.FIR.countDocuments(dateFilter),
      mongoose.models.FreezeRequest.countDocuments(dateFilter),
      mongoose.models.FraudReport.aggregate([
        { $match: dateFilter },
        { $lookup: { from: "citizens", localField: "userId", foreignField: "userId", as: "citizen" } },
        { $unwind: { path: "$citizen", preserveNullAndEmptyArrays: true } },
        { $group: { _id: "$citizen.address.state", count: { $sum: 1 } } },
        { $sort: { count: -1 } }
      ]),
      mongoose.models.FraudReport.aggregate([
        { $match: dateFilter },
        { $group: { _id: "$reportType", count: { $sum: 1 } } },
        { $sort: { count: -1 } }
      ]),
      mongoose.models.FraudReport.aggregate([
        { $match: dateFilter },
        { $group: { _id: { $dateToString: { format: "%Y-%m-%d", date: "$createdAt" } }, count: { $sum: 1 } } },
        { $sort: { _id: 1 } },
        { $limit: 30 }
      ]),
      mongoose.models.FraudNumber.find().sort({ riskScore: -1 }).limit(10).lean(),
      mongoose.models.Citizen.countDocuments({ accountStatus: "active" }),
      mongoose.models.PoliceOfficer.countDocuments({ status: "active" }),
      mongoose.models.IspOperator.countDocuments({ status: "active" })
    ]);

    const stateNames = ["Andhra Pradesh", "Arunachal Pradesh", "Assam", "Bihar", "Chhattisgarh", "Goa", "Gujarat", "Haryana", "Himachal Pradesh", "Jharkhand", "Karnataka", "Kerala", "Madhya Pradesh", "Maharashtra", "Manipur", "Meghalaya", "Mizoram", "Nagaland", "Odisha", "Punjab", "Rajasthan", "Sikkim", "Tamil Nadu", "Telangana", "Tripura", "Uttar Pradesh", "Uttarakhand", "West Bengal"];

    res.json({
      period: `${days}d`,
      national_summary: {
        total_reports: totalReports,
        total_cases: totalCases,
        total_firs: totalFirs,
        total_freeze_requests: totalFreezeRequests,
        total_citizens: totalCitizens,
        active_officers: activeOfficers,
        active_isps: totalIspOperators,
        resolution_rate: totalCases > 0 ? Math.round((await mongoose.models.Case.countDocuments({ status: { $in: ["closed", "resolved"] } }) / totalCases) * 100) : 0
      },
      fraud_by_state: stateNames.map(state => ({
        state,
        count: fraudByState.find(f => f._id === state)?.count || 0,
        percentage: totalReports > 0 ? Math.round(((fraudByState.find(f => f._id === state)?.count || 0) / totalReports) * 100) : 0
      })).filter(s => s.count > 0).sort((a, b) => b.count - a.count),
      fraud_by_type: fraudByType.map(f => ({ type: f._id, count: f.count })),
      daily_trend: reportTrend.map(d => ({ date: d._id, count: d.count })),
      top_fraud_numbers: topFraudNumbers.map(f => ({
        phone: f.phoneNumber, risk_score: f.riskScore, reports: f.reportCount
      })),
      fraud_impact: {
        estimated_loss: totalReports * 15000,
        affected_citizens: totalCitizens > 0 ? Math.round((totalReports / totalCitizens) * 10000) / 100 : 0
      }
    });
  } catch (error) { next(error); }
});

// GET /state-dashboard - State level fraud analytics
router.get("/state-dashboard", authenticateJWT, requireRole("admin"), async (req, res, next) => {
  try {
    const { state } = req.query;
    if (!state) return res.status(400).json({ error: "VALIDATION_ERROR", message: "State parameter required" });

    const days = parseInt(req.query.days) || 30;
    const dateFilter = { createdAt: { $gte: new Date(Date.now() - days * 86400000) } };
    const stateFilter = { ...dateFilter, state };

    const [totalCases, totalFirs, openCases, fraudByDistrict, fraudByType, dailyStats, citizenStats] = await Promise.all([
      mongoose.models.Case.countDocuments(stateFilter),
      mongoose.models.FIR.countDocuments(stateFilter),
      mongoose.models.Case.countDocuments({ ...stateFilter, status: "open" }),
      mongoose.models.Case.aggregate([
        { $match: stateFilter },
        { $group: { _id: "$district", count: { $sum: 1 }, openCount: { $sum: { $cond: [{ $eq: ["$status", "open"] }, 1, 0] } } } },
        { $sort: { count: -1 } }
      ]),
      mongoose.models.Case.aggregate([
        { $match: stateFilter },
        { $group: { _id: "$caseType", count: { $sum: 1 } } },
        { $sort: { count: -1 } }
      ]),
      mongoose.models.Case.aggregate([
        { $match: stateFilter },
        { $group: { _id: { $dateToString: { format: "%Y-%m-%d", date: "$createdAt" } }, count: { $sum: 1 } } },
        { $sort: { _id: 1 } },
        { $limit: 30 }
      ]),
      mongoose.models.Citizen.countDocuments({ "address.state": state, accountStatus: "active" })
    ]);

    res.json({
      state,
      period: `${days}d`,
      summary: {
        total_cases: totalCases,
        total_firs: totalFirs,
        open_cases: openCases,
        active_citizens: citizenStats,
        resolution_rate: totalCases > 0 ? Math.round(((totalCases - openCases) / totalCases) * 100) : 0
      },
      fraud_by_district: fraudByDistrict.map(d => ({
        district: d._id, count: d.count, open_cases: d.openCount
      })),
      fraud_by_type: fraudByType.map(f => ({ type: f._id, count: f.count })),
      daily_trend: dailyStats.map(d => ({ date: d._id, count: d.count }))
    });
  } catch (error) { next(error); }
});

// GET /district-dashboard - District level fraud analytics
router.get("/district-dashboard", authenticateJWT, requireRole("admin"), async (req, res, next) => {
  try {
    const { state, district } = req.query;
    if (!state || !district) {
      return res.status(400).json({ error: "VALIDATION_ERROR", message: "State and district parameters required" });
    }

    const days = parseInt(req.query.days) || 30;
    const dateFilter = { createdAt: { $gte: new Date(Date.now() - days * 86400000) } };
    const locationFilter = { ...dateFilter, state, district };

    const [cases, firs, fraudNumbers, activeOfficers, citizenCount, evidenceCount, heatmapData] = await Promise.all([
      mongoose.models.Case.find(locationFilter).sort({ createdAt: -1 }).limit(50).lean(),
      mongoose.models.FIR.find(locationFilter).sort({ createdAt: -1 }).limit(50).lean(),
      mongoose.models.FraudNumber.countDocuments({ district, state }),
      mongoose.models.PoliceOfficer.countDocuments({ district, state, status: "active" }),
      mongoose.models.Citizen.countDocuments({ "address.district": district, "address.state": state, accountStatus: "active" }),
      mongoose.models.EvidenceFile.aggregate([
        { $lookup: { from: "cases", localField: "caseId", foreignField: "_id", as: "caseInfo" } },
        { $unwind: { path: "$caseInfo", preserveNullAndEmptyArrays: true } },
        { $match: { "caseInfo.district": district, "caseInfo.state": state } },
        { $count: "total" }
      ]),
      mongoose.models.HeatmapData.findOne({ district, state }).lean()
    ]);

    res.json({
      state, district,
      period: `${days}d`,
      summary: {
        total_cases: cases.length,
        total_firs: firs.length,
        known_fraud_numbers: fraudNumbers,
        active_officers: activeOfficers,
        active_citizens: citizenCount,
        evidence_files: evidenceCount[0]?.total || 0,
        risk_score: heatmapData?.riskScore || 0
      },
      recent_cases: cases.slice(0, 10).map(c => ({
        id: c._id, title: c.title, status: c.status, priority: c.priority, created_at: c.createdAt
      })),
      recent_firs: firs.slice(0, 10).map(f => ({
        id: f._id, fir_number: f.firNumber, complainant: f.complainantName, status: f.status
      }))
    });
  } catch (error) { next(error); }
});

// GET /fraud-trends - Get fraud trend analysis
router.get("/fraud-trends", authenticateJWT, requireRole("admin"), async (req, res, next) => {
  try {
    const days = parseInt(req.query.days) || 90;
    const { state, type } = req.query;
    const dateFilter = { createdAt: { $gte: new Date(Date.now() - days * 86400000) } };
    if (state) dateFilter.state = state;
    if (type) dateFilter.reportType = type;

    const [weeklyTrends, monthlyTrends, typeTrends, stateTrends, growthRate] = await Promise.all([
      mongoose.models.FraudReport.aggregate([
        { $match: dateFilter },
        { $group: { _id: { week: { $isoWeek: "$createdAt" }, year: { $isoWeekYear: "$createdAt" } }, count: { $sum: 1 } } },
        { $sort: { "_id.year": 1, "_id.week": 1 } },
        { $limit: 52 }
      ]),
      mongoose.models.FraudReport.aggregate([
        { $match: dateFilter },
        { $group: { _id: { $dateToString: { format: "%Y-%m", date: "$createdAt" } }, count: { $sum: 1 } } },
        { $sort: { _id: 1 } }
      ]),
      mongoose.models.FraudReport.aggregate([
        { $match: dateFilter },
        { $group: { _id: "$reportType", count: { $sum: 1 }, change: { $sum: 1 } } },
        { $sort: { count: -1 } }
      ]),
      mongoose.models.FraudReport.aggregate([
        { $match: dateFilter },
        { $lookup: { from: "citizens", localField: "userId", foreignField: "userId", as: "citizen" } },
        { $unwind: { path: "$citizen", preserveNullAndEmptyArrays: true } },
        { $group: { _id: "$citizen.address.state", count: { $sum: 1 } } },
        { $sort: { count: -1 } },
        { $limit: 10 }
      ]),
      mongoose.models.FraudReport.aggregate([
        { $match: { createdAt: { $gte: new Date(Date.now() - 7 * 86400000) } } },
        { $group: { _id: null, count: { $sum: 1 } } }
      ])
    ]);

    const previousWeekCount = await mongoose.models.FraudReport.countDocuments({
      createdAt: { $gte: new Date(Date.now() - 14 * 86400000), $lt: new Date(Date.now() - 7 * 86400000) }
    });

    res.json({
      period: `${days}d`,
      trends: {
        weekly: weeklyTrends.map(w => ({ week: w._id.week, year: w._id.year, count: w.count })),
        monthly: monthlyTrends.map(m => ({ month: m._id, count: m.count })),
        by_type: typeTrends.map(t => ({ type: t._id, count: t.count })),
        by_state: stateTrends.map(s => ({ state: s._id, count: s.count }))
      },
      growth: {
        current_week: growthRate[0]?.count || 0,
        previous_week: previousWeekCount,
        week_over_week_change: previousWeekCount > 0 ? Math.round(((growthRate[0]?.count || 0) - previousWeekCount) / previousWeekCount * 100) : 0,
        projected_next_week: Math.round((growthRate[0]?.count || 0) * 1.1)
      }
    });
  } catch (error) { next(error); }
});

// GET /economic-impact - Calculate economic impact of fraud
router.get("/economic-impact", authenticateJWT, requireRole("admin"), async (req, res, next) => {
  try {
    const days = parseInt(req.query.days) || 365;
    const dateFilter = { createdAt: { $gte: new Date(Date.now() - days * 86400000) } };

    const [totalReports, freezeRequests, totalCases, fraudNumbers, monthlyLoss] = await Promise.all([
      mongoose.models.FraudReport.countDocuments(dateFilter),
      mongoose.models.FreezeRequest.find(dateFilter).lean(),
      mongoose.models.Case.countDocuments(dateFilter),
      mongoose.models.FraudNumber.countDocuments(),
      mongoose.models.FraudReport.aggregate([
        { $match: dateFilter },
        { $group: { _id: { $dateToString: { format: "%Y-%m", date: "$createdAt" } }, count: { $sum: 1 } } },
        { $sort: { _id: 1 } }
      ])
    ]);

    const avgLossPerReport = 15000;
    const totalEstimatedLoss = totalReports * avgLossPerReport;
    const preventedLoss = freezeRequests.length * 50000;
    const recoveryRate = 0.12;

    res.json({
      period: `${days}d`,
      economic_impact: {
        total_estimated_loss: totalEstimatedLoss,
        prevented_loss: preventedLoss,
        net_impact: totalEstimatedLoss - preventedLoss,
        recovery_amount: Math.round(totalEstimatedLoss * recoveryRate),
        recovery_rate: recoveryRate
      },
      monthly_breakdown: monthlyLoss.map(m => ({
        month: m._id,
        reports: m.count,
        estimated_loss: m.count * avgLossPerReport
      })),
      statistics: {
        total_reports: totalReports,
        total_cases: totalCases,
        freeze_requests_processed: freezeRequests.filter(f => f.status !== "pending").length,
        known_fraud_numbers: fraudNumbers,
        average_loss_per_report: avgLossPerReport,
        cost_per_citizen: Math.round(totalEstimatedLoss / Math.max(1, totalReports))
      },
      impact_by_state: await mongoose.models.FraudReport.aggregate([
        { $match: { ...dateFilter, state: { $exists: true, $ne: null } } },
        { $group: { _id: "$state", count: { $sum: 1 }, estimated_loss: { $sum: avgLossPerReport } } },
        { $sort: { count: -1 } },
        { $limit: 10 }
      ]).then(results => results.map(r => ({ state: r._id, count: r.count, estimated_loss: r.estimated_loss })))
    });
  } catch (error) { next(error); }
});

export default router;