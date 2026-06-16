package com.cybershield.ai.sms;

import java.util.HashSet;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class MaliciousUrlDetector {
    private static final Pattern URL_PATTERN = Pattern.compile(
            "(https?://[\\w\\-._~:/?#\\[\\]@!$&'()*+,;=%]+)", Pattern.CASE_INSENSITIVE
    );

    private final Set<String> knownMaliciousDomains = new HashSet<>();
    private final Set<String> suspiciousTlds = new HashSet<>();

    public MaliciousUrlDetector() {
        loadKnownMaliciousDomains();
        loadSuspiciousTlds();
    }

    private void loadKnownMaliciousDomains() {
        // Known fraudulent bank domains
        String[] malicious = {
                "suspicious-bank-login.com", "verify-account-now.net", "kyc-update.in",
                "claim-prize.in", "free-airdrop-crypto.com", "fake-delivery-tracker.com",
                "paytm-update-kyc.in", "phonepe-verify.in", "google-play-update.xyz",
                "upi-payment-received.xyz", "adhaar-update.in", "otp-verify.in",
                "bank-secure-login.com", "hdfc-netbanking-verify.com", "sbi-update-kyc.in",
                "icici-secure-verify.in", "bob-verify-account.in", "pnb-update-kyc.in",
                "axis-secure-login.com", "kotak-verify-now.in", "yes-bank-update.com",
                "fraud-claim-reward.com", "winner-notification.in", "lottery-winner.in",
                "crypto-airdrop.xyz", "claim-tokens-now.com", "free-ucooin.com",
                "courier-delivery.com", "amazon-delivery.in", "flipkart-track.in",
                "india-post-delivery.in", "meesho-order.in", "myntra-discount.in",
                "upi-fraud.com", "gpay-received.com", "phonepe-payment.xyz",
                "invest-now-scheme.com", "guaranteed-returns.in", "double-money.xyz",
                "sebi-approved.xyz", "trading-profit.com", "stock-tips-free.in"
        };
        for (String domain : malicious) {
            knownMaliciousDomains.add(domain);
        }
    }

    private void loadSuspiciousTlds() {
        suspiciousTlds.add("xyz");
        suspiciousTlds.add("top");
        suspiciousTlds.add("club");
        suspiciousTlds.add("pw");
        suspiciousTlds.add("tk");
        suspiciousTlds.add("ml");
        suspiciousTlds.add("ga");
        suspiciousTlds.add("cf");
        suspiciousTlds.add("gq");
        suspiciousTlds.add("buzz");
        suspiciousTlds.add("work");
        suspiciousTlds.add("space");
    }

    public boolean containsUrl(String messageBody) {
        if (messageBody == null) return false;
        return URL_PATTERN.matcher(messageBody).find();
    }

    public String extractFirstUrl(String messageBody) {
        if (messageBody == null) return "";
        Matcher matcher = URL_PATTERN.matcher(messageBody);
        if (matcher.find()) {
            return matcher.group(1);
        }
        return "";
    }

    public boolean isMaliciousUrl(String url) {
        if (url == null || url.isEmpty()) return false;

        String domain = extractDomain(url);
        if (domain == null) return false;

        // Check known malicious domains
        if (knownMaliciousDomains.contains(domain.toLowerCase())) return true;

        // Check subdomains of known malicious domains
        for (String malicious : knownMaliciousDomains) {
            if (domain.toLowerCase().endsWith("." + malicious)) return true;
        }

        // Check for suspicious TLD
        int lastDot = domain.lastIndexOf('.');
        if (lastDot >= 0) {
            String tld = domain.substring(lastDot + 1).toLowerCase();
            if (suspiciousTlds.contains(tld)) {
                // Additional heuristics for suspicious TLDs
                if (domain.contains("bank") || domain.contains("verify") || domain.contains("kyc")
                        || domain.contains("otp") || domain.contains("login")
                        || domain.contains("secure") || domain.contains("update")) {
                    return true;
                }
            }
        }

        // Check for typosquatting of known brands
        if (isTyposquatting(domain)) return true;

        // Check for IP address URLs (phishing indicator)
        if (domain.matches("\\d+\\.\\d+\\.\\d+\\.\\d+")) return true;

        return false;
    }

    private boolean isTyposquatting(String domain) {
        String[] knownBrands = {
                "google", "facebook", "whatsapp", "instagram", "telegram",
                "hdfcbank", "sbibank", "icicibank", "paytm", "phonepe", "gpay",
                "googlepay", "amazon", "flipkart", "meesho", "jio", "airtel"
        };

        String normalized = domain.toLowerCase().replaceAll("[^a-z]", "");
        for (String brand : knownBrands) {
            int distance = levenshteinDistance(normalized, brand);
            if (distance > 0 && distance <= 2) {
                return true;
            }
        }
        return false;
    }

    private int levenshteinDistance(String s1, String s2) {
        if (s1.isEmpty() || s2.isEmpty()) {
            return Math.max(s1.length(), s2.length());
        }
        int[] prev = new int[s2.length() + 1];
        for (int j = 0; j <= s2.length(); j++) {
            prev[j] = j;
        }
        for (int i = 1; i <= s1.length(); i++) {
            int[] curr = new int[s2.length() + 1];
            curr[0] = i;
            for (int j = 1; j <= s2.length(); j++) {
                int cost = s1.charAt(i - 1) == s2.charAt(j - 1) ? 0 : 1;
                curr[j] = Math.min(
                        Math.min(curr[j - 1] + 1, prev[j] + 1),
                        prev[j - 1] + cost
                );
            }
            prev = curr;
        }
        return prev[s2.length()];
    }

    private String extractDomain(String url) {
        try {
            java.net.URL parsed = new java.net.URL(url);
            return parsed.getHost();
        } catch (Exception e) {
            // Fallback: extract manually
            String stripped = url;
            if (stripped.startsWith("http://")) stripped = stripped.substring(7);
            if (stripped.startsWith("https://")) stripped = stripped.substring(8);
            int slashIndex = stripped.indexOf('/');
            if (slashIndex > 0) stripped = stripped.substring(0, slashIndex);
            int atSign = stripped.indexOf('@');
            if (atSign > 0) stripped = stripped.substring(atSign + 1);
            int colon = stripped.indexOf(':');
            if (colon > 0) stripped = stripped.substring(0, colon);
            return stripped;
        }
    }
}