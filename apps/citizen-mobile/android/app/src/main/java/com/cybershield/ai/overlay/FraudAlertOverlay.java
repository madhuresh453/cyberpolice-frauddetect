package com.cybershield.ai.overlay;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.provider.Settings;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.TextView;

import androidx.core.content.ContextCompat;

import com.cybershield.app.R;

public class FraudAlertOverlay extends Activity {
    private static final int OVERLAY_PERMISSION_REQUEST = 2001;

    private TextView riskScoreText;
    private TextView riskLevelText;
    private TextView phoneNumberText;
    private TextView warningMessageText;
    private Button blockButton;
    private Button reportButton;
    private Button dismissButton;
    private View riskIndicator;

    private int riskScore;
    private String riskLevel;
    private String phoneNumber;
    private String sessionId;

    private static int currentRiskScore = 0;
    private static String currentRiskLevel = "UNKNOWN";
    private static String currentPhone = "";
    private static FraudAlertOverlay currentInstance;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(
                WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
                WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL
        );
        getWindow().setFlags(
                WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
                WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH
        );

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setTurnScreenOn(true);
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED);
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        }

        setContentView(R.layout.activity_fraud_alert);

        initializeViews();
        extractIntentData();
        populateAlert();
        setupActionButtons();
        currentInstance = this;
    }

    private void initializeViews() {
        riskScoreText = findViewById(R.id.risk_score);
        riskLevelText = findViewById(R.id.risk_level);
        phoneNumberText = findViewById(R.id.phone_number);
        warningMessageText = findViewById(R.id.warning_message);
        blockButton = findViewById(R.id.btn_block);
        reportButton = findViewById(R.id.btn_report);
        dismissButton = findViewById(R.id.btn_dismiss);
        riskIndicator = findViewById(R.id.risk_indicator);
    }

    private void extractIntentData() {
        Intent intent = getIntent();
        riskScore = intent.getIntExtra("risk_score", 50);
        riskLevel = intent.getStringExtra("risk_level");
        phoneNumber = intent.getStringExtra("phone_number");
        sessionId = intent.getStringExtra("session_id");

        if (riskLevel == null) riskLevel = "YELLOW";
        if (phoneNumber == null) phoneNumber = "Unknown";
        if (sessionId == null) sessionId = "";

        currentRiskScore = riskScore;
        currentRiskLevel = riskLevel;
        currentPhone = phoneNumber;
    }

    private void populateAlert() {
        phoneNumberText.setText(phoneNumber);
        riskScoreText.setText(riskScore + "%");

        switch (riskLevel) {
            case "RED":
                riskLevelText.setText("SCAM LIKELY");
                riskLevelText.setTextColor(0xFFFF0000);
                riskIndicator.setBackgroundColor(0xFFFF0000);
                warningMessageText.setText("This caller is highly likely a fraudster. Do not share any personal information or OTP.");
                warningMessageText.setVisibility(View.VISIBLE);
                break;
            case "YELLOW":
                riskLevelText.setText("SUSPICIOUS");
                riskLevelText.setTextColor(0xFFFFA500);
                riskIndicator.setBackgroundColor(0xFFFFA500);
                warningMessageText.setText("This number has suspicious activity. Please exercise caution.");
                warningMessageText.setVisibility(View.VISIBLE);
                break;
            case "GREEN":
                riskLevelText.setText("SAFE");
                riskLevelText.setTextColor(0xFF00AA00);
                riskIndicator.setBackgroundColor(0xFF00AA00);
                warningMessageText.setVisibility(View.GONE);
                break;
            default:
                riskLevelText.setText("ANALYZING");
                riskLevelText.setTextColor(0xFF888888);
                riskIndicator.setBackgroundColor(0xFF888888);
                warningMessageText.setVisibility(View.GONE);
                break;
        }
    }

    private void setupActionButtons() {
        blockButton.setOnClickListener(v -> {
            blockNumber(phoneNumber);
            finish();
        });

        reportButton.setOnClickListener(v -> {
            Intent reportIntent = new Intent(this, com.cybershield.ai.evidence.EmergencyReportService.class);
            reportIntent.putExtra("phone_number", phoneNumber);
            reportIntent.putExtra("risk_score", riskScore);
            reportIntent.putExtra("risk_level", riskLevel);
            reportIntent.putExtra("session_id", sessionId);
            reportIntent.putExtra("type", "call");
            ContextCompat.startForegroundService(this, reportIntent);
            finish();
        });

        dismissButton.setOnClickListener(v -> {
            finish();
        });
    }

    private void blockNumber(String number) {
        if (number == null || number.isEmpty()) return;
        Intent intent = new Intent(Intent.ACTION_INSERT);
        intent.setType("vnd.android.cursor.item/contact");
        intent.putExtra(android.provider.ContactsContract.Intents.Insert.PHONE, number);
        startActivity(intent);
    }

    public static void updateRisk(int riskScore, String riskLevel, String phoneNumber) {
        currentRiskScore = riskScore;
        currentRiskLevel = riskLevel;
        currentPhone = phoneNumber;
        if (currentInstance != null) {
            currentInstance.runOnUiThread(() -> {
                currentInstance.riskScoreText.setText(riskScore + "%");
                currentInstance.riskLevelText.setText(riskLevel);
                currentInstance.phoneNumberText.setText(phoneNumber);
                currentInstance.populateAlert();
            });
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (currentInstance == this) {
            currentInstance = null;
        }
    }
}