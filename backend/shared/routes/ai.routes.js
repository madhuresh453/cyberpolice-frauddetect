/**
 * RAKSAAR (CyberShield AI) — AI Integration Routes
 * Connects the Express backend to the AI Gateway (Python FastAPI).
 * All AI operations go through these endpoints.
 */
import { Router } from "express";
import mongoose from "mongoose";
import { authenticateJWT } from "../middlewares/auth.middleware.js";
import multer from "multer";

const router = Router();
const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 50 * 1024 * 1024 } });

// AI Gateway URL - points to the Python AI Gateway service
// Uses environment variable; falls back to production URL for release builds
const AI_GATEWAY_URL = process.env.AI_GATEWAY_URL || (process.env.NODE_ENV === "production" ? "https://api.uni6ctf.online" : "http://localhost:8000");

/**
 * Helper to call AI Gateway
 */
async function callAIGateway(endpoint, method = "GET", body = null, audioFile = null) {
  const url = `${AI_GATEWAY_URL}${endpoint}`;
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 30000);

  try {
    const fetch = (await import("node-fetch")).default;

    if (audioFile) {
      // Form data with audio file
      const FormData = (await import("form-data")).default;
      const form = new FormData();
      form.append("file", audioFile.buffer, audioFile.originalname || "audio.wav");
      if (body) {
        Object.entries(body).forEach(([key, value]) => {
          if (value) form.append(key, String(value));
        });
      }
      const response = await fetch(url, { method, body: form, signal: controller.signal });
      clearTimeout(timeout);
      return await response.json();
    }

    const response = await fetch(url, {
      method,
      headers: body ? { "Content-Type": "application/json" } : {},
      body: body ? JSON.stringify(body) : undefined,
      signal: controller.signal,
    });
    clearTimeout(timeout);
    return await response.json();
  } catch (error) {
    clearTimeout(timeout);
    if (error.name === "AbortError") {
      return { error: "AI_GATEWAY_TIMEOUT", message: "AI Gateway request timed out", status: "unavailable" };
    }
    return { error: "AI_GATEWAY_ERROR", message: error.message, status: "unavailable" };
  }
}

// ===== ENDPOINTS =====

/**
 * POST /analyze/call
 * Complete call analysis: STT → Scam Classification → Phone Reputation → Deepfake → Risk Score
 */
router.post("/analyze/call", authenticateJWT, upload.single("audio"), async (req, res, next) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: "VALIDATION_ERROR", message: "Audio file is required" });
    }

    const { phone_number, language } = req.body;
    const formBody = {};
    if (phone_number) formBody.phone_number = phone_number;
    if (language) formBody.language = language;
    else formBody.language = "auto";

    const result = await callAIGateway("/analyze/call", "POST", formBody, req.file);

    // If analysis found scam, auto-create a fraud report
    if (result.risk_score && result.risk_score >= 50) {
      try {
        const transcript = result.transcript || "";
        await mongoose.models.FraudReport.create({
          userId: req.user.sub,
          reportType: "call",
          status: "open",
          riskScore: result.risk_score,
          riskLevel: result.risk_level || "high",
          description: `AI-detected scam: ${result.scam_classification?.primary_type || "Unknown"} (Risk: ${result.risk_score})`,
          metadata: {
            phoneNumber: phone_number || "unknown",
            scamType: result.scam_classification?.primary_type,
            transcript: transcript.substring(0, 2000),
            deepfakeDetected: result.deepfake_analysis?.is_deepfake,
            aiAnalysisSummary: JSON.stringify(result).substring(0, 500),
          },
          createdAt: new Date(),
        });

        // Also create a case for high-risk calls
        if (result.risk_score >= 70) {
          await mongoose.models.Case.create({
            title: `AI-Detected Scam Call: ${phone_number || "Unknown"}`,
            description: `Automatically generated case from AI call analysis.\nScam Type: ${result.scam_classification?.primary_type || "Unknown"}\nRisk Score: ${result.risk_score}\nTranscript: ${(transcript || "").substring(0, 3000)}`,
            caseType: "call_fraud",
            status: "open",
            priority: "critical",
            riskScore: result.risk_score,
            relatedNumbers: phone_number ? [phone_number] : [],
            source: "ai_detection",
            complainantId: req.user.sub,
          });
        }
      } catch (dbError) {
        // Non-critical - don't fail the response
        console.error("Failed to create auto-report:", dbError.message);
      }
    }

    res.json({
      success: true,
      data: result,
      message: result.risk_score >= 70 ? "HIGH RISK SCAM DETECTED" : result.risk_score >= 40 ? "Suspicious activity detected" : "Call appears safe",
    });
  } catch (error) {
    next(error);
  }
});

/**
 * POST /analyze/text
 * Analyze text for scam indicators (used for SMS, WhatsApp, chat analysis)
 */
router.post("/analyze/text", authenticateJWT, async (req, res, next) => {
  try {
    const { text, language, phone_number, url, upi_id } = req.body;
    if (!text) {
      return res.status(400).json({ error: "VALIDATION_ERROR", message: "Text is required" });
    }

    const result = await callAIGateway("/analyze/full", "POST", {
      text,
      language: language || "auto",
      phone_number: phone_number || "",
      url: url || "",
      upi_id: upi_id || "",
    });

    // If scam detected, log to fraud reports
    if (result.risk_score?.risk_score >= 50) {
      await mongoose.models.FraudReport.create({
        userId: req.user.sub,
        reportType: url ? "url" : upi_id ? "upi" : "text",
        status: "open",
        riskScore: result.risk_score.risk_score,
        riskLevel: result.risk_score.category,
        description: `AI-detected: ${result.scam_classification?.primary_scam_type || "Suspicious content"}`,
        metadata: { textPreview: text.substring(0, 500), ...result.scam_classification },
      }).catch(() => {});
    }

    res.json({
      success: true,
      analysis: result.scam_classification,
      risk_score: result.risk_score,
      phone_reputation: result.phone_reputation,
      url_analysis: result.url_analysis,
      overall_verdict: result.overall_verdict,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * POST /analyze/sms
 * Analyze SMS for scam indicators
 */
router.post("/analyze/sms", authenticateJWT, async (req, res, next) => {
  try {
    const { text, sender } = req.body;
    if (!text) {
      return res.status(400).json({ error: "VALIDATION_ERROR", message: "SMS text is required" });
    }

    const result = await callAIGateway("/analyze/sms", "POST", null, null, { text, sender: sender || "" });

    if (result.is_scam) {
      await mongoose.models.SmsLog.create({
        fromNumber: sender || "unknown",
        messageBody: text.substring(0, 1000),
        userId: req.user.sub,
        classification: "fraud",
        riskScore: result.risk_score,
        aiAnalysis: { scamType: result.scam_type, urlsFound: result.urls_found },
        status: "blocked",
      }).catch(() => {});
    }

    res.json({ success: true, ...result });
  } catch (error) {
    next(error);
  }
});

/**
 * POST /analyze/whatsapp
 * Analyze WhatsApp message
 */
router.post("/analyze/whatsapp", authenticateJWT, async (req, res, next) => {
  try {
    const { text, sender } = req.body;
    if (!text) {
      return res.status(400).json({ error: "VALIDATION_ERROR", message: "Message text is required" });
    }

    const result = await callAIGateway("/analyze/whatsapp", "POST", null, null, { text, sender: sender || "" });

    if (result.is_scam) {
      await mongoose.models.WhatsappAnalysis.create({
        senderNumber: sender || "unknown",
        messageBody: text.substring(0, 1000),
        userId: req.user.sub,
        classification: "fraud",
        riskScore: result.risk_score,
        aiAnalysis: { scamType: result.scam_type, indicators: result.whatsapp_indicators },
        status: "blocked",
      }).catch(() => {});
    }

    res.json({ success: true, ...result });
  } catch (error) {
    next(error);
  }
});

/**
 * GET /health
 * Check AI Gateway health
 */
router.get("/health", async (_req, res) => {
  const health = await callAIGateway("/health");
  res.json({
    service: "raksaar-ai-routes",
    ai_gateway: health.status || "unreachable",
    services: health.services || {},
  });
});

/**
 * GET /threat-intel/phone/:number
 * Get threat intelligence for a phone number
 */
router.get("/threat-intel/phone/:number", authenticateJWT, async (req, res, next) => {
  try {
    const { number } = req.params;
    // Check local fraud database first
    const fraudNumber = await mongoose.models.FraudNumber.findOne({ phoneNumber: number });
    const reports = await mongoose.models.FraudReport.countDocuments({ "metadata.phoneNumber": number });
    const riskScore = await mongoose.models.RiskScore.findOne({ phoneNumber: number });

    res.json({
      phone_number: number,
      in_fraud_database: !!fraudNumber,
      fraud_reports: reports || 0,
      risk_score: riskScore?.score || fraudNumber?.riskScore || 0,
      risk_category: riskScore?.category || "unknown",
      threat_level: reports >= 5 ? "critical" : reports >= 2 ? "high" : reports >= 1 ? "suspicious" : "unknown",
      last_reported: fraudNumber?.updatedAt || null,
      recommendation: reports >= 3 ? "BLOCK immediately" : reports >= 1 ? "Flag for investigation" : "No known threat",
    });
  } catch (error) {
    next(error);
  }
});

/**
 * GET /threat-intel/stats
 * Get threat intelligence statistics
 */
router.get("/threat-intel/stats", authenticateJWT, async (_req, res, next) => {
  try {
    const [totalFraudNumbers, totalCases, highRiskCases, recentReports] = await Promise.all([
      mongoose.models.FraudNumber.countDocuments(),
      mongoose.models.Case.countDocuments({ source: "ai_detection" }),
      mongoose.models.Case.countDocuments({ source: "ai_detection", status: "open", riskScore: { $gte: 70 } }),
      mongoose.models.FraudReport.countDocuments({ createdAt: { $gte: new Date(Date.now() - 86400000) } }),
    ]);

    res.json({
      total_fraud_numbers: totalFraudNumbers,
      ai_generated_cases: totalCases,
      high_risk_cases: highRiskCases,
      reports_last_24h: recentReports,
      ai_gateway_connected: true,
    });
  } catch (error) {
    next(error);
  }
});

export default router;