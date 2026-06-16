package com.cybershield.ai.call;

import android.Manifest;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.telephony.PhoneStateListener;
import android.telephony.TelephonyManager;
import android.util.Log;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;
import androidx.core.content.ContextCompat;

import com.cybershield.app.R;
import com.cybershield.ai.evidence.EvidenceHashService;
import com.cybershield.ai.overlay.FraudAlertOverlay;

import org.json.JSONObject;

import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.UUID;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class CallDetectionService extends Service {
    private static final String TAG = "CallDetection";
    private static final String CHANNEL_ID = "call_detection_channel";
    private static final int NOTIFICATION_ID = 1001;
    private static final String AI_GATEWAY_URL = "https://ai-gateway.cybershield.gov.in/v1/analyze/call";

    private TelephonyManager telephonyManager;
    private PhoneStateListener phoneStateListener;
    private ExecutorService executorService;
    private Handler mainHandler;
    private String currentCallState = "IDLE";
    private String currentPhoneNumber = "";
    private String currentCallSessionId = "";

    @Override
    public void onCreate() {
        super.onCreate();
        executorService = Executors.newSingleThreadExecutor();
        mainHandler = new Handler(Looper.getMainLooper());
        telephonyManager = (TelephonyManager) getSystemService(Context.TELEPHONY_SERVICE);
        startForegroundNotification();
    }

    private void startForegroundNotification() {
        NotificationCompat.Builder builder = new NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentTitle("CyberShield AI Active")
                .setContentText("Call protection is running")
                .setSmallIcon(R.drawable.ic_shield)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setOngoing(true);

        startForeground(NOTIFICATION_ID, builder.build());
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        registerPhoneStateListener();
        return START_STICKY;
    }

    private void registerPhoneStateListener() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE)
                    != PackageManager.PERMISSION_GRANTED) {
                Log.w(TAG, "READ_PHONE_STATE permission not granted");
                return;
            }
        }

        phoneStateListener = new PhoneStateListener() {
            @Override
            public void onCallStateChanged(int state, String phoneNumber) {
                super.onCallStateChanged(state, phoneNumber);
                switch (state) {
                    case TelephonyManager.CALL_STATE_IDLE:
                        handleIdleState();
                        break;
                    case TelephonyManager.CALL_STATE_RINGING:
                        handleIncomingCall(phoneNumber);
                        break;
                    case TelephonyManager.CALL_STATE_OFFHOOK:
                        handleCallConnected();
                        break;
                }
            }
        };

        telephonyManager.listen(phoneStateListener, PhoneStateListener.LISTEN_CALL_STATE);
    }

    private void handleIncomingCall(String phoneNumber) {
        currentCallState = "RINGING";
        currentPhoneNumber = phoneNumber != null ? phoneNumber : "";
        currentCallSessionId = UUID.randomUUID().toString();

        Log.d(TAG, "Incoming call detected: " + currentPhoneNumber + " session=" + currentCallSessionId);

        executorService.execute(() -> {
            try {
                int riskScore = performRealtimeReputationLookup(currentPhoneNumber);
                String riskLevel = getRiskLevel(riskScore);

                mainHandler.post(() -> {
                    showFraudAlert(riskScore, riskLevel, currentPhoneNumber);
                });

                EvidenceHashService.getInstance(this).logCallEvent(
                        currentCallSessionId, currentPhoneNumber, "INCOMING", riskScore, riskLevel
                );
            } catch (Exception e) {
                Log.e(TAG, "Error during call analysis", e);
            }
        });
    }

    private int performRealtimeReputationLookup(String phoneNumber) {
        int defaultRisk = 50;
        try {
            URL url = new URL(AI_GATEWAY_URL);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setRequestProperty("X-Session-Id", currentCallSessionId);
            conn.setDoOutput(true);
            conn.setConnectTimeout(5000);
            conn.setReadTimeout(5000);

            JSONObject payload = new JSONObject();
            payload.put("phone_number", phoneNumber);
            payload.put("source", "incoming_call");
            payload.put("session_id", currentCallSessionId);
            payload.put("platform", "android");
            payload.put("app_version", "1.0.0");

            OutputStream os = conn.getOutputStream();
            os.write(payload.toString().getBytes(StandardCharsets.UTF_8));
            os.flush();
            os.close();

            int responseCode = conn.getResponseCode();
            if (responseCode == 200) {
                java.io.BufferedReader reader = new java.io.BufferedReader(
                        new java.io.InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8));
                StringBuilder response = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    response.append(line);
                }
                reader.close();

                JSONObject jsonResponse = new JSONObject(response.toString());
                return jsonResponse.optInt("risk_score", defaultRisk);
            }
        } catch (Exception e) {
            Log.e(TAG, "Reputation lookup failed, using default risk", e);
        }
        return defaultRisk;
    }

    private void handleCallConnected() {
        currentCallState = "CONNECTED";
        Log.d(TAG, "Call connected: " + currentPhoneNumber);

        executorService.execute(() -> {
            try {
                int riskScore = performRealtimeReputationLookup(currentPhoneNumber);
                String riskLevel = getRiskLevel(riskScore);

                mainHandler.post(() -> {
                    updateAlertForConnectedCall(riskScore, riskLevel, currentPhoneNumber);
                });

                EvidenceHashService.getInstance(this).logCallEvent(
                        currentCallSessionId, currentPhoneNumber, "CONNECTED", riskScore, riskLevel
                );
            } catch (Exception e) {
                Log.e(TAG, "Error updating risk on connect", e);
            }
        });
    }

    private void handleIdleState() {
        if (!currentCallState.equals("IDLE")) {
            Log.d(TAG, "Call ended: " + currentPhoneNumber + " session=" + currentCallSessionId);
            EvidenceHashService.getInstance(this).logCallEvent(
                    currentCallSessionId, currentPhoneNumber, "ENDED", 0, "NONE"
            );
            currentCallState = "IDLE";
            currentPhoneNumber = "";
            currentCallSessionId = "";
        }
    }

    private String getRiskLevel(int score) {
        if (score >= 70) return "RED";
        if (score >= 40) return "YELLOW";
        return "GREEN";
    }

    private void showFraudAlert(int riskScore, String riskLevel, String phoneNumber) {
        Intent intent = new Intent(this, FraudAlertOverlay.class);
        intent.putExtra("risk_score", riskScore);
        intent.putExtra("risk_level", riskLevel);
        intent.putExtra("phone_number", phoneNumber);
        intent.putExtra("session_id", currentCallSessionId);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(intent);
    }

    private void updateAlertForConnectedCall(int riskScore, String riskLevel, String phoneNumber) {
        FraudAlertOverlay.updateRisk(riskScore, riskLevel, phoneNumber);
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (telephonyManager != null && phoneStateListener != null) {
            telephonyManager.listen(phoneStateListener, PhoneStateListener.LISTEN_NONE);
        }
        if (executorService != null && !executorService.isShutdown()) {
            executorService.shutdown();
        }
    }
}