import mongoose from "mongoose";

export async function calculateTrustScore(phoneNumber) {
  try {
    const [citizen, fraudReports, blockedEntries, casesInvolved, freezeRequests, trafficLogs, smsLogs, upiComplaints, existingTrustScore, existingRiskScore] = await Promise.all([
      mongoose.models.Citizen.findOne({ phoneNumber }).lean(),
      mongoose.models.FraudReport.countDocuments({ "metadata.phoneNumber": phoneNumber }),
      mongoose.models.BlockedNumber.countDocuments({ phoneNumber }),
      mongoose.models.Case.countDocuments({ relatedNumbers: phoneNumber }),
      mongoose.models.FreezeRequest.countDocuments({ accountNumber: phoneNumber }),
      mongoose.models.TrafficLog.aggregate([
        { $match: { $or: [{ fromNumber: phoneNumber }, { toNumber: phoneNumber }] } },
        { $count: "total" }
      ]),
      mongoose.models.SmsLog.aggregate([
        { $match: { $or: [{ fromNumber: phoneNumber }, { toNumber: phoneNumber }] } },
        { $group: { _id: "$classification", count: { $sum: 1 } } }
      ]),
      mongoose.models.UpiVerification.countDocuments({ phoneNumber }),
      mongoose.models.TrustScore.findOne({ phoneNumber }).lean(),
      mongoose.models.RiskScore.findOne({ phoneNumber }).lean()
    ]);

    // Scoring factors with weights
    const weights = {
      fraudReports: -15,
      blockedEntries: -10,
      casesInvolved: -20,
      freezeRequests: -25,
      smsFraudRatio: -10,
      trafficAnomaly: -5,
      upiComplaints: -8,
      verifiedIdentity: 15,
      familyProtection: 10,
      reportResolution: 12
    };

    let score = 50; // Base score
    let reasons = [];
    let riskFactors = [];

    // Negative factors
    if (fraudReports > 0) {
      const penalty = Math.min(fraudReports * weights.fraudReports, -50);
      score += penalty;
      reasons.push(`Reported in ${fraudReports} fraud reports`);
      riskFactors.push({ factor: "fraud_reports", impact: penalty, details: `${fraudReports} reports` });
    }

    if (blockedEntries > 0) {
      const penalty = Math.min(blockedEntries * weights.blockedEntries, -30);
      score += penalty;
      reasons.push(`Blocked by ${blockedEntries} users`);
      riskFactors.push({ factor: "blocked", impact: penalty, details: `${blockedEntries} blocks` });
    }

    if (casesInvolved > 0) {
      const penalty = Math.min(casesInvolved * weights.casesInvolved, -60);
      score += penalty;
      reasons.push(`Involved in ${casesInvolved} cases`);
      riskFactors.push({ factor: "cases", impact: penalty, details: `${casesInvolved} cases` });
    }

    if (freezeRequests > 0) {
      const penalty = Math.min(freezeRequests * weights.freezeRequests, -50);
      score += penalty;
      reasons.push(`${freezeRequests} freeze requests against this number`);
      riskFactors.push({ factor: "freeze_requests", impact: penalty, details: `${freezeRequests} requests` });
    }

    // SMS analysis
    if (smsLogs.length > 0) {
      const fraudSmsCount = smsLogs.find(s => s._id === "fraud")?.count || 0;
      const totalSms = smsLogs.reduce((acc, s) => acc + s.count, 0);
      if (totalSms > 0 && fraudSmsCount / totalSms > 0.3) {
        const penalty = weights.smsFraudRatio;
        score += penalty;
        reasons.push(`High fraud SMS ratio (${Math.round(fraudSmsCount / totalSms * 100)}%)`);
        riskFactors.push({ factor: "sms_fraud_ratio", impact: penalty, details: `${fraudSmsCount}/${totalSms} fraud` });
      }
    }

    // UPI complaints
    if (upiComplaints > 0) {
      const penalty = Math.min(upiComplaints * weights.upiComplaints, -20);
      score += penalty;
      reasons.push(`${upiComplaints} UPI complaints`);
      riskFactors.push({ factor: "upi_complaints", impact: penalty, details: `${upiComplaints} complaints` });
    }

    // Positive factors
    if (citizen) {
      // Verified identity
      if (citizen.verificationStatus === "verified") {
        score += weights.verifiedIdentity;
        reasons.push("Identity verified");
      }
      // Family protection enabled
      if (citizen.preferences?.familyProtection) {
        score += weights.familyProtection;
        reasons.push("Family protection active");
      }
      // KYC completed
      if (citizen.kycStatus === "completed") {
        score += 8;
        reasons.push("KYC completed");
      }
      // Trust graph from existing records
      if (citizen.totalReports > 0 && citizen.trustScore > 50) {
        score += Math.min(citizen.totalReports * 2, 10);
        reasons.push("Positive reporting history");
      }
    }

    // Existing trust score smoothing
    if (existingTrustScore) {
      score = (score * 0.7) + (existingTrustScore.score * 0.3);
    }

    // Ensure bounds
    score = Math.max(0, Math.min(100, Math.round(score)));

    // Determine risk category
    let category;
    if (score >= 80) category = "safe";
    else if (score >= 60) category = "low";
    else if (score >= 40) category = "medium";
    else if (score >= 20) category = "high";
    else category = "critical";

    // Build historical trend
    const thirtyDaysAgo = new Date(Date.now() - 30 * 86400000);
    const reportHistory = await mongoose.models.FraudReport.aggregate([
      { $match: { "metadata.phoneNumber": phoneNumber, createdAt: { $gte: thirtyDaysAgo } } },
      { $group: { _id: { $dateToString: { format: "%Y-%m-%d", date: "$createdAt" } }, count: { $sum: 1 } } },
      { $sort: { _id: 1 } },
      { $limit: 30 }
    ]);

    // Save to database
    await mongoose.models.TrustScore.findOneAndUpdate(
      { phoneNumber },
      {
        phoneNumber,
        score,
        category,
        reasons: reasons.slice(0, 10),
        riskFactors,
        lastCalculated: new Date(),
        trend: reportHistory.map(r => ({ date: r._id, count: r.count }))
      },
      { upsert: true, new: true }
    );

    await mongoose.models.RiskScore.findOneAndUpdate(
      { phoneNumber },
      {
        phoneNumber,
        score: 100 - score,
        category,
        factors: riskFactors,
        lastCalculated: new Date()
      },
      { upsert: true, new: true }
    );

    return {
      trust_score: score,
      risk_category: category,
      reasons: reasons.slice(0, 10),
      risk_factors: riskFactors.slice(0, 5),
      trend: reportHistory.map(r => ({ date: r._id, count: r.count })),
      calculated_at: new Date().toISOString()
    };
  } catch (error) {
    console.error(JSON.stringify({ level: "error", message: "Trust score calculation failed", phoneNumber, error: error.message }));
    return { trust_score: 50, risk_category: "unknown", reasons: ["Calculation error"], risk_factors: [], trend: [], calculated_at: new Date().toISOString() };
  }
}

export async function getTrustScore(phoneNumber) {
  const trustScore = await mongoose.models.TrustScore.findOne({ phoneNumber }).lean();
  const riskScore = await mongoose.models.RiskScore.findOne({ phoneNumber }).lean();
  const citizen = await mongoose.models.Citizen.findOne({ phoneNumber }).lean();

  return {
    phone_number: phoneNumber,
    trust_score: trustScore?.score ?? 50,
    risk_score: riskScore?.score ?? 50,
    risk_category: riskScore?.category ?? "unknown",
    reasons: trustScore?.reasons || [],
    risk_factors: riskScore?.factors || [],
    verification_status: citizen?.verificationStatus ?? "unverified",
    trend: trustScore?.trend || [],
    last_calculated: trustScore?.lastCalculated ?? null
  };
}

export async function batchCalculateTrustScores(phoneNumbers) {
  const results = [];
  for (const phone of phoneNumbers) {
    try {
      const result = await calculateTrustScore(phone);
      results.push({ phone_number: phone, ...result });
    } catch (err) {
      results.push({ phone_number: phone, trust_score: 50, error: err.message });
    }
  }
  return results;
}

export async function getTrustScoreHistory(phoneNumber, days = 90) {
  const since = new Date(Date.now() - days * 86400000);
  const scores = await mongoose.models.TrustScore.find({
    phoneNumber,
    lastCalculated: { $gte: since }
  }).sort({ lastCalculated: 1 }).lean();

  return scores.map(s => ({
    date: s.lastCalculated,
    score: s.score,
    category: s.category
  }));
}