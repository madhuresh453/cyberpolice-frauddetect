import { Router } from "express";
import mongoose from "mongoose";
import { authenticateJWT } from "../middlewares/auth.middleware.js";

const router = Router();

// POST /report/call - Report fraudulent call
router.post("/report/call", authenticateJWT, async (req, res, next) => {
  try {
    const { caller_number, receiver_number, call_time, duration, notes } = req.body;
    if (!caller_number || !receiver_number) {
      return res.status(400).json({ error: "VALIDATION_ERROR", message: "Caller and receiver numbers required" });
    }
    const report = await mongoose.models.Call.create({
      callerNumber: caller_number,
      receiverNumber: receiver_number,
      userId: req.user.sub,
      callTime: call_time || new Date(),
      duration: duration || 0,
      notes,
      reportType: "fraud",
      status: "pending"
    });
    // Also create fraud report
    await mongoose.models.FraudReport.create({
      userId: req.user.sub,
      reportType: "call",
      referenceId: report._id,
      status: "open",
      description: notes || "Fraud call reported"
    });
    res.status(201).json({ id: report._id, status: "reported", message: "Call reported successfully" });
  } catch (error) { next(error); }
});

// POST /report/sms - Report fraudulent SMS
router.post("/report/sms", authenticateJWT, async (req, res, next) => {
  try {
    const { from_number, message_body, received_at } = req.body;
    if (!from_number || !message_body) {
      return res.status(400).json({ error: "VALIDATION_ERROR", message: "Sender number and message body required" });
    }
    const smsLog = await mongoose.models.SmsLog.create({
      fromNumber: from_number,
      toNumber: req.user.phone || "unknown",
      messageBody: message_body,
      userId: req.user.sub,
      receivedAt: received_at || new Date(),
      classification: "fraud",
      status: "pending"
    });
    await mongoose.models.FraudReport.create({
      userId: req.user.sub,
      reportType: "sms",
      referenceId: smsLog._id,
      status: "open",
      description: message_body.substring(0, 500)
    });
    res.status(201).json({ id: smsLog._id, status: "reported", message: "SMS reported successfully" });
  } catch (error) { next(error); }
});

// POST /report/whatsapp - Report fraudulent WhatsApp message
router.post("/report/whatsapp", authenticateJWT, async (req, res, next) => {
  try {
    const { from_number, message_body, media_urls, received_at } = req.body;
    if (!from_number || !message_body) {
      return res.status(400).json({ error: "VALIDATION_ERROR", message: "Sender number and message body required" });
    }
    const whatsappReport = await mongoose.models.WhatsappAnalysis.create({
      senderNumber: from_number,
      messageBody: message_body,
      userId: req.user.sub,
      mediaUrls: media_urls || [],
      receivedAt: received_at || new Date(),
      classification: "suspicious",
      status: "pending"
    });
    await mongoose.models.FraudReport.create({
      userId: req.user.sub,
      reportType: "whatsapp",
      referenceId: whatsappReport._id,
      status: "open",
      description: message_body.substring(0, 500)
    });
    res.status(201).json({ id: whatsappReport._id, status: "reported", message: "WhatsApp message reported successfully" });
  } catch (error) { next(error); }
});

// GET /trust-score/{number} - Get trust score for a phone number
router.get("/trust-score/:number", authenticateJWT, async (req, res, next) => {
  try {
    const { number } = req.params;
    const citizen = await mongoose.models.Citizen.findOne({ phoneNumber: number });
    const trustScore = await mongoose.models.TrustScore.findOne({ phoneNumber: number });
    const riskScore = await mongoose.models.RiskScore.findOne({ phoneNumber: number });
    const fraudReports = await mongoose.models.FraudReport.countDocuments({ "metadata.phoneNumber": number });
    res.json({
      phone_number: number,
      trust_score: trustScore?.score ?? citizen?.trustScore ?? 50,
      risk_category: riskScore?.category ?? citizen?.riskCategory ?? "unknown",
      verification_status: citizen?.verificationStatus ?? "unverified",
      total_reports: fraudReports,
      last_updated: trustScore?.updatedAt ?? null,
      exists_in_system: !!citizen
    });
  } catch (error) { next(error); }
});

// GET /history - Get user's report history
router.get("/history", authenticateJWT, async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;
    const { status, type, start_date, end_date } = req.query;

    const filter = { userId: new mongoose.Types.ObjectId(req.user.sub) };
    if (status) filter.status = status;
    if (type) filter.reportType = type;
    if (start_date || end_date) {
      filter.createdAt = {};
      if (start_date) filter.createdAt.$gte = new Date(start_date);
      if (end_date) filter.createdAt.$lte = new Date(end_date);
    }

    const [reports, total] = await Promise.all([
      mongoose.models.FraudReport.find(filter).sort({ createdAt: -1 }).skip(skip).limit(limit).lean(),
      mongoose.models.FraudReport.countDocuments(filter)
    ]);

    res.json({
      data: reports.map(r => ({
        id: r._id,
        type: r.reportType,
        status: r.status,
        description: r.description?.substring(0, 200),
        created_at: r.createdAt
      })),
      pagination: { page, limit, total, pages: Math.ceil(total / limit) }
    });
  } catch (error) { next(error); }
});

// POST /block-number - Block a number
router.post("/block-number", authenticateJWT, async (req, res, next) => {
  try {
    const { phone_number, reason } = req.body;
    if (!phone_number) {
      return res.status(400).json({ error: "VALIDATION_ERROR", message: "Phone number required" });
    }
    const existing = await mongoose.models.BlockedNumber.findOne({
      userId: req.user.sub,
      phoneNumber: phone_number
    });
    if (existing) {
      return res.status(409).json({ error: "CONFLICT", message: "Number already blocked" });
    }
    const blocked = await mongoose.models.BlockedNumber.create({
      userId: req.user.sub,
      phoneNumber: phone_number,
      reason: reason || "User blocked",
      blockedAt: new Date()
    });
    res.status(201).json({ id: blocked._id, phone_number, status: "blocked" });
  } catch (error) { next(error); }
});

// POST /emergency-sos - Send SOS alert
router.post("/emergency-sos", authenticateJWT, async (req, res, next) => {
  try {
    const { location, message, emergency_type } = req.body;
    const sos = await mongoose.models.EmergencySos.create({
      userId: req.user.sub,
      location: {
        type: "Point",
        coordinates: location?.coordinates || [0, 0],
        address: location?.address
      },
      message: message || "SOS Alert",
      emergencyType: emergency_type || "general",
      status: "active",
      priority: "high",
      initiatedAt: new Date()
    });
    res.status(201).json({ id: sos._id, status: "sos_sent", message: "Emergency services notified" });
  } catch (error) { next(error); }
});

// GET /family-protection - Get family protection status
router.get("/family-protection", authenticateJWT, async (req, res, next) => {
  try {
    const citizen = await mongoose.models.Citizen.findOne({ userId: req.user.sub });
    if (!citizen) {
      return res.status(404).json({ error: "NOT_FOUND", message: "Citizen profile not found" });
    }
    const familyMembers = await mongoose.models.FamilyMember.find({ citizenId: citizen._id }).lean();
    const blockedNumbers = await mongoose.models.BlockedNumber.find({ userId: req.user.sub }).lean();
    res.json({
      protection_enabled: citizen.preferences?.familyProtection || false,
      family_members: familyMembers.map(f => ({
        id: f._id,
        name: f.fullName,
        phone: f.phoneNumber,
        relation: f.relationship,
        status: f.status || "pending"
      })),
      blocked_numbers: blockedNumbers.map(b => ({
        phone: b.phoneNumber,
        reason: b.reason,
        blocked_at: b.blockedAt
      })),
      trust_score: citizen.trustScore,
      risk_category: citizen.riskCategory
    });
  } catch (error) { next(error); }
});

// POST /evidence/upload - Upload evidence for a report
router.post("/evidence/upload", authenticateJWT, async (req, res, next) => {
  try {
    const { report_id, file_url, file_type, description, metadata } = req.body;
    if (!report_id || !file_url || !file_type) {
      return res.status(400).json({ error: "VALIDATION_ERROR", message: "Report ID, file URL and file type required" });
    }
    const evidence = await mongoose.models.EvidenceFile.create({
      userId: req.user.sub,
      reportId: report_id,
      fileUrl: file_url,
      fileType: file_type,
      description: description || "",
      metadata: metadata || {},
      status: "uploaded",
      uploadedAt: new Date()
    });
    // Update chain of custody
    await mongoose.models.ChainOfCustody.create({
      evidenceId: evidence._id,
      action: "uploaded",
      actionBy: req.user.sub,
      actionByRole: req.user.role,
      timestamp: new Date(),
      notes: "Initial evidence upload"
    });
    res.status(201).json({ id: evidence._id, status: "uploaded" });
  } catch (error) { next(error); }
});

export default router;