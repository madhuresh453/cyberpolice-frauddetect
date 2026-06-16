package com.cybershield.ai.sms;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class FraudClassifier {
    // OTP Scam patterns
    private static final Pattern OTP_SCAM_PATTERNS[] = {
            Pattern.compile("(otp|one.?time.?password|verification.?code|auth.?code)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("(share|send|tell).*otp", Pattern.CASE_INSENSITIVE),
            Pattern.compile("otp.*?(share|send|tell)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("(never.share|do.not.share).*otp", Pattern.CASE_INSENSITIVE),
            Pattern.compile("(enter.*otp|verify.*otp|confirm.*otp)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("(amazon|flipkart|swiggy|zomato|paytm|gpay|phonepe).*otp", Pattern.CASE_INSENSITIVE),
    };

    // KYC Scam patterns
    private static final Pattern KYC_SCAM_PATTERNS[] = {
            Pattern.compile("(kyc|know.your.customer)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("(aadhaar|pan.card|voter.id).*?(update|verify|link|expire)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("(update|verify|complete).*?(aadhaar|pan|kyc)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("(kyc.expired|kyc.pending|kyc.verification)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("(sebi|rbi|trai).*?(kyc|update|verify)", Pattern.CASE_INSENSITIVE),
    };

    // Bank scam patterns
    private static final Pattern BANK_SCAM_PATTERNS[] = {
            Pattern.compile("(bank|netbanking|net.banking|internet.banking).*?(update|verify|login|account|suspend)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("(hdfc|sbi|icici|bob|pnb|axis|kotak|yes.bank|canara|union.bank)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("(account.?suspended|account.?blocked|account.?locked|account.?freeze)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("(verify.?bank|bank.?verify|link.?bank|bank.?link)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("(debit.?card|credit.?card|atm.?pin).*?(block|verify|update|expire)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("(neft|imps|rtgs|upi).*?(pending|failed|reversed|verify)", Pattern.CASE_INSENSITIVE),
    };

    // Fake delivery scam patterns
    private static final Pattern DELIVERY_SCAM_PATTERNS[] = {
            Pattern.compile("(delivery|courier|parcel|package|shipment)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("(amazon|flipkart|meesho|myntra|jio.mart)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("(track|tracking|track.your|order.status)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("(delivery.fee|shipping.charge|cod.payment|delivery.payment)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("(india.post|delhivery|bluedart|ekart|shadowfax)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("(redeliver|reschedule|missed.delivery|address.issue)", Pattern.CASE_INSENSITIVE),
    };

    // Investment scam patterns
    private static final Pattern INVESTMENT_SCAM_PATTERNS[] = {
            Pattern.compile("(invest|investment|trading|stock|mutual.fund)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("(guaranteed.return|high.return|double.money|earn.money)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("(crypto|bitcoin|ethereum|nft|web3|defi)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("(sebi.registered|registered.with.sebi|rbi.approved)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("(scheme|plan|mlm|network.marketing|referral)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("(join.now|act.now|limited.offer|last.chance)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("(profit|returns|dividend|daily.earn)", Pattern.CASE_INSENSITIVE),
    };

    public String classify(String sender, String messageBody, String expandedUrl,
                           boolean maliciousUrl, boolean containsApk) {
        if (containsApk) return "APK_MALWARE";
        if (maliciousUrl) {
            String classified = classifyByUrlPatterns(messageBody);
            if (!"UNKNOWN".equals(classified)) return classified;
        }

        int otpScore = matchPatterns(messageBody, OTP_SCAM_PATTERNS);
        int kycScore = matchPatterns(messageBody, KYC_SCAM_PATTERNS);
        int bankScore = matchPatterns(messageBody, BANK_SCAM_PATTERNS);
        int deliveryScore = matchPatterns(messageBody, DELIVERY_SCAM_PATTERNS);
        int investmentScore = matchPatterns(messageBody, INVESTMENT_SCAM_PATTERNS);

        int maxScore = Math.max(Math.max(Math.max(otpScore, kycScore), Math.max(bankScore, deliveryScore)), investmentScore);

        if (maxScore == 0) return "UNKNOWN";
        if (maxScore == otpScore) return "OTP_SCAM";
        if (maxScore == kycScore) return "KYC_SCAM";
        if (maxScore == bankScore) return "BANK_SCAM";
        if (maxScore == deliveryScore) return "DELIVERY_SCAM";
        if (maxScore == investmentScore) return "INVESTMENT_SCAM";

        return "UNKNOWN";
    }

    private String classifyByUrlPatterns(String messageBody) {
        String lower = messageBody.toLowerCase();
        if (lower.contains("kyc") || lower.contains("aadhaar")) return "KYC_SCAM";
        if (lower.contains("otp") || lower.contains("verification")) return "OTP_SCAM";
        if (lower.contains("bank") || lower.contains("netbanking")) return "BANK_SCAM";
        if (lower.contains("delivery") || lower.contains("courier")) return "DELIVERY_SCAM";
        if (lower.contains("invest") || lower.contains("crypto")) return "INVESTMENT_SCAM";
        return "UNKNOWN";
    }

    private int matchPatterns(String text, Pattern[] patterns) {
        if (text == null || text.isEmpty()) return 0;
        int score = 0;
        for (Pattern pattern : patterns) {
            Matcher matcher = pattern.matcher(text);
            if (matcher.find()) {
                score += 10;
            }
        }
        return score;
    }

    /**
     * Analyze a phone number for fraud risk.
     * Returns risk score 0-100.
     */
    public int analyzeNumber(String number) {
        if (number == null || number.isEmpty()) return 0;
        int score = 0;
        String n = number.replaceAll("[^0-9+]", "");

        // Premium rate numbers (Indian)
        if (n.startsWith("+919") && n.length() == 13) {
            // Check for suspicious patterns in the number itself
            String digits = n.substring(4);
            // Repeated digits (e.g., 9999999999)
            if (digits.length() >= 4) {
                char first = digits.charAt(0);
                boolean allSame = true;
                for (int i = 1; i < Math.min(digits.length(), 6); i++) {
                    if (digits.charAt(i) != first) { allSame = false; break; }
                }
                if (allSame) score += 15;
            }
        }

        // Short codes are generally safe
        if (n.length() <= 5) return Math.min(score, 10);

        // Numbers starting with specific suspicious patterns
        if (n.contains("140") || n.contains("1800") || n.contains("1860")) {
            score += 5; // Could be legitimate telemarketing
        }

        // International numbers pretending to be Indian
        if (n.startsWith("+1") || n.startsWith("+44") || n.startsWith("+61")) {
            score += 20; // Suspicious for Indian context
        }

        return Math.min(score, 100);
    }

    /**
     * Analyze text content for fraud indicators.
     * Returns risk score 0-100.
     */
    public int analyzeText(String text) {
        if (text == null || text.isEmpty()) return 0;
        int score = 0;

        // OTP scam patterns
        String[] highRiskKeywords = {
            "otp", "one time password", "verification code",
            "kyc", "pan", "aadhaar", "bank account",
            "account suspended", "account blocked", "account locked",
            "urgent", "immediately", "within 24 hours",
            "click here", "click link", "verify now",
            "lottery", "won prize", "congratulations you won",
            "investment", "guaranteed returns", "double money",
            "crypto", "bitcoin", "investment opportunity",
            "remote access", "screen share", "anydesk", "teamviewer",
            "upi", "gpay", "phonepe", "paytm",
            "reward", "prize", "cashback",
            "refund", "tax refund", "income tax refund"
        };

        String lower = text.toLowerCase();
        for (String keyword : highRiskKeywords) {
            if (lower.contains(keyword)) {
                score += 8;
            }
        }

        // URL patterns
        if (lower.contains("http") || lower.contains("bit.ly") || lower.contains("tinyurl")) {
            score += 10;
        }

        // Urgency patterns
        if (lower.contains("act now") || lower.contains("limited time") || lower.contains("last chance")) {
            score += 15;
        }

        // Fear tactics
        if (lower.contains("legal action") || lower.contains("police") || lower.contains("arrest")) {
            score += 20;
        }

        return Math.min(score, 100);
    }
}
