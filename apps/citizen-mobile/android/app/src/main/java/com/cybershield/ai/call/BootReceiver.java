package com.cybershield.ai.call;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.util.Log;

public class BootReceiver extends BroadcastReceiver {
    private static final String TAG = "BootReceiver";

    @Override
    public void onReceive(Context context, Intent intent) {
        if (intent == null || intent.getAction() == null) return;
        String action = intent.getAction();
        if (!Intent.ACTION_BOOT_COMPLETED.equals(action) && !"android.intent.action.QUICKBOOT_POWERON".equals(action)) {
            return;
        }

        Log.d(TAG, "Boot completed, starting CyberShield services");

        // Start foreground service
        Intent foregroundIntent = new Intent(context, ForegroundService.class);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(foregroundIntent);
        } else {
            context.startService(foregroundIntent);
        }

        // Start call detection service
        Intent callIntent = new Intent(context, CallDetectionService.class);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(callIntent);
        } else {
            context.startService(callIntent);
        }
    }
}