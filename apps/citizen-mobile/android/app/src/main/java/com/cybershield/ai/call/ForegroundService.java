package com.cybershield.ai.call;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;

import com.cybershield.app.R;

public class ForegroundService extends Service {
    private static final String CHANNEL_ID = "cybershield_foreground";
    private static final int NOTIFICATION_ID = 1000;
    private static final String CHANNEL_NAME = "CyberShield AI Protection";
    private static final String CHANNEL_DESC = "Ongoing call and SMS fraud detection";

    @Override
    public void onCreate() {
        super.onCreate();
        createNotificationChannel();
        startForeground(NOTIFICATION_ID, buildNotification());
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                    CHANNEL_ID,
                    CHANNEL_NAME,
                    NotificationManager.IMPORTANCE_LOW
            );
            channel.setDescription(CHANNEL_DESC);
            channel.setShowBadge(false);
            channel.setLockscreenVisibility(Notification.VISIBILITY_SECRET);

            // Android 14+ (API 34) battery optimization
            // FOREGROUND_SERVICE_IMMEDIATE = 1 (constant from API 34)
            if (Build.VERSION.SDK_INT >= 34) {
                try {
                    // Use reflection or direct constant to avoid compile-time dependency
                    java.lang.reflect.Method method = channel.getClass().getMethod("setForegroundServiceBehavior", int.class);
                    method.invoke(channel, 1); // FOREGROUND_SERVICE_IMMEDIATE = 1
                } catch (Exception ignored) {
                    // API not available, skip
                }
            }

            NotificationManager manager = getSystemService(NotificationManager.class);
            if (manager != null) {
                manager.createNotificationChannel(channel);
            }
        }
    }

    private Notification buildNotification() {
        return new NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentTitle("CyberShield AI")
                .setContentText("Fraud detection active")
                .setSmallIcon(R.drawable.ic_shield)
                .setPriority(NotificationCompat.PRIORITY_LOW)
                .setOngoing(true)
                .setSilent(true)
                .build();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        // Android 12+ (API 31) requires foreground service type declaration
        return START_STICKY;
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }
}