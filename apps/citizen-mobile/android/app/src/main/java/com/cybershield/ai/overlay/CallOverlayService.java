package com.cybershield.ai.overlay;

import android.app.Service;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.os.Build;
import android.os.IBinder;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.WindowManager;
import android.widget.TextView;

import androidx.annotation.Nullable;

import com.cybershield.app.R;

public class CallOverlayService extends Service {
    private WindowManager windowManager;
    private View overlayView;
    private TextView riskBadge;

    private static CallOverlayService instance;

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        instance = this;
        windowManager = (WindowManager) getSystemService(WINDOW_SERVICE);
        showOverlay();
    }

    private void showOverlay() {
        int layoutFlag;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            layoutFlag = WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY;
        } else {
            layoutFlag = WindowManager.LayoutParams.TYPE_PHONE;
        }

        WindowManager.LayoutParams params = new WindowManager.LayoutParams(
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.WRAP_CONTENT,
                layoutFlag,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
                        | WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL
                        | WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
                PixelFormat.TRANSLUCENT
        );

        params.gravity = Gravity.TOP | Gravity.END;
        params.y = 100;

        LayoutInflater inflater = LayoutInflater.from(this);
        overlayView = inflater.inflate(R.layout.overlay_call_risk, null);
        riskBadge = overlayView.findViewById(R.id.risk_badge);

        overlayView.setOnTouchListener(new View.OnTouchListener() {
            private int initialX;
            private int initialY;
            private float initialTouchX;
            private float initialTouchY;

            @Override
            public boolean onTouch(View v, MotionEvent event) {
                switch (event.getAction()) {
                    case MotionEvent.ACTION_DOWN:
                        initialX = params.x;
                        initialY = params.y;
                        initialTouchX = event.getRawX();
                        initialTouchY = event.getRawY();
                        return true;
                    case MotionEvent.ACTION_MOVE:
                        params.x = initialX + (int) (event.getRawX() - initialTouchX);
                        params.y = initialY + (int) (event.getRawY() - initialTouchY);
                        windowManager.updateViewLayout(overlayView, params);
                        return true;
                    case MotionEvent.ACTION_UP:
                        return true;
                }
                return false;
            }
        });

        try {
            windowManager.addView(overlayView, params);
        } catch (SecurityException e) {
            stopSelf();
        }
    }

    public void updateRiskBadge(String riskLevel, int riskScore) {
        if (riskBadge == null) return;

        switch (riskLevel) {
            case "RED":
                riskBadge.setBackgroundColor(0xCCFF0000);
                riskBadge.setText("SCAM ALERT! (" + riskScore + "%)");
                break;
            case "YELLOW":
                riskBadge.setBackgroundColor(0xCCFFA500);
                riskBadge.setText("Suspicious (" + riskScore + "%)");
                break;
            case "GREEN":
                riskBadge.setBackgroundColor(0xCC00AA00);
                riskBadge.setText("Safe (" + riskScore + "%)");
                break;
            default:
                riskBadge.setBackgroundColor(0xCC888888);
                riskBadge.setText("Analyzing...");
                break;
        }
    }

    public static void updateOverlay(String riskLevel, int riskScore) {
        if (instance != null) {
            instance.updateRiskBadge(riskLevel, riskScore);
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        instance = null;
        if (overlayView != null && windowManager != null) {
            windowManager.removeView(overlayView);
        }
    }
}