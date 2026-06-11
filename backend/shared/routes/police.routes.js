import { Router } from "express";
import mongoose from "mongoose";
import { authenticateJWT, requireRole } from "../middlewares/auth.middleware.js";

const router = Router();

// GET /cases - List all cases with pagination and filters
router.get("/cases", authenticateJWT, requireRole("police", "admin"), async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;
    const { status, priority, district, state, officer_id, type } = req.query;

    const filter = {};
    if (status) filter.status = status;
    if (priority) filter.priority = priority;
    if (district) filter.district = district;
    if (state) filter.state = state;
    if (officer_id) filter.assignedOfficer = new mongoose.Types.ObjectId(officer_id);
    if (type) filter.caseType = type;
    if (req.user.role === "police") {
      const officer = await mongoose.models.PoliceOfficer.findOne({ userId: req.user.sub });
      if (officer) filter.$or = [{ assignedOfficer: officer._id }, { departmentId: officer.departmentId }];
    }

    const [cases, total] = await Promise.all([
      mongoose.models.Case.find(filter)
        .populate("assignedOfficer", "fullName badgeNumber")
        .populate("departmentId", "name district state")
        .sort({ createdAt: -1 }).skip(skip).limit(limit).lean(),
      mongoose.models.Case.countDocuments(filter)
    ]);

    res.json({
      data: cases.map(c => ({
        id: c._id, case_number: c.caseNumber, type: c.caseType, status: c.status,
        priority: c.priority, title: c.title, description: c.description?.substring(0, 300),
        district: c.district, state: c.state, assigned_officer: c.assignedOfficer,
        department: c.departmentId, fir_count: c.firCount || 0, evidence_count: c.evidenceCount || 0,
        risk_score: c.riskScore, created_at: c.createdAt, updated_at: c.updatedAt
      })),
      pagination: { page, limit, total, pages: Math.ceil(total / limit) }
    });
  } catch (error) { next(error); }
});

// POST /cases - Create a new case
router.post("/cases", authenticateJWT, requireRole("police", "admin"), async (req, res, next) => {
  try {
    const { title, description, case_type, priority, district, state, complainant_name, complainant_phone, related_numbers, related_upi_ids } = req.body;
    if (!title || !case_type) {
      return res.status(400).json({ error: "VALIDATION_ERROR", message: "Title and case type required" });
    }
    const officer = await mongoose.models.PoliceOfficer.findOne({ userId: req.user.sub });
    const caseDoc = await mongoose.models.Case.create({
      title, description, caseType: case_type, priority: priority || "medium",
      district, state, complainantName: complainant_name, complainantPhone: complainant_phone,
      relatedNumbers: related_numbers || [], relatedUpiIds: related_upi_ids || [],
      assignedOfficer: officer?._id, departmentId: officer?.departmentId,
      status: "open", riskScore: 50
    });
    res.status(201).json({ id: caseDoc._id, case_number: caseDoc.caseNumber, status: "created" });
  } catch (error) { next(error); }
});

// GET /firs - List all FIRs
router.get("/firs", authenticateJWT, requireRole("police", "admin"), async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;
    const { status, district, case_id, officer_id } = req.query;

    const filter = {};
    if (status) filter.status = status;
    if (district) filter.district = district;
    if (case_id) filter.caseId = new mongoose.Types.ObjectId(case_id);
    if (officer_id) filter.filedBy = new mongoose.Types.ObjectId(officer_id);

    const [firs, total] = await Promise.all([
      mongoose.models.FIR.find(filter)
        .populate("caseId", "caseNumber title")
        .populate("filedBy", "fullName badgeNumber")
        .sort({ createdAt: -1 }).skip(skip).limit(limit).lean(),
      mongoose.models.FIR.countDocuments(filter)
    ]);

    res.json({
      data: firs.map(f => ({
        id: f._id, fir_number: f.firNumber, case: f.caseId,
        complainant_name: f.complainantName, complainant_phone: f.complainantPhone,
        incident_date: f.incidentDate, incident_location: f.incidentLocation,
        sections: f.sections, status: f.status, filed_by: f.filedBy,
        created_at: f.createdAt, updated_at: f.updatedAt
      })),
      pagination: { page, limit, total, pages: Math.ceil(total / limit) }
    });
  } catch (error) { next(error); }
});

// POST /firs - Create a new FIR
router.post("/firs", authenticateJWT, requireRole("police", "admin"), async (req, res, next) => {
  try {
    const { case_id, complainant_name, complainant_phone, complainant_address, incident_date, incident_location, description, sections, accused_details } = req.body;
    if (!case_id || !complainant_name) {
      return res.status(400).json({ error: "VALIDATION_ERROR", message: "Case ID and complainant name required" });
    }
    const officer = await mongoose.models.PoliceOfficer.findOne({ userId: req.user.sub });
    const fir = await mongoose.models.FIR.create({
      caseId: new mongoose.Types.ObjectId(case_id),
      complainantName: complainant_name, complainantPhone: complainant_phone,
      complainantAddress: complainant_address, incidentDate: incident_date || new Date(),
      incidentLocation: incident_location, description, sections: sections || [],
      accusedDetails: accused_details || [], filedBy: officer?._id, status: "registered",
      district: officer?.district, state: officer?.state
    });
    // Update case with FIR reference
    await mongoose.models.Case.findByIdAndUpdate(case_id, { $inc: { firCount: 1 }, $push: { firIds: fir._id } });
    res.status(201).json({ id: fir._id, fir_number: fir.firNumber, status: "registered" });
  } catch (error) { next(error); }
});

// GET /evidence - List all evidence
router.get("/evidence", authenticateJWT, requireRole("police", "admin"), async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;
    const { case_id, type, status } = req.query;

    const filter = {};
    if (case_id) filter.caseId = new mongoose.Types.ObjectId(case_id);
    if (type) filter.fileType = type;
    if (status) filter.status = status;

    const [evidence, total] = await Promise.all([
      mongoose.models.EvidenceFile.find(filter)
        .populate("caseId", "caseNumber title")
        .populate("userId", "fullName email")
        .sort({ createdAt: -1 }).skip(skip).limit(limit).lean(),
      mongoose.models.EvidenceFile.countDocuments(filter)
    ]);

    res.json({
      data: evidence.map(e => ({
        id: e._id, case: e.caseId, file_url: e.fileUrl, file_type: e.fileType,
        description: e.description, uploaded_by: e.userId, status: e.status,
        uploaded_at: e.uploadedAt
      })),
      pagination: { page, limit, total, pages: Math.ceil(total / limit) }
    });
  } catch (error) { next(error); }
});

// GET /analytics - Get fraud analytics data
router.get("/analytics", authenticateJWT, requireRole("police", "admin"), async (req, res, next) => {
  try {
    const { district, state, days } = req.query;
    const dateFilter = {};
    if (days) dateFilter.createdAt = { $gte: new Date(Date.now() - parseInt(days) * 86400000) };

    const matchFilter = { ...dateFilter };
    if (district) matchFilter.district = district;
    if (state) matchFilter.state = state;

    const [totalCases, openCases, closedCases, totalFirs, totalReports, fraudByType, dailyStats] = await Promise.all([
      mongoose.models.Case.countDocuments(matchFilter),
      mongoose.models.Case.countDocuments({ ...matchFilter, status: "open" }),
      mongoose.models.Case.countDocuments({ ...matchFilter, status: { $in: ["closed", "resolved"] } }),
      mongoose.models.FIR.countDocuments(matchFilter),
      mongoose.models.FraudReport.countDocuments(dateFilter),
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
      ])
    ]);

    res.json({
      summary: {
        total_cases: totalCases,
        open_cases: openCases,
        closed_cases: closedCases,
        total_firs: totalFirs,
        total_reports: totalReports,
        resolution_rate: totalCases > 0 ? Math.round((closedCases / totalCases) * 100) : 0
      },
      fraud_by_type: fraudByType.map(f => ({ type: f._id, count: f.count })),
      daily_trend: dailyStats.map(d => ({ date: d._id, count: d.count })),
      period: days ? `${days}d` : "all"
    });
  } catch (error) { next(error); }
});

// GET /heatmap - Get fraud heatmap data
router.get("/heatmap", authenticateJWT, requireRole("police", "admin"), async (req, res, next) => {
  try {
    const { district, state, fraud_type } = req.query;
    const filter = {};
    if (district) filter.district = district;
    if (state) filter.state = state;
    if (fraud_type) filter.fraudType = fraud_type;

    const data = await mongoose.models.HeatmapData.find(filter)
      .sort({ count: -1 }).limit(500).lean();

    res.json({
      data: data.map(h => ({
        district: h.district, state: h.state,
        lat: h.coordinates?.lat, lng: h.coordinates?.lng,
        count: h.count, risk_score: h.riskScore,
        fraud_types: h.fraudTypes, trend: h.trend
      })),
      total_locations: data.length
    });
  } catch (error) { next(error); }
});

// GET /fraud-network - Get fraud network data
router.get("/fraud-network", authenticateJWT, requireRole("police", "admin"), async (req, res, next) => {
  try {
    const { phone_number, upi_id, case_id, depth } = req.query;
    const pipeline = [];

    if (phone_number) {
      pipeline.push(
        { $match: { phoneNumber: phone_number } },
        { $lookup: { from: "fraudreports", localField: "phoneNumber", foreignField: "metadata.phoneNumber", as: "reports" } },
        { $lookup: { from: "callanalyses", localField: "phoneNumber", localField: "callerNumber", foreignField: "receiverNumber", as: "calls" } },
        { $lookup: { from: "cases", localField: "phoneNumber", localField: "relatedNumbers", foreignField: "relatedNumbers", as: "cases" } },
        { $limit: 1 }
      );
    } else if (upi_id) {
      pipeline.push(
        { $match: { upiId: upi_id } },
        { $lookup: { from: "fraudreports", localField: "upiId", foreignField: "metadata.upiId", as: "reports" } },
        { $lookup: { from: "cases", localField: "upiId", localField: "relatedUpiIds", foreignField: "relatedUpiIds", as: "cases" } },
        { $limit: 1 }
      );
    } else if (case_id) {
      const caseDoc = await mongoose.models.Case.findById(case_id).lean();
      if (!caseDoc) return res.status(404).json({ error: "NOT_FOUND", message: "Case not found" });
      const relatedPhones = await mongoose.models.FraudNumber.find({ phoneNumber: { $in: caseDoc.relatedNumbers || [] } }).lean();
      const relatedUpi = await mongoose.models.FraudUpiId.find({ upiId: { $in: caseDoc.relatedUpiIds || [] } }).lean();
      return res.json({
        case: caseDoc,
        nodes: [
          ...relatedPhones.map(p => ({ type: "phone", value: p.phoneNumber, risk: p.riskScore })),
          ...relatedUpi.map(u => ({ type: "upi", value: u.upiId, risk: u.riskScore }))
        ],
        links: relatedPhones.map(p => ({ source: caseDoc.caseNumber, target: p.phoneNumber, type: "linked" }))
      });
    }

    if (pipeline.length === 0) {
      // Return top fraud connections
      const topFraudNumbers = await mongoose.models.FraudNumber.find()
        .sort({ riskScore: -1 }).limit(20).lean();
      const topFraudUpi = await mongoose.models.FraudUpiId.find()
        .sort({ riskScore: -1 }).limit(20).lean();
      return res.json({
        nodes: [
          ...topFraudNumbers.map(p => ({ type: "phone", value: p.phoneNumber, risk: p.riskScore })),
          ...topFraudUpi.map(u => ({ type: "upi", value: u.upiId, risk: u.riskScore }))
        ]
      });
    }

    const result = await mongoose.models.FraudNumber.aggregate(pipeline);
    res.json({ data: result });
  } catch (error) { next(error); }
});

// POST /bank-freeze - Request bank account freeze
router.post("/bank-freeze", authenticateJWT, requireRole("police", "admin"), async (req, res, next) => {
  try {
    const { account_number, ifsc_code, bank_name, account_holder, reason, case_id, upi_id } = req.body;
    if (!account_number || !ifsc_code || !reason) {
      return res.status(400).json({ error: "VALIDATION_ERROR", message: "Account number, IFSC, and reason required" });
    }
    const officer = await mongoose.models.PoliceOfficer.findOne({ userId: req.user.sub });
    const freezeReq = await mongoose.models.FreezeRequest.create({
      accountNumber: account_number, ifscCode: ifsc_code, bankName: bank_name,
      accountHolder: account_holder, reason, caseId: case_id ? new mongoose.Types.ObjectId(case_id) : null,
      upiId: upi_id, requestedBy: officer?._id, requestorType: "police",
      status: "pending", priority: "high"
    });
    res.status(201).json({ id: freezeReq._id, status: "freeze_requested", message: "Bank freeze request submitted" });
  } catch (error) { next(error); }
});

// POST /deepfake-analysis - Submit deepfake analysis request
router.post("/deepfake-analysis", authenticateJWT, requireRole("police", "admin"), async (req, res, next) => {
  try {
    const { media_url, media_type, case_id, description } = req.body;
    if (!media_url || !media_type) {
      return res.status(400).json({ error: "VALIDATION_ERROR", message: "Media URL and type required" });
    }
    const analysis = await mongoose.models.DeepfakeAnalysis.create({
      mediaUrl: media_url, mediaType: media_type,
      caseId: case_id ? new mongoose.Types.ObjectId(case_id) : null,
      requestedBy: req.user.sub, description,
      status: "processing", confidence: 0,
      submittedAt: new Date()
    });
    res.status(201).json({ id: analysis._id, status: "processing", message: "Analysis queued" });
  } catch (error) { next(error); }
});

export default router;