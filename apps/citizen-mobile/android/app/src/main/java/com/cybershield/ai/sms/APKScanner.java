package com.cybershield.ai.sms;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.security.MessageDigest;
import java.util.HashSet;
import java.util.Set;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

public class APKScanner {
    private final Set<String> knownMaliciousHashes = new HashSet<>();
    private static final String DANGEROUS_PERMISSIONS[] = {
            "android.permission.READ_SMS",
            "android.permission.SEND_SMS",
            "android.permission.READ_CONTACTS",
            "android.permission.READ_CALL_LOG",
            "android.permission.READ_PHONE_STATE",
            "android.permission.WRITE_SETTINGS",
            "android.permission.DEVICE_ADMIN",
            "android.permission.INSTALL_PACKAGES",
            "android.permission.BIND_ACCESSIBILITY_SERVICE",
            "android.permission.BIND_DEVICE_ADMIN",
            "android.permission.WRITE_CALL_LOG"
    };

    public APKScanner() {
        loadKnownMaliciousHashes();
    }

    private void loadKnownMaliciousHashes() {
        knownMaliciousHashes.add("e3b0c44298fc1c149afbf4c8996fb924");
        knownMaliciousHashes.add("a1b2c3d4e5f67890abcdef1234567890");
        knownMaliciousHashes.add("deadbeef12345678deadbeef12345678");
    }

    public boolean detectApkReference(String messageBody, String url) {
        if (messageBody == null && url == null) return false;

        String combined = (messageBody != null ? messageBody : "") + " " + (url != null ? url : "");
        String lower = combined.toLowerCase();

        return lower.contains(".apk") ||
                lower.contains("download app") ||
                lower.contains("install app") ||
                lower.contains("click to install") ||
                lower.contains("app download") ||
                lower.contains("apk download") ||
                lower.contains("play.google.com/store/apps/details") ||
                (lower.contains("download") && lower.contains("app")) ||
                (url != null && url.endsWith(".apk"));
    }

    public boolean isMaliciousDownload(String url) {
        if (url == null || url.isEmpty()) return false;

        // Check for direct APK download from non-Play Store sources
        if (url.endsWith(".apk")) return true;

        // Check for known malicious download domains
        String domain = extractDomain(url);
        if (domain == null) return false;

        String[] maliciousDownloadHosts = {
                "free-apk.xyz", "mod-apk.top", "cracked-apps.com",
                "premium-free.xyz", "hacked-games.com", "free-in-app.xyz"
        };

        for (String host : maliciousDownloadHosts) {
            if (domain.toLowerCase().contains(host)) return true;
        }

        return false;
    }

    public boolean hasDangerousPermissions(String apkPath) {
        File apkFile = new File(apkPath);
        if (!apkFile.exists()) return false;

        try {
            ZipFile zip = new ZipFile(apkFile);
            ZipEntry manifestEntry = zip.getEntry("AndroidManifest.xml");
            if (manifestEntry == null) {
                zip.close();
                return false;
            }

            // Read manifest as binary XML and check permissions
            InputStream is = zip.getInputStream(manifestEntry);
            byte[] manifestBytes = readAllBytes(is);
            String manifestStr = new String(manifestBytes, "ISO-8859-1");
            is.close();
            zip.close();

            for (String permission : DANGEROUS_PERMISSIONS) {
                if (manifestStr.contains(permission)) {
                    return true;
                }
            }

            return false;
        } catch (IOException e) {
            return false;
        }
    }

    public String calculateHash(String apkPath) {
        try {
            File file = new File(apkPath);
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            java.io.FileInputStream fis = new java.io.FileInputStream(file);
            byte[] buffer = new byte[8192];
            int bytesRead;
            while ((bytesRead = fis.read(buffer)) != -1) {
                md.update(buffer, 0, bytesRead);
            }
            fis.close();
            byte[] hashBytes = md.digest();
            StringBuilder sb = new StringBuilder();
            for (byte b : hashBytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e) {
            return "";
        }
    }

    public boolean isKnownMalicious(String hash) {
        return knownMaliciousHashes.contains(hash.toLowerCase());
    }

    public boolean checkApk(String apkPath) {
        String hash = calculateHash(apkPath);
        if (isKnownMalicious(hash)) return true;
        if (hasDangerousPermissions(apkPath)) return true;
        return false;
    }

    private String extractDomain(String url) {
        try {
            URL parsed = new URL(url);
            return parsed.getHost();
        } catch (Exception e) {
            String stripped = url;
            if (stripped.startsWith("http://")) stripped = stripped.substring(7);
            if (stripped.startsWith("https://")) stripped = stripped.substring(8);
            int idx = stripped.indexOf('/');
            return idx > 0 ? stripped.substring(0, idx) : stripped;
        }
    }

    private byte[] readAllBytes(InputStream is) throws IOException {
        java.io.ByteArrayOutputStream buffer = new java.io.ByteArrayOutputStream();
        byte[] data = new byte[1024];
        int read;
        while ((read = is.read(data, 0, data.length)) != -1) {
            buffer.write(data, 0, read);
        }
        return buffer.toByteArray();
    }
}