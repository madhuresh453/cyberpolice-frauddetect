import { Router } from "express";
import mongoose from "mongoose";
import {
  Report, CallLog, SmsLog, Threat, Transaction,
  FamilyMember, Evidence, Notification, TrainingModule,
} from "./citizen.service.js";
import { calculateRiskScore, analyzeUrl, analyzeText } from "./risk-scoring.service.js";

const router = Router();

// ===== MIDDLEWARE =====
const authenticateJWT = (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({ success: false, error: "AUTH_REQUIRED", message: "Bearer token required" });
  }
  // In production, verify JWT token
  req.user = { sub: req.headers["x-user-id"] || "test-user-id" };
  next();
};

router.use(authenticateJWT);

// ===== DASHBOARD =====
router.get("/dashboard", async (req, res, next) => {
  try {
    const userId = req.user.sub;

    const [
      reportCount,
      safeCallCount,
      fraudCallCount,
      smsCount,
      familyCount,
      recentThreats,
      recentReports,
      notifications,
    ] = await Promise.all([
      Report.countDocuments({ userId }),
      CallLog.countDocuments({ userId, status: "safe" }),
      CallLog.countDocuments({ userId, isFraud: true }),
      SmsLog.countDocuments({ userId }),
      FamilyMember.countDocuments({ userId, status: "active" }),
      Threat.find({ userId }).sort({ createdAt: -1 }).limit(5).lean(),
      Report.find({ userId }).sort({ createdAt: -1 }).limit(5).lean(),
      Notification.find({ userId, read: false }).sort({ createdAt: -1 }).limit(10).lean(),
    ]);

    res.json({
      success: true,
      stats: {
        reportsTotal: reportCount,
        callsScanned: safeCallCount + fraudCallCount,
        callsSafe: safeCallCount,
        callsFraud: fraudCallCount,
        smsScanned: smsCount,
        familyProtected: familyCount,
      },
      threats: recentThreats,
      reports: recentReports,
      notifications,
    });
  } catch (error) {
    next(error);
  }
});

// ===== CALL PROTECTION =====
router.post("/call/analyze", async (req, res, next) => {
  try {
    const { phoneNumber, callerName, transcript } = req.body;
    const riskResult = calculateRiskScore({ text: transcript || "", phoneNumber });

    // Log the call
    const callLog = await CallLog.create({
      userId: req.user.sub,
      phoneNumber,
      callerName,
      direction: "incoming",
      riskScore: riskResult.score,
      isFraud: riskResult.isThreat,
      status: riskResult.isThreat ? "fraud" : riskResult.score > 30 ? "suspicious" : "safe",
      transcript,
      keywords: riskResult.factors.map(f => f.name),
      analysisResult: riskResult,
    });

    res.json({
      success: true,
      riskScore: riskResult.score,
      riskLevel: riskResult.riskLevel,
      isThreat: riskResult.isThreat,
      factors: riskResult.factors,
      callId: callLog._id,
    });
  } catch (error) {
    next(error);
  }
});

router.get("/calls", async (req, res, next) => {
  try {
    const { status, page = 1, limit = 20 } = req.query;
    const query = { userId: req.user.sub };
    if (status) query.status = status;

    const calls = await CallLog.find(query)
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(parseInt(limit))
      .lean();

    const total = await CallLog.countDocuments(query);

    res.json({ success: true, calls, total, page: parseInt(page), totalPages: Math.ceil(total / limit) });
  } catch (error) {
    next(error);
  }
});

router.get("/calls/:id", async (req, res, next) => {
  try {
    const call = await CallLog.findOne({ _id: req.params.id, userId: req.user.sub }).lean();
    if (!call) return res.status(404).json({ success: false, message: "Call not found" });
    res.json({ success: true, call });
  } catch (error) {
    next(error);
  }
});

// ===== SMS PROTECTION =====
router.post("/sms/analyze", async (req, res, next) => {
  try {
    const { sender, message } = req.body;
    const textResult = analyzeText(message);
    const urlResult = message ? analyzeUrl(message) : null;

    const riskScore = Math.max(textResult.score, urlResult?.riskScore || 0);
    const suspiciousLinks = urlResult?.indicators || [];

    const smsLog = await SmsLog.create({
      userId: req.user.sub,
      sender,
      message,
      riskScore,
      isFraud: riskScore > 50,
      fraudType: Object.keys(textResult.categories).join(", "),
      suspiciousLinks,
      indicators: [...textResult.keywordsFound.map(k => k.keyword), ...suspiciousLinks],
      status: riskScore > 50 ? "suspicious" : "safe",
    });

    res.json({
      success: true,
      riskScore,
      riskLevel: riskScore <= 20 ? "safe" : riskScore <= 50 ? "suspicious" : "dangerous",
      isFraud: riskScore > 50,
      keywordsFound: textResult.keywordsFound,
      suspiciousLinks,
      smsId: smsLog._id,
    });
  } catch (error) {
    next(error);
  }
});

router.get("/sms", async (req, res, next) => {
  try {
    const { status, page = 1, limit = 20 } = req.query;
    const query = { userId: req.user.sub };
    if (status) query.status = status;

    const smsLogs = await SmsLog.find(query)
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(parseInt(limit))
      .lean();

    const total = await SmsLog.countDocuments(query);
    res.json({ success: true, sms: smsLogs, total, page: parseInt(page), totalPages: Math.ceil(total / limit) });
  } catch (error) {
    next(error);
  }
});

// ===== WHATSAPP PROTECTION =====
router.post("/whatsapp/analyze", async (req, res, next) => {
  try {
    const { message, mediaUrl, contactNumber } = req.body;
    const textResult = message ? analyzeText(message) : { score: 0, keywordsFound: [], categories: {} };
    const linkResult = mediaUrl ? analyzeUrl(mediaUrl) : null;

    const riskScore = Math.max(textResult.score, linkResult?.riskScore || 0);

    res.json({
      success: true,
      riskScore,
      riskLevel: riskScore <= 20 ? "safe" : riskScore <= 50 ? "suspicious" : "dangerous",
      isFraud: riskScore > 50,
      textAnalysis: textResult,
      linkAnalysis: linkResult,
    });
  } catch (error) {
    next(error);
  }
});

// ===== LINK SCANNER =====
router.post("/link/analyze", async (req, res, next) => {
  try {
    const { url } = req.body;
    if (!url) return res.status(400).json({ success: false, message: "URL is required" });

    const result = analyzeUrl(url);

    res.json({
      success: true,
      ...result,
      url,
    });
  } catch (error) {
    next(error);
  }
});

// ===== UPI / TRANSACTION PROTECTION =====
router.post("/transaction/analyze", async (req, res, next) => {
  try {
    const { amount, merchantName, merchantId, upiId, isNewBeneficiary, recentTransactionCount } = req.body;

    const txResult = calculateRiskScore({
      transaction: { amount, merchantName, merchantId, isNewBeneficiary, recentTransactionCount },
    });

    const transaction = await Transaction.create({
      userId: req.user.sub,
      amount,
      merchantName,
      merchantId,
      upiId,
      riskScore: txResult.score,
      isFraudulent: txResult.isThreat,
      status: txResult.score > 70 ? "BLOCKED" : txResult.score > 40 ? "PENDING" : "COMPLETED",
    });

    res.json({
      success: true,
      transactionId: transaction._id,
      riskScore: txResult.score,
      riskLevel: txResult.riskLevel,
      shouldBlock: txResult.score > 70,
      shouldWarn: txResult.score > 40,
    });
  } catch (error) {
    next(error);
  }
});

router.get("/transactions", async (req, res, next) => {
  try {
    const transactions = await Transaction.find({ userId: req.user.sub })
      .sort({ createdAt: -1 })
      .limit(50)
      .lean();
    res.json({ success: true, transactions });
  } catch (error) {
    next(error);
  }
});

// ===== FAMILY SHIELD =====
router.get("/family", async (req, res, next) => {
  try {
    const members = await FamilyMember.find({ userId: req.user.sub }).lean();
    res.json({ success: true, members, count: members.length });
  } catch (error) {
    next(error);
  }
});

router.post("/family", async (req, res, next) => {
  try {
    const { name, phoneNumber, relation } = req.body;
    const member = await FamilyMember.create({
      userId: req.user.sub,
      name,
      phoneNumber,
      relation,
    });
    res.status(201).json({ success: true, member });
  } catch (error) {
    next(error);
  }
});

router.put("/family/:id", async (req, res, next) => {
  try {
    const member = await FamilyMember.findOneAndUpdate(
      { _id: req.params.id, userId: req.user.sub },
      { $set: req.body },
      { new: true }
    );
    if (!member) return res.status(404).json({ success: false, message: "Family member not found" });
    res.json({ success: true, member });
  } catch (error) {
    next(error);
  }
});

router.delete("/family/:id", async (req, res, next) => {
  try {
    await FamilyMember.deleteOne({ _id: req.params.id, userId: req.user.sub });
    res.json({ success: true, message: "Family member removed" });
  } catch (error) {
    next(error);
  }
});

// ===== FRAUD REPORTING =====
router.post("/report", async (req, res, next) => {
  try {
    const { fraudType, phoneNumber, description, amount, evidenceUrls, location } = req.body;

    const caseId = `CS-${Date.now().toString(36).toUpperCase()}-${Math.random().toString(36).substr(2, 4).toUpperCase()}`;

    const report = await Report.create({
      userId: req.user.sub,
      fraudType,
      phoneNumber,
      description,
      amount: amount || 0,
      location,
      evidenceUrls: evidenceUrls || [],
      caseId,
      riskScore: calculateRiskScore({ text: description, phoneNumber }).score,
    });

    // Create notification
    await Notification.create({
      userId: req.user.sub,
      title: "Report Submitted",
      message: `Your report #${caseId} has been submitted successfully`,
      type: "REPORT",
      severity: "info",
      data: { reportId: report._id, caseId },
    });

    res.status(201).json({
      success: true,
      report,
      caseId,
      trackingUrl: `/track/${caseId}`,
    });
  } catch (error) {
    next(error);
  }
});

router.get("/reports", async (req, res, next) => {
  try {
    const { status, page = 1, limit = 20 } = req.query;
    const query = { userId: req.user.sub };
    if (status) query.status = status;

    const reports = await Report.find(query)
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(parseInt(limit))
      .lean();

    const total = await Report.countDocuments(query);
    res.json({ success: true, reports, total, page: parseInt(page), totalPages: Math.ceil(total / limit) });
  } catch (error) {
    next(error);
  }
});

router.get("/reports/:id", async (req, res, next) => {
  try {
    const report = await Report.findOne({ _id: req.params.id, userId: req.user.sub }).lean();
    if (!report) return res.status(404).json({ success: false, message: "Report not found" });
    res.json({ success: true, report });
  } catch (error) {
    next(error);
  }
});

// ===== EVIDENCE MANAGEMENT =====
router.post("/evidence/upload", async (req, res, next) => {
  try {
    const { reportId, type, url, mimeType, fileSize } = req.body;
    const evidence = await Evidence.create({
      userId: req.user.sub,
      reportId,
      type,
      url,
      mimeType,
      fileSize,
    });
    res.status(201).json({ success: true, evidence });
  } catch (error) {
    next(error);
  }
});

router.get("/evidence/:reportId", async (req, res, next) => {
  try {
    const evidence = await Evidence.find({
      reportId: req.params.reportId,
      userId: req.user.sub,
    }).lean();
    res.json({ success: true, evidence });
  } catch (error) {
    next(error);
  }
});

// ===== EMERGENCY SYSTEM =====
router.post("/emergency/sos", async (req, res, next) => {
  try {
    const { location, description } = req.body;

    // Create emergency report
    const caseId = `EM-${Date.now().toString(36).toUpperCase()}`;
    const report = await Report.create({
      userId: req.user.sub,
      fraudType: "EMERGENCY",
      description: description || "Emergency SOS activated",
      location,
      caseId,
      status: "REVIEWING",
      riskScore: 100,
    });

    // Get family members to notify
    const familyMembers = await FamilyMember.find({ userId: req.user.sub, status: "active" }).lean();

    // Create emergency notification
    await Notification.create({
      userId: req.user.sub,
      title: "🚨 Emergency SOS Activated",
      message: "Your emergency alert has been received. Authorities will be notified.",
      type: "ALERT",
      severity: "critical",
      data: { reportId: report._id, caseId, familyMembers },
    });

    res.json({
      success: true,
      caseId,
      message: "Emergency alert sent. Help is on the way.",
      familyNotified: familyMembers.length,
    });
  } catch (error) {
    next(error);
  }
});

// ===== NOTIFICATIONS =====
router.get("/notifications", async (req, res, next) => {
  try {
    const notifications = await Notification.find({ userId: req.user.sub })
      .sort({ createdAt: -1 })
      .limit(50)
      .lean();
    const unreadCount = await Notification.countDocuments({ userId: req.user.sub, read: false });
    res.json({ success: true, notifications, unreadCount });
  } catch (error) {
    next(error);
  }
});

router.put("/notifications/:id/read", async (req, res, next) => {
  try {
    await Notification.updateOne(
      { _id: req.params.id, userId: req.user.sub },
      { $set: { read: true, readAt: new Date() } }
    );
    res.json({ success: true });
  } catch (error) {
    next(error);
  }
});

router.put("/notifications/read-all", async (req, res, next) => {
  try {
    await Notification.updateMany(
      { userId: req.user.sub, read: false },
      { $set: { read: true, readAt: new Date() } }
    );
    res.json({ success: true });
  } catch (error) {
    next(error);
  }
});

// ===== TRAINING MODULES =====
router.get("/training/modules", async (req, res, next) => {
  try {
    const modules = await TrainingModule.find({ isActive: true }).lean();
    res.json({ success: true, modules });
  } catch (error) {
    next(error);
  }
});

router.get("/training/modules/:id", async (req, res, next) => {
  try {
    const module = await TrainingModule.findById(req.params.id).lean();
    if (!module) return res.status(404).json({ success: false, message: "Module not found" });
    res.json({ success: true, module });
  } catch (error) {
    next(error);
  }
});

router.post("/training/modules/:id/complete", async (req, res, next) => {
  try {
    const module = await TrainingModule.findByIdAndUpdate(
      req.params.id,
      { $inc: { completionCount: 1 } },
      { new: true }
    );
    if (!module) return res.status(404).json({ success: false, message: "Module not found" });

    await Notification.create({
      userId: req.user.sub,
      title: "🎉 Training Completed",
      message: `Congratulations! You completed "${module.title}"`,
      type: "TRAINING",
      severity: "info",
      data: { moduleId: module._id, badge: module.badgeReward },
    });

    res.json({ success: true, badge: module.badgeReward });
  } catch (error) {
    next(error);
  }
});

// ===== TRUST SCORE =====
router.get("/trust-score", async (req, res, next) => {
  try {
    const userId = req.user.sub;

    const [totalReports, fraudReportsCount, safeReportsCount, blockedCallsCount] = await Promise.all([
      Report.countDocuments({ userId }),
      Report.countDocuments({ userId, status: "RESOLVED" }),
      Report.countDocuments({ userId, status: "DISMISSED" }),
      CallLog.countDocuments({ userId, status: "blocked" }),
    ]);

    // Calculate trust score (0-1000)
    const baseScore = 750;
    const reportDeduction = Math.min(fraudReportsCount * 10, 200);
    const safeBonus = Math.min(safeReportsCount * 5, 100);
    const blockedBonus = Math.min(blockedCallsCount * 2, 50);
    const trustScore = Math.max(0, Math.min(1000, baseScore - reportDeduction + safeBonus + blockedBonus));

    let status = "Excellent";
    if (trustScore < 300) status = "Poor";
    else if (trustScore < 500) status = "Fair";
    else if (trustScore < 700) status = "Good";

    res.json({
      success: true,
      score: trustScore,
      status,
      totalReports,
      safeReports: safeReportsCount,
      fraudReports: fraudReportsCount,
      pendingReports: totalReports - fraudReportsCount - safeReportsCount,
      blockedCalls: blockedCallsCount,
    });
  } catch (error) {
    next(error);
  }
});

// ===== BLOCK NUMBER =====
router.post("/block-number", async (req, res, next) => {
  try {
    const { phoneNumber } = req.body;
    // In production, save to user's block list
    res.json({ success: true, phoneNumber, blocked: true });
  } catch (error) {
    next(error);
  }
});

// ===== HEATMAP DATA =====
router.get("/heatmap", async (req, res, next) => {
  try {
    const fraudData = await Report.aggregate([
      { $match: { location: { $exists: true, $ne: null } } },
      { $group: {
        _id: { city: "$location.city", state: "$location.state" },
        count: { $sum: 1 },
        avgRiskScore: { $avg: "$riskScore" },
      }},
      { $sort: { count: -1 } },
      { $limit: 100 },
    ]);

    res.json({ success: true, heatmapData: fraudData });
  } catch (error) {
    next(error);
  }
});

// ===== HEALTH CHECK =====
router.get("/health", (req, res) => {
  res.json({
    success: true,
    service: "Citizen API",
    version: "1.0.0",
    endpoints: [
      "dashboard", "calls", "sms", "whatsapp", "links",
      "transactions", "family", "reports", "evidence",
      "emergency", "notifications", "training", "trust-score",
    ],
  });
});

export default router;