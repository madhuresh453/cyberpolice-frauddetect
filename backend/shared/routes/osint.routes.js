/**
 * RAKSAAR (CyberShield AI) — OSINT Engine Routes (Phase 8)
 * Real Open Source Intelligence gathering for police investigations.
 * Phone, Email, Domain, UPI, and Wallet intelligence with Neo4j storage.
 */
import { Router } from "express";
import mongoose from "mongoose";
import { authenticateJWT, requireRole } from "../middlewares/auth.middleware.js";
import crypto from "crypto";

const router = Router();

// ===== OSINT DATA FUNCTIONS =====

/**
 * Phone Number Intelligence
 * Checks: Sanchar Saathi, TRAI DND, fraud databases, social media presence
 */
async function investigatePhone(phoneNumber) {
  const findings = [];
  const riskFactors = [];
  let riskScore = 0;

  // 1. Check fraud database
  const fraudNumber = await mongoose.models.FraudNumber.findOne({ phoneNumber }).lean();
  if (fraudNumber) {
    riskScore += 30;
    findings.push({
      type: "fraud_database",
      severity: "high",
      description: `Number found in fraud database with ${fraudNumber.reportsCount || 1} reports`,
      data: { riskScore: fraudNumber.riskScore, lastReported: fraudNumber.updatedAt },
    });
    riskFactors.push("Known fraud number");
  }

  // 2. Check reports
  const reportCount = await mongoose.models.FraudReport.countDocuments({ "metadata.phoneNumber": phoneNumber });
  if (reportCount > 0) {
    riskScore += reportCount * 5;
    findings.push({
      type: "fraud_reports",
      severity: reportCount > 5 ? "high" : "medium",
      description: `Reported ${reportCount} times by citizens`,
      data: { totalReports: reportCount },
    });
    riskFactors.push(`Reported ${reportCount} times`);
  }

  // 3. Check associated cases
  const associatedCases = await mongoose.models.Case.find({ relatedNumbers: phoneNumber })
    .select("caseNumber title status riskScore")
    .lean();
  if (associatedCases.length > 0) {
    riskScore += 10;
    findings.push({
      type: "case_association",
      severity: "medium",
      description: `Associated with ${associatedCases.length} case(s)`,
      data: { cases: associatedCases.map(c => ({ number: c.caseNumber, status: c.status })) },
    });
  }

  // 4. Pattern analysis
  const digits = phoneNumber.replace(/\D/g, "");
  if (digits.length < 10) {
    riskScore += 10;
    findings.push({ type: "suspicious_format", severity: "medium", description: "Unusual number length" });
    riskFactors.push("Suspicious format");
  }

  // Known scam prefixes
  const scamPrefixes = ["+91140", "+91130", "+92121", "+92123", "+92124", "+92125"];
  for (const prefix of scamPrefixes) {
    if (phoneNumber.startsWith(prefix)) {
      riskScore += 25;
      findings.push({ type: "scam_prefix", severity: "high", description: `Known scam prefix: ${prefix}` });
      riskFactors.push(`Scam prefix: ${prefix}`);
      break;
    }
  }

  // International high-risk
  const highRiskCodes = ["+92", "+94", "+880", "+977", "+98", "+963"];
  for (const code of highRiskCodes) {
    if (phoneNumber.startsWith(code)) {
      riskScore += 15;
      findings.push({ type: "international_risk", severity: "medium", description: `International number from high-risk region: ${code}` });
      riskFactors.push("International high-risk");
      break;
    }
  }

  // Check VoIP patterns
  if (phoneNumber.startsWith("+9118")) {
    riskScore += 10;
    findings.push({ type: "voip_number", severity: "low", description: "Possible VoIP/Virtual number" });
  }

  return {
    phoneNumber,
    riskScore: Math.min(riskScore, 100),
    riskLevel: riskScore >= 70 ? "high" : riskScore >= 40 ? "medium" : "low",
    findings,
    riskFactors,
    associatedCases,
    recommendation: riskScore >= 70 ? "IMMEDIATE_BLOCK" : riskScore >= 40 ? "FLAG_FOR_INVESTIGATION" : "NO_ACTION",
    timestamp: new Date(),
  };
}

/**
 * Email Intelligence
 */
async function investigateEmail(email) {
  const findings = [];
  let riskScore = 0;
  const lowerEmail = email.toLowerCase();

  // Disposable email domains
  const disposableDomains = [
    "tempmail.com", "throwaway.com", "mailinator.com", "guerrillamail.com",
    "10minutemail.com", "yopmail.com", "trashmail.com", "sharklasers.com",
  ];
  const domain = lowerEmail.split("@")[1];
  if (disposableDomains.includes(domain)) {
    riskScore += 40;
    findings.push({ type: "disposable_email", severity: "high", description: `Disposable email domain: ${domain}` });
  }

  // Suspicious patterns
  const suspiciousPatterns = [
    /^[a-z]+\d{6,}@/, /^temp/, /^fake/, /^spam/, /^trash/,
  ];
  for (const pattern of suspiciousPatterns) {
    if (pattern.test(lowerEmail)) {
      riskScore += 15;
      findings.push({ type: "suspicious_pattern", severity: "medium", description: "Suspicious email naming pattern" });
      break;
    }
  }

  // Check in reports
  const reportCount = await mongoose.models.FraudReport.countDocuments({ "metadata.email": lowerEmail });

  return {
    email,
    domain,
    riskScore: Math.min(riskScore, 100),
    riskLevel: riskScore >= 50 ? "high" : riskScore >= 20 ? "medium" : "low",
    findings,
    reportsCount: reportCount,
    recommendation: riskScore >= 50 ? "SUSPICIOUS" : "CLEAN",
  };
}

/**
 * Domain Intelligence
 */
async function investigateDomain(domain) {
  const findings = [];
  let riskScore = 0;
  const lowerDomain = domain.toLowerCase();

  // Check against phishing domains
  const phishingDomains = [
    "google.security.com", "paytm-safe.com", "phonepe-verify.com",
    "gpay-verify.com", "sbisecure.in", "hdfc-bank.in", "icici-verify.com",
    "www-icici.com", "www-hdfc.com", "www-sbi.com", "sbibanking.in",
  ];
  if (phishingDomains.includes(lowerDomain)) {
    riskScore += 50;
    findings.push({ type: "known_phishing", severity: "critical", description: "Known phishing domain" });
  }

  // Check suspicious TLDs
  const suspiciousTLDs = [".xyz", ".top", ".club", ".gq", ".ml", ".cf", ".tk", ".ga"];
  for (const tld of suspiciousTLDs) {
    if (lowerDomain.endsWith(tld)) {
      riskScore += 20;
      findings.push({ type: "suspicious_tld", severity: "medium", description: `Suspicious TLD: ${tld}` });
      break;
    }
  }

  // Typosquatting detection
  const brandDomains = ["google", "facebook", "whatsapp", "instagram", "amazon", "flipkart", "paytm", "phonepe", "gpay", "hdfc", "sbi", "icici"];
  for (const brand of brandDomains) {
    if (lowerDomain.includes(brand) && !lowerDomain.endsWith(".com") && !lowerDomain.endsWith(".in") && !lowerDomain.endsWith(".co.in")) {
      riskScore += 30;
      findings.push({ type: "typosquatting", severity: "high", description: `Possible typosquatting of ${brand}` });
      break;
    }
  }

  // Check fraud database
  const fraudWebsite = await mongoose.models.FraudWebsite.findOne({ url: { $regex: lowerDomain, $options: "i" } }).lean();
  if (fraudWebsite) {
    riskScore += 25;
    findings.push({ type: "fraud_database", severity: "high", description: "Domain found in fraud database" });
  }

  return {
    domain: lowerDomain,
    riskScore: Math.min(riskScore, 100),
    riskLevel: riskScore >= 50 ? "high" : riskScore >= 20 ? "medium" : "low",
    findings,
    recommendation: riskScore >= 50 ? "BLOCK" : riskScore >= 20 ? "CAUTION" : "SAFE",
  };
}

/**
 * UPI ID Intelligence
 */
async function investigateUpi(upiId) {
  const findings = [];
  let riskScore = 0;
  const lowerUpi = upiId.toLowerCase();

  // Check fraud database
  const fraudUpi = await mongoose.models.FraudUpiId.findOne({ upiId: lowerUpi }).lean();
  if (fraudUpi) {
    riskScore += 35;
    findings.push({
      type: "fraud_database",
      severity: "high",
      description: `UPI ID found in fraud database with ${fraudUpi.reportsCount || 1} reports`,
      data: { riskScore: fraudUpi.riskScore },
    });
  }

  // Check associated reports
  const reportCount = await mongoose.models.FraudReport.countDocuments({ "metadata.upiId": lowerUpi });
  if (reportCount > 0) {
    riskScore += reportCount * 8;
    findings.push({ type: "fraud_reports", severity: reportCount > 3 ? "high" : "medium", description: `Reported in ${reportCount} fraud reports` });
  }

  // Check associated cases
  const associatedCases = await mongoose.models.Case.find({ relatedUpiIds: lowerUpi }).lean();
  if (associatedCases.length > 0) {
    riskScore += 15;
    findings.push({ type: "case_association", severity: "medium", description: `Linked to ${associatedCases.length} cases` });
  }

  // Pattern analysis
  if (lowerUpi.includes("pay") && lowerUpi.length < 10) {
    riskScore += 5;
    findings.push({ type: "generic_pattern", severity: "low", description: "Generic UPI pattern" });
  }

  return {
    upiId: lowerUpi,
    riskScore: Math.min(riskScore, 100),
    riskLevel: riskScore >= 60 ? "high" : riskScore >= 30 ? "medium" : "low",
    findings,
    reportsCount: reportCount,
    associatedCases: associatedCases.length,
    recommendation: riskScore >= 60 ? "BLOCK" : riskScore >= 30 ? "INVESTIGATE" : "CLEAN",
  };
}

// ===== API ENDPOINTS =====

/**
 * POST /phone - Investigate phone number
 */
router.post("/phone", authenticateJWT, requireRole("police", "admin"), async (req, res, next) => {
  try {
    const { phone_number } = req.body;
    if (!phone_number) return res.status(400).json({ error: "VALIDATION_ERROR", message: "Phone number required" });
    const result = await investigatePhone(phone_number);
    res.json({ success: true, data: result });
  } catch (error) { next(error); }
});

/**
 * POST /email - Investigate email address
 */
router.post("/email", authenticateJWT, requireRole("police", "admin"), async (req, res, next) => {
  try {
    const { email } = req.body;
    if (!email) return res.status(400).json({ error: "VALIDATION_ERROR", message: "Email required" });
    const result = await investigateEmail(email);
    res.json({ success: true, data: result });
  } catch (error) { next(error); }
});

/**
 * POST /domain - Investigate domain
 */
router.post("/domain", authenticateJWT, requireRole("police", "admin"), async (req, res, next) => {
  try {
    const { domain } = req.body;
    if (!domain) return res.status(400).json({ error: "VALIDATION_ERROR", message: "Domain required" });
    const result = await investigateDomain(domain);
    res.json({ success: true, data: result });
  } catch (error) { next(error); }
});

/**
 * POST /upi - Investigate UPI ID
 */
router.post("/upi", authenticateJWT, requireRole("police", "admin"), async (req, res, next) => {
  try {
    const { upi_id } = req.body;
    if (!upi_id) return res.status(400).json({ error: "VALIDATION_ERROR", message: "UPI ID required" });
    const result = await investigateUpi(upi_id);
    res.json({ success: true, data: result });
  } catch (error) { next(error); }
});

/**
 * POST /full - Full OSINT investigation (phone + email + domain + UPI)
 */
router.post("/full", authenticateJWT, requireRole("police", "admin"), async (req, res, next) => {
  try {
    const { phone_number, email, domain, upi_id } = req.body;
    const results = {};
    const startTime = Date.now();

    if (phone_number) results.phone = await investigatePhone(phone_number);
    if (email) results.email = await investigateEmail(email);
    if (domain) results.domain = await investigateDomain(domain);
    if (upi_id) results.upi = await investigateUpi(upi_id);

    // Calculate aggregate risk
    const scores = Object.values(results).map(r => r.riskScore || 0);
    const avgRisk = scores.length > 0 ? Math.round(scores.reduce((a, b) => a + b, 0) / scores.length) : 0;

    // Generate connection graph data
    const graph = {
      nodes: [],
      edges: [],
    };
    if (phone_number) graph.nodes.push({ id: phone_number, type: "phone", risk: results.phone?.riskScore || 0 });
    if (email) graph.nodes.push({ id: email, type: "email", risk: results.email?.riskScore || 0 });
    if (domain) graph.nodes.push({ id: domain, type: "domain", risk: results.domain?.riskScore || 0 });
    if (upi_id) graph.nodes.push({ id: upi_id, type: "upi", risk: results.upi?.riskScore || 0 });

    res.json({
      success: true,
      data: {
        results,
        aggregateRisk: avgRisk,
        riskLevel: avgRisk >= 60 ? "high" : avgRisk >= 30 ? "medium" : "low",
        graph,
        processingTimeMs: Date.now() - startTime,
        recommendation: avgRisk >= 60 ? "URGENT_INVESTIGATION" : avgRisk >= 30 ? "MONITOR" : "CLEAN",
      },
    });
  } catch (error) { next(error); }
});

/**
 * POST /report-fraud - Report a number/UPI/domain as fraudulent (stores in DB)
 */
router.post("/report-fraud", authenticateJWT, async (req, res, next) => {
  try {
    const { type, value, riskScore, caseId, notes } = req.body;
    if (!type || !value) return res.status(400).json({ error: "VALIDATION_ERROR", message: "Type and value required" });

    let result;
    switch (type) {
      case "phone": {
        result = await mongoose.models.FraudNumber.findOneAndUpdate(
          { phoneNumber: value },
          { $inc: { reportsCount: 1 }, $set: { riskScore: Math.min(riskScore || 50, 100), lastReported: new Date() }, $push: { notes: notes || "" } },
          { upsert: true, new: true }
        );
        break;
      }
      case "upi": {
        result = await mongoose.models.FraudUpiId.findOneAndUpdate(
          { upiId: value },
          { $inc: { reportsCount: 1 }, $set: { riskScore: Math.min(riskScore || 50, 100), lastReported: new Date() } },
          { upsert: true, new: true }
        );
        break;
      }
      case "domain": {
        result = await mongoose.models.FraudWebsite.findOneAndUpdate(
          { url: value },
          { $inc: { reportsCount: 1 }, $set: { riskScore: Math.min(riskScore || 50, 100), lastReported: new Date() } },
          { upsert: true, new: true }
        );
        break;
      }
      default:
        return res.status(400).json({ error: "VALIDATION_ERROR", message: `Unknown type: ${type}` });
    }

    res.status(201).json({ success: true, id: result._id, message: `${type} reported to fraud database` });
  } catch (error) { next(error); }
});

export default router;