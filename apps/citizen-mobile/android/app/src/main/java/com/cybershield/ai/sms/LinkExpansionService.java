package com.cybershield.ai.sms;

import android.util.Log;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.InetAddress;
import java.net.URL;
import java.net.URLDecoder;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class LinkExpansionService {
    private static final String TAG = "LinkExpansion";
    private static final int MAX_REDIRECTS = 10;
    private static final int TIMEOUT_MS = 5000;

    private static final Pattern SHORTENER_PATTERN = Pattern.compile(
            "(bit\\.ly|tinyurl\\.com|t\\.co|goo\\.gl|is\\.gd|buff\\.ly|ow\\.ly|rb\\.gy|cutt\\.ly|shorturl\\.at|"
                    + "bit\\.do|shorte\\.st|cl\\.ly|rebrand\\.ly|bl\\.ink|lnkd\\.in|tiny\\.cc|v\\.gd|qr\\.ae|adf\\.ly)",
            Pattern.CASE_INSENSITIVE
    );

    private static final Pattern URL_PATTERN = Pattern.compile(
            "(https?://[\\w\\-._~:/?#\\[\\]@!$&'()*+,;=%]+)",
            Pattern.CASE_INSENSITIVE
    );

    private final Set<String> maliciousDomains = new HashSet<>();

    public LinkExpansionService() {
        loadMaliciousDomains();
    }

    private void loadMaliciousDomains() {
        maliciousDomains.add("suspicious-bank-login.com");
        maliciousDomains.add("verify-account-now.net");
        maliciousDomains.add("kyc-update.in");
        maliciousDomains.add("claim-prize.in");
        maliciousDomains.add("free-airdrop-crypto.com");
        maliciousDomains.add("fake-delivery-tracker.com");
        maliciousDomains.add("paytm-update-kyc.in");
        maliciousDomains.add("phonepe-verify.in");
        maliciousDomains.add("google-play-update.xyz");
        maliciousDomains.add("upi-payment-received.xyz");
        maliciousDomains.add("adhaar-update.in");
    }

    public String expandUrl(String shortUrl) {
        if (shortUrl == null || shortUrl.isEmpty()) return shortUrl;

        if (!isShortenerUrl(shortUrl)) return shortUrl;

        Set<String> visited = new HashSet<>();
        String currentUrl = shortUrl;
        int redirectCount = 0;

        try {
            while (redirectCount < MAX_REDIRECTS) {
                if (visited.contains(currentUrl)) break;
                visited.add(currentUrl);

                URL url = new URL(currentUrl);
                HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                conn.setRequestMethod("HEAD");
                conn.setInstanceFollowRedirects(false);
                conn.setConnectTimeout(TIMEOUT_MS);
                conn.setReadTimeout(TIMEOUT_MS);
                conn.setRequestProperty("User-Agent", "CyberShield-LinkChecker/1.0");

                int responseCode = conn.getResponseCode();
                if (responseCode >= 300 && responseCode < 400) {
                    String location = conn.getHeaderField("Location");
                    if (location == null) break;

                    if (location.startsWith("/")) {
                        String base = url.getProtocol() + "://" + url.getHost();
                        location = base + location;
                    }
                    currentUrl = URLDecoder.decode(location, "UTF-8");
                    redirectCount++;
                } else {
                    break;
                }
            }
        } catch (IOException e) {
            Log.e(TAG, "Error expanding URL: " + shortUrl, e);
        }

        return currentUrl;
    }

    public List<String> extractAllUrls(String text) {
        List<String> urls = new ArrayList<>();
        if (text == null || text.isEmpty()) return urls;

        Matcher matcher = URL_PATTERN.matcher(text);
        while (matcher.find()) {
            String url = matcher.group(1);
            if (url != null && !url.isEmpty()) {
                urls.add(url);
            }
        }

        // Also check for bit.ly style text without http prefix
        Pattern bareShortener = Pattern.compile(
                "(bit\\.ly/\\w+|tinyurl\\.com/\\w+|t\\.co/\\w+|goo\\.gl/\\w+|shorturl\\.at/\\w+|v\\.gd/\\w+|cutt\\.ly/\\w+)",
                Pattern.CASE_INSENSITIVE
        );
        Matcher bareMatcher = bareShortener.matcher(text);
        while (bareMatcher.find()) {
            String bareUrl = bareMatcher.group(1);
            if (bareUrl != null && !urls.contains("http://" + bareUrl)) {
                urls.add("https://" + bareUrl);
            }
        }

        return urls;
    }

    public boolean isShortenerUrl(String url) {
        if (url == null) return false;
        return SHORTENER_PATTERN.matcher(url).find();
    }

    public List<String> getRedirectChain(String url) {
        List<String> chain = new ArrayList<>();
        if (url == null || url.isEmpty()) return chain;

        Set<String> visited = new HashSet<>();
        String currentUrl = url;
        int redirectCount = 0;

        try {
            while (redirectCount < MAX_REDIRECTS) {
                if (visited.contains(currentUrl)) break;
                visited.add(currentUrl);
                chain.add(currentUrl);

                URL u = new URL(currentUrl);
                HttpURLConnection conn = (HttpURLConnection) u.openConnection();
                conn.setRequestMethod("HEAD");
                conn.setInstanceFollowRedirects(false);
                conn.setConnectTimeout(TIMEOUT_MS);
                conn.setReadTimeout(TIMEOUT_MS);

                int responseCode = conn.getResponseCode();
                if (responseCode >= 300 && responseCode < 400) {
                    String location = conn.getHeaderField("Location");
                    if (location == null) break;
                    if (location.startsWith("/")) {
                        String base = u.getProtocol() + "://" + u.getHost();
                        location = base + location;
                    }
                    currentUrl = location;
                    redirectCount++;
                } else {
                    break;
                }
            }
        } catch (IOException e) {
            Log.e(TAG, "Error tracing redirect chain", e);
        }

        return chain;
    }
}