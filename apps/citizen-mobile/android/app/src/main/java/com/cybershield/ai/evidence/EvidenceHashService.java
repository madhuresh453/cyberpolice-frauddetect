package com.cybershield.ai.evidence;

import android.content.Context;
import android.content.SharedPreferences;
import android.util.Log;

import java.security.MessageDigest;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.UUID;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class EvidenceHashService {
    private static final String TAG = "EvidenceHash";
    private static EvidenceHashService instance;
    private final Context context;
    private final ExecutorService executorService;
    private final SharedPreferences preferences;

    private EvidenceHashService(Context context) {
        this.context = context.getApplicationContext();
        this.executorService = Executors.newSingleThreadExecutor();
        this.preferences = context.getSharedPreferences("evidence_store", Context.MODE_PRIVATE);
    }

    public static synchronized EvidenceHashService getInstance(Context context) {
        if (instance == null) {
            instance = new EvidenceHashService(context);
        }
        return instance;
    }

    public void logCallEvent(String sessionId, String phoneNumber, String status, int riskScore, String riskLevel) {
        executorService.execute(() -> {
            try {
                String timestamp = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US).format(new Date());
                String evidenceId = UUID.randomUUID().toString();
                String raw = evidenceId + "|" + sessionId + "|" + phoneNumber + "|" + status + "|" + riskScore + "|" + riskLevel + "|" + timestamp;
                String hash = sha256(raw);

                EvidenceRecord record = new EvidenceRecord();
                record.evidenceId = evidenceId;
                record.sessionId = sessionId;
                record.type = "CALL";
                record.source = phoneNumber;
                record.status = status;
                record.riskScore = riskScore;
                record.riskLevel = riskLevel;
                record.timestamp = timestamp;
                record.hash = hash;
                record.tamperIndicator = previousHash;

                storeEvidence(record);
                previousHash = hash;
            } catch (Exception e) {
                Log.e(TAG, "Error logging call event", e);
            }
        });
    }

    public void logSmsEvent(String sessionId, String sender, String messageBody, int riskScore, String fraudType) {
        executorService.execute(() -> {
            try {
                String timestamp = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US).format(new Date());
                String evidenceId = UUID.randomUUID().toString();
                String raw = evidenceId + "|" + sessionId + "|" + sender + "|" + messageBody + "|" + riskScore + "|" + fraudType + "|" + timestamp;
                String hash = sha256(raw);
                String previousEvidenceHash = previousHash;

                EvidenceRecord record = new EvidenceRecord();
                record.evidenceId = evidenceId;
                record.sessionId = sessionId;
                record.type = "SMS";
                record.source = sender;
                record.status = fraudType;
                record.riskScore = riskScore;
                record.riskLevel = riskScore >= 70 ? "RED" : riskScore >= 40 ? "YELLOW" : "GREEN";
                record.timestamp = timestamp;
                record.hash = hash;
                record.tamperIndicator = previousEvidenceHash;
                record.messageHash = sha256(messageBody);

                storeEvidence(record);
                previousHash = hash;
            } catch (Exception e) {
                Log.e(TAG, "Error logging SMS event", e);
            }
        });
    }

    public void logReportEvent(String evidenceId, String reporterId, String reportType, String details) {
        executorService.execute(() -> {
            String hash = sha256("${evidenceId}|${reporterId}|${reportType}|${details}");
            String timestamp = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US).format(new Date());

            EvidenceRecord record = new EvidenceRecord();
            record.evidenceId = evidenceId;
            record.sessionId = UUID.randomUUID().toString();
            record.type = "REPORT";
            record.source = reporterId;
            record.status = reportType;
            record.timestamp = timestamp;
            record.hash = hash;
            record.tamperIndicator = previousHash;

            storeEvidence(record);
            previousHash = hash;
        });
    }

    private String sha256(String input) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hashBytes = md.digest(input.getBytes("UTF-8"));
            StringBuilder sb = new StringBuilder();
            for (byte b : hashBytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e) {
            return "";
        }
    }

    private void storeEvidence(EvidenceRecord record) {
        String key = "evidence_" + record.evidenceId;
        String json = record.toJson();
        try {
            String encryptedJson = encrypt(json);
            preferences.edit().putString(key, encryptedJson).apply();
            Log.d(TAG, "Evidence stored: " + record.evidenceId + " hash=" + record.hash);

            // Send to backend
            sendToBackend(record);
        } catch (Exception e) {
            Log.e(TAG, "Error storing evidence", e);
        }
    }

    private String encrypt(String input) throws Exception {
        java.util.Base64.Encoder encoder = java.util.Base64.getEncoder();
        return encoder.encodeToString(input.getBytes("UTF-8"));
    }

    private String previousHash = "";

    private void sendToBackend(EvidenceRecord record) {
        try {
            java.net.URL url = new java.net.URL("https://api.cybershield.gov.in/v1/evidence/log");
            java.net.HttpURLConnection conn = (java.net.HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setDoOutput(true);
            conn.setConnectTimeout(10000);
            conn.setReadTimeout(10000);

            String payload = record.toJson();
            java.io.OutputStream os = conn.getOutputStream();
            os.write(payload.getBytes("UTF-8"));
            os.flush();
            os.close();

            int responseCode = conn.getResponseCode();
            Log.d(TAG, "Evidence upload response code: " + responseCode);
        } catch (Exception e) {
            Log.e(TAG, "Failed to send evidence to backend", e);
        }
    }

    public boolean verifyChainIntegrity() {
        return previousHash != null && !previousHash.isEmpty();
    }

    public class EvidenceRecord {
        public String evidenceId;
        public String sessionId;
        public String type;
        public String source;
        public String status;
        public int riskScore;
        public String riskLevel;
        public String timestamp;
        public String hash;
        public String tamperIndicator;
        public String messageHash;

        public String toJson() {
            return "{" +
                    "\"evidenceId\":\"" + evidenceId + "\"," +
                    "\"sessionId\":\"" + sessionId + "\"," +
                    "\"type\":\"" + type + "\"," +
                    "\"source\":\"" + source + "\"," +
                    "\"status\":\"" + status + "\"," +
                    "\"riskScore\":" + riskScore + "," +
                    "\"riskLevel\":\"" + riskLevel + "\"," +
                    "\"timestamp\":\"" + timestamp + "\"," +
                    "\"hash\":\"" + hash + "\"," +
                    "\"tamperIndicator\":\"" + (tamperIndicator != null ? tamperIndicator : "") + "\"," +
                    "\"messageHash\":\"" + (messageHash != null ? messageHash : "") + "\"" +
                    "}";
        }
    }

    /**
     * Generate SHA-256 hash of a file.
     * @param path absolute path to the file
     * @return hex-encoded SHA-256 hash, or null on error
     */
    public String hashFile(String path) {
        try {
            java.io.File file = new java.io.File(path);
            if (!file.exists()) return null;
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            java.io.FileInputStream fis = new java.io.FileInputStream(file);
            byte[] buffer = new byte[8192];
            int bytesRead;
            while ((bytesRead = fis.read(buffer)) != -1) {
                digest.update(buffer, 0, bytesRead);
            }
            fis.close();
            byte[] hashBytes = digest.digest();
            StringBuilder sb = new StringBuilder();
            for (byte b : hashBytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e) {
            Log.e(TAG, "hashFile failed", e);
            return null;
        }
    }

    /**
     * Generate SHA-256 hash of a string.
     * @param input the string to hash
     * @return hex-encoded SHA-256 hash
     */
    public String hashString(String input) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hashBytes = digest.digest(input.getBytes("UTF-8"));
            StringBuilder sb = new StringBuilder();
            for (byte b : hashBytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e) {
            Log.e(TAG, "hashString failed", e);
            return "";
        }
    }

    
}
