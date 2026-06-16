package com.cybershield.ai.sms;

import android.content.Context;
import android.util.Log;

import com.cybershield.ai.evidence.EvidenceHashService;

public class SmsScanner {
    private static final String TAG = "SmsScanner";
    private final Context context;
    private final MaliciousUrlDetector urlDetector;
    private final LinkExpansionService linkExpander;
    private final FraudClassifier fraudClassifier;
    private final APKScanner apkScanner;
    private final EvidenceHashService evidenceService;

    public SmsScanner(Context context) {
        this.context = context;
        this.urlDetector = new MaliciousUrlDetector();
        this.linkExpander = new LinkExpansionService();
        this.fraudClassifier = new FraudClassifier();
        this.apkScanner = new APKScanner();
        this.evidenceService = EvidenceHashService.getInstance(context);
    }

    public void analyzeSms(String sender, String messageBody) {
        Log.d(TAG, "Analyzing SMS from: " + sender);

        boolean containsUrl = urlDetector.containsUrl(messageBody);
        String expandedUrl = "";
        if (containsUrl) {
            String rawUrl = urlDetector.extractFirstUrl(messageBody);
            expandedUrl = linkExpander.expandUrl(rawUrl);
        }

        boolean isMaliciousUrl = containsUrl && urlDetector.isMaliciousUrl(expandedUrl);
        boolean containsApk = apkScanner.detectApkReference(messageBody, expandedUrl);
        boolean isApkMalicious = containsApk && apkScanner.isMaliciousDownload(expandedUrl);
        String fraudType = fraudClassifier.classify(sender, messageBody, expandedUrl, isMaliciousUrl, containsApk);
        int riskScore = computeRiskScore(isMaliciousUrl, containsApk, isApkMalicious, fraudType);

        String sessionId = java.util.UUID.randomUUID().toString();
        evidenceService.logSmsEvent(sessionId, sender, messageBody, riskScore, fraudType);
        notifyUser(sender, messageBody, riskScore, fraudType);
    }

    private int computeRiskScore(boolean maliciousUrl, boolean containsApk, boolean apkMalicious, String fraudType) {
        int score = 0;

        if (maliciousUrl) score += 30;
        if (containsApk) score += 20;
        if (apkMalicious) score += 20;
        if (containsApk && apkMalicious) score += 10;

        switch (fraudType) {
            case "OTP_SCAM": score += 40; break;
            case "KYC_SCAM": score += 35; break;
            case "BANK_SCAM": score += 35; break;
            case "DELIVERY_SCAM": score += 25; break;
            case "INVESTMENT_SCAM": score += 30; break;
            case "APK_MALWARE": score += 45; break;
            default: score += 5; break;
        }

        return Math.min(score, 100);
    }

    private void notifyUser(String sender, String message, int riskScore, String fraudType) {
        Log.w(TAG, "Fraud SMS detected: type=" + fraudType + " risk=" + riskScore + "% sender=" + sender);

        android.content.Intent intent = new android.content.Intent(context, com.cybershield.ai.overlay.FraudAlertOverlay.class);
        intent.putExtra("risk_score", riskScore);
        intent.putExtra("risk_level", riskScore >= 70 ? "RED" : riskScore >= 40 ? "YELLOW" : "GREEN");
        intent.putExtra("phone_number", sender);
        intent.putExtra("session_id", java.util.UUID.randomUUID().toString());
        intent.putExtra("type", "sms");
        intent.putExtra("fraud_type", fraudType);
        intent.addFlags(android.content.Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
    }
}