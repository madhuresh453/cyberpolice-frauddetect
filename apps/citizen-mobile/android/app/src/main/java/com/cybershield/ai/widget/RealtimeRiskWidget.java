package com.cybershield.ai.widget;

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.os.Handler;
import android.os.Looper;
import android.widget.RemoteViews;

import com.cybershield.app.R;
import com.cybershield.ai.call.CallDetectionService;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

public class RealtimeRiskWidget extends AppWidgetProvider {
    private static final ScheduledExecutorService scheduler = Executors.newSingleThreadScheduledExecutor();
    private static int currentRiskScore = 0;
    private static String currentRiskLevel = "GREEN";
    private static int widgetId = AppWidgetManager.INVALID_APPWIDGET_ID;

    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        for (int id : appWidgetIds) {
            widgetId = id;
            updateWidget(context, appWidgetManager, id);
        }
        startPeriodicUpdates(context);
    }

    @Override
    public void onEnabled(Context context) {
        super.onEnabled(context);
        startPeriodicUpdates(context);
    }

    @Override
    public void onDisabled(Context context) {
        super.onDisabled(context);
        scheduler.shutdown();
    }

    private void startPeriodicUpdates(Context context) {
        scheduler.scheduleAtFixedRate(() -> {
            if (widgetId != AppWidgetManager.INVALID_APPWIDGET_ID) {
                AppWidgetManager manager = AppWidgetManager.getInstance(context);
                updateWidget(context, manager, widgetId);
            }
        }, 0, 15, TimeUnit.SECONDS);
    }

    private void updateWidget(Context context, AppWidgetManager manager, int id) {
        RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.widget_realtime_risk);

        // Update risk score
        views.setTextViewText(R.id.widget_risk_score, currentRiskScore + "%");

        // Update risk level indicator
        int indicatorColor;
        String levelText;
        switch (currentRiskLevel) {
            case "RED":
                indicatorColor = Color.RED;
                levelText = "HIGH RISK";
                break;
            case "YELLOW":
                indicatorColor = Color.rgb(255, 165, 0);
                levelText = "SUSPICIOUS";
                break;
            case "GREEN":
                indicatorColor = Color.rgb(0, 170, 0);
                levelText = "SAFE";
                break;
            default:
                indicatorColor = Color.GRAY;
                levelText = "MONITORING";
                break;
        }
        views.setTextColor(R.id.widget_risk_score, indicatorColor);
        views.setTextViewText(R.id.widget_risk_level, levelText);
        views.setInt(R.id.widget_indicator, "setBackgroundColor", indicatorColor);

        // Open app on click
        Intent intent = new Intent(context, CallDetectionService.class);
        PendingIntent pendingIntent = PendingIntent.getService(
                context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
        );
        views.setOnClickPendingIntent(R.id.widget_container, pendingIntent);

        manager.updateAppWidget(id, views);
    }

    public static void updateRisk(int score, String level) {
        currentRiskScore = score;
        currentRiskLevel = level;
    }
}