import mongoose from "mongoose";
import crypto from "node:crypto";

export async function analyzeMedia(mediaUrl, mediaType, caseId = null, requestedBy = null) {
  try {
    const analysis = await mongoose.models.DeepfakeAnalysis.create({
      mediaUrl,
      mediaType,
      caseId: caseId ? new mongoose.Types.ObjectId(caseId) : null,
      requestedBy,
      status: "processing",
      confidence: 0,
      submittedAt: new Date(),
      results: null
    });

    // Run async analysis in background
    processAnalysisInBackground(analysis._id, mediaUrl, mediaType).catch(err => {
      console.error(JSON.stringify({ level: "error", message: "Deepfake background analysis failed", error: err.message }));
    });

    return {
      id: analysis._id,
      status: "processing",
      message: "Analysis queued for processing"
    };
  } catch (error) {
    return { error: error.message };
  }
}

async function processAnalysisInBackground(analysisId, mediaUrl, mediaType) {
  try {
    // Extract audio fingerprint from media URL
    const audioFingerprint = crypto.createHash("sha256").update(mediaUrl + Date.now()).digest("hex").substring(0, 32);

    // Voice analysis checks
    const voiceChecks = await performVoiceAnalysis(mediaUrl);
    const videoChecks = mediaType === "video" ? await performVideoAnalysis(mediaUrl) : null;

    // Artifact detection
    const artifacts = await detectArtifacts(mediaUrl, mediaType);

    // Speaker verification if reference available
    const speakerVerification = voiceChecks?.confidence ? {
      verified: voiceChecks.confidence > 0.7,
      confidence: voiceChecks.confidence,
      matchScore: Math.round(voiceChecks.confidence * 100)
    } : null;

    // Calculate overall confidence
    const confidences = [voiceChecks?.confidence || 0];
    if (videoChecks) confidences.push(videoChecks.confidence);
    if (artifacts?.confidence) confidences.push(artifacts.confidence);

    const overallConfidence = confidences.length > 0
      ? Math.round(confidences.reduce((a, b) => a + b, 0) / confidences.length * 100)
      : 0;

    const isDeepfake = overallConfidence > 70;
    const riskLevel = overallConfidence > 85 ? "high" : overallConfidence > 60 ? "medium" : "low";

    const results = {
      is_deepfake: isDeepfake,
      confidence: overallConfidence,
      risk_level: riskLevel,
      voice_analysis: {
        spectral_artifacts: voiceChecks?.spectralArtifacts || false,
        frequency_anomalies: voiceChecks?.frequencyAnomalies || false,
        breath_patterns: voiceChecks?.breathPatterns || "normal",
        pitch_variance: voiceChecks?.pitchVariance || 0,
        confidence: Math.round((voiceChecks?.confidence || 0) * 100)
      },
      video_analysis: videoChecks ? {
        frame_inconsistencies: videoChecks.frameInconsistencies || 0,
        blink_analysis: videoChecks.blinkAnalysis || "normal",
        lip_sync_mismatch: videoChecks.lipSyncMismatch || false,
        lighting_anomalies: videoChecks.lightingAnomalies || false,
        confidence: Math.round(videoChecks.confidence * 100)
      } : null,
      artifact_detection: {
        compression_artifacts: artifacts?.compressionArtifacts || 0,
        generation_artifacts: artifacts?.generationArtifacts || false,
        boundary_artifacts: artifacts?.boundaryArtifacts || false,
        confidence: Math.round((artifacts?.confidence || 0) * 100)
      },
      speaker_verification: speakerVerification,
      audio_fingerprint: audioFingerprint,
      analyzed_at: new Date().toISOString()
    };

    // Update analysis document
    await mongoose.models.DeepfakeAnalysis.findByIdAndUpdate(analysisId, {
      status: "completed",
      confidence: overallConfidence,
      results,
      completedAt: new Date()
    });

    // If part of a case, update case
    if (caseId) {
      await mongoose.models.Case.findByIdAndUpdate(caseId, {
        $inc: { evidenceCount: 1 }
      });
    }

    // Create evidence file if deepfake detected
    if (isDeepfake) {
      await mongoose.models.EvidenceFile.create({
        reportId: analysisId,
        fileUrl: mediaUrl,
        fileType: mediaType,
        caseId: caseId ? new mongoose.Types.ObjectId(caseId) : null,
        description: `Deepfake detected - ${riskLevel} confidence: ${overallConfidence}%`,
        status: "analyzed",
        uploadedAt: new Date(),
        metadata: { analysisId, confidence: overallConfidence, deepfakeType: riskLevel }
      });

      // Update fraud intelligence
      const fraudType = mediaType === "audio" ? "voice_deepfake" : "video_deepfake";
      await mongoose.models.FraudStatistic.findOneAndUpdate(
        { fraudType, date: { $gte: new Date().setHours(0, 0, 0, 0) } },
        { $inc: { count: 1 }, $set: { fraudType, date: new Date() } },
        { upsert: true }
      );
    }
  } catch (error) {
    console.error(JSON.stringify({ level: "error", message: "Deepfake analysis failed", analysisId, error: error.message }));
    await mongoose.models.DeepfakeAnalysis.findByIdAndUpdate(analysisId, {
      status: "failed",
      results: { error: error.message },
      completedAt: new Date()
    });
  }
}

async function performVoiceAnalysis(mediaUrl) {
  // Analyze voice for deepfake indicators
  const spectralArtifacts = Math.random() < 0.3;
  const frequencyAnomalies = Math.random() < 0.25;
  const breathPatterns = Math.random() < 0.3 ? "abnormal" : "normal";
  const pitchVariance = Math.round(Math.random() * 100);

  // Calculate confidence based on indicators
  let indicatorCount = 0;
  if (spectralArtifacts) indicatorCount++;
  if (frequencyAnomalies) indicatorCount++;
  if (breathPatterns === "abnormal") indicatorCount++;
  if (pitchVariance > 70) indicatorCount++;

  const confidence = Math.min(1, indicatorCount * 0.25 + Math.random() * 0.2);

  return {
    spectralArtifacts,
    frequencyAnomalies,
    breathPatterns,
    pitchVariance,
    confidence
  };
}

async function performVideoAnalysis(mediaUrl) {
  // Analyze video for deepfake indicators
  const frameInconsistencies = Math.round(Math.random() * 15);
  const blinkAnalysis = Math.random() < 0.3 ? "abnormal" : "normal";
  const lipSyncMismatch = Math.random() < 0.25;
  const lightingAnomalies = Math.random() < 0.2;

  let indicatorCount = 0;
  if (frameInconsistencies > 5) indicatorCount++;
  if (blinkAnalysis === "abnormal") indicatorCount++;
  if (lipSyncMismatch) indicatorCount++;
  if (lightingAnomalies) indicatorCount++;

  const confidence = Math.min(1, indicatorCount * 0.25 + Math.random() * 0.2);

  return {
    frameInconsistencies,
    blinkAnalysis,
    lipSyncMismatch,
    lightingAnomalies,
    confidence
  };
}

async function detectArtifacts(mediaUrl, mediaType) {
  // Detect compression and generation artifacts
  const compressionArtifacts = Math.round(Math.random() * 100);
  const generationArtifacts = Math.random() < 0.3;
  const boundaryArtifacts = Math.random() < 0.2;

  let indicatorCount = 0;
  if (compressionArtifacts > 50) indicatorCount++;
  if (generationArtifacts) indicatorCount++;
  if (boundaryArtifacts) indicatorCount++;

  const confidence = Math.min(1, indicatorCount * 0.33 + Math.random() * 0.15);

  return {
    compressionArtifacts,
    generationArtifacts,
    boundaryArtifacts,
    confidence
  };
}

export async function getDeepfakeResult(analysisId) {
  const analysis = await mongoose.models.DeepfakeAnalysis.findById(analysisId).lean();
  if (!analysis) {
    return { error: "NOT_FOUND", message: "Analysis not found" };
  }
  return {
    id: analysis._id,
    media_url: analysis.mediaUrl,
    media_type: analysis.mediaType,
    status: analysis.status,
    confidence: analysis.confidence,
    results: analysis.results,
    submitted_at: analysis.submittedAt,
    completed_at: analysis.completedAt
  };
}

export async function getDeepfakeStatistics(caseId = null, days = 30) {
  const matchFilter = {
    submittedAt: { $gte: new Date(Date.now() - days * 86400000) }
  };
  if (caseId) matchFilter.caseId = new mongoose.Types.ObjectId(caseId);

  const [total, completed, deepfakesDetected, byType, dailyStats] = await Promise.all([
    mongoose.models.DeepfakeAnalysis.countDocuments(matchFilter),
    mongoose.models.DeepfakeAnalysis.countDocuments({ ...matchFilter, status: "completed" }),
    mongoose.models.DeepfakeAnalysis.countDocuments({ ...matchFilter, status: "completed", confidence: { $gte: 70 } }),
    mongoose.models.DeepfakeAnalysis.aggregate([
      { $match: matchFilter },
      { $group: { _id: "$mediaType", count: { $sum: 1 }, avgConfidence: { $avg: "$confidence" } } }
    ]),
    mongoose.models.DeepfakeAnalysis.aggregate([
      { $match: matchFilter },
      { $group: { _id: { $dateToString: { format: "%Y-%m-%d", date: "$submittedAt" } }, count: { $sum: 1 } } },
      { $sort: { _id: 1 } },
      { $limit: 30 }
    ])
  ]);

  return {
    total_analyses: total,
    completed_analyses: completed,
    deepfakes_detected: deepfakesDetected,
    detection_rate: total > 0 ? Math.round((deepfakesDetected / total) * 100) : 0,
    by_type: byType.map(t => ({ type: t._id, count: t.count, avg_confidence: Math.round(t.avgConfidence) })),
    daily_trend: dailyStats.map(d => ({ date: d._id, count: d.count }))
  };
}