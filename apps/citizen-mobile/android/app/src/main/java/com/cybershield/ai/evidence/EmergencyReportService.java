package com.cybershield.ai.evidence;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;
import android.util.Log;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;

import com.cybershield.app.R;

import org.json.JSONObject;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.UUID;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * EmergencyReportService — Foreground service for fraud report submission.
 * Creates JSON payload, stores locally, uploads asynchronously.
 */
public class EmergencyReportService extends Service {
    private static final String TAG = "EmergencyReport";
    private static final String CHANNEL_ID = "emergency_report_channel";
    private static final int NOTIFICATION_ID = 3001;
    private static final String BACKEND_URL = "http://10.0.2.2:5000/api/v1/citizen/reports";

    private ExecutorService executorService;

    @Override
    public void onCreate() {
        super.onCreate();
        executorService = Executors.newSingleThreadExecutor();
        createNotificationChannel();
        startForeground(NOTIFICATION_ID, buildNotification("Submitting report..."));
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (intent == null) {
            stopSelf();
            return START_NOT_STICKY;
        }

        String phoneNumber = intent.getStringExtra("phone_number");
        int riskScore = intent.getIntExtra("risk_score", 0);
        String riskLevel = intent.getStringExtra("risk_level");
        String sessionId = intent.getStringExtra("session_id");
        String scamType = intent.getStringExtra("scam_type");

        if (phoneNumber == null) phoneNumber = "unknown";
        if (riskLevel == null) riskLevel = "UNKNOWN";
        if (sessionId == null) sessionId = UUID.randomUUID().toString();
        if (scamType == null) scamType = "unknown";

        final String finalPhoneNumber = phoneNumber;
        final int finalRiskScore = riskScore;
        final String finalRiskLevel = riskLevel;
        final String finalSessionId = sessionId;
        final String finalScamType = scamType;

        executorService.execute(() -> {
            try {
                String report = buildReportJson(finalPhoneNumber, finalRiskScore, finalRiskLevel, finalSessionId, finalScamType);
                saveReportLocally(report);
                uploadReport(report);

                NotificationManager manager = getSystemService(NotificationManager.class);
                if (manager != null) {
                    manager.notify(NOTIFICATION_ID, buildNotification("Report submitted successfully"));
                }
                Log.d(TAG, "Emergency report submitted for " + finalPhoneNumber);
            } catch (Exception e) {
                Log.e(TAG, "Failed to submit emergency report", e);
                NotificationManager manager = getSystemService(NotificationManager.class);
                if (manager != null) {
                    manager.notify(NOTIFICATION_ID, buildNotification("Report submission failed"));
                }
            } finally {
                stopForeground(true);
                stopSelf();
            }
        });

        return START_NOT_STICKY;
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    private String buildReportJson(String phoneNumber, int riskScore, String riskLevel, String sessionId, String scamType) {
        String timestamp = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US).format(new Date());
        String reportId = UUID.randomUUID().toString();

        try {
            JSONObject json = new JSONObject();
            json.put("report_id", reportId);
            json.put("phone_number", phoneNumber);
            json.put("risk_score", riskScore);
            json.put("risk_level", riskLevel);
            json.put("session_id", sessionId);
            json.put("scam_type", scamType);
            json.put("timestamp", timestamp);
            json.put("device_model", Build.MODEL);
            json.put("android_version", Build.VERSION.RELEASE);
            json.put("app_version", "1.0.0");
            json.put("status", "submitted");
            return json.toString();
        } catch (Exception e) {
            return "{}";
        }
    }

    private void saveReportLocally(String report) {
        try {
            File dir = new File(getFilesDir(), "fraud_reports");
            if (!dir.exists()) dir.mkdirs();
            File file = new File(dir, "report_" + System.currentTimeMillis() + ".json");
            FileOutputStream fos = new FileOutputStream(file);
            fos.write(report.getBytes(StandardCharsets.UTF_8));
            fos.close();
            Log.d(TAG, "Report saved locally: " + file.getAbsolutePath());
        } catch (Exception e) {
            Log.e(TAG, "Failed to save report locally", e);
        }
    }

    private void uploadReport(String report) {
        try {
            URL url = new URL(BACKEND_URL);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setDoOutput(true);
            conn.setConnectTimeout(10000);
            conn.setReadTimeout(10000);

            OutputStream os = conn.getOutputStream();
            os.write(report.getBytes(StandardCharsets.UTF_8));
            os.flush();
            os.close();

            int responseCode = conn.getResponseCode();
            Log.d(TAG, "Upload response: " + responseCode);
        } catch (Exception e) {
            Log.e(TAG, "Upload failed", e);
        }
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                    CHANNEL_ID,
                    "Emergency Reports",
                    NotificationManager.IMPORTANCE_LOW
            );
            channel.setDescription("Fraud report submission status");
            NotificationManager manager = getSystemService(NotificationManager.class);
            if (manager != null) {
                manager.createNotificationChannel(channel);
            }
        }
    }

    private Notification buildNotification(String text) {
        return new NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentTitle("RAKSAAR - Report")
                .setContentText(text)
                .setSmallIcon(R.drawable.ic_shield)
                .setPriority(NotificationCompat.PRIORITY_LOW)
                .setOngoing(true)
                .build();
    }
}