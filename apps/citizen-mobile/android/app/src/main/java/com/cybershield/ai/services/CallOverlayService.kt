package com.cybershield.ai.services

import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView
import androidx.core.content.ContextCompat
import com.cybershield.app.R

/**
 * RAKSAAR (CyberShield AI) - CallOverlayService
 * Phase 11: Android Protection Engine
 *
 * Shows floating overlay during calls:
 * - RED overlay for high risk (risk >= 70)
 * - YELLOW overlay for suspicious (risk >= 40)
 * - GREEN overlay for safe
 *
 * Supports Android 11 through Android 14+
 */
class CallOverlayService : Service() {
    companion object {
        const val TAG = "RAKSAAR_OVERLAY"
        const val CHANNEL_ID = "raksaar_overlay"
        const val NOTIFICATION_ID = 2001
    }

    private lateinit var windowManager: WindowManager
    private var overlayView: View? = null
    private var riskScore = 0
    private var phoneNumber = ""

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        phoneNumber = intent?.getStringExtra("phone_number") ?: ""
        riskScore = intent?.getIntExtra("risk_score", 0) ?: 0
        showOverlay()
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        removeOverlay()
        super.onDestroy()
    }

    private fun showOverlay() {
        removeOverlay()

        val inflater = getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater
        overlayView = inflater.inflate(R.layout.overlay_call_warning, null)

        overlayView?.findViewById<TextView>(R.id.tvPhoneNumber)?.text = phoneNumber
        overlayView?.findViewById<TextView>(R.id.tvRiskScore)?.text = "$riskScore"
        overlayView?.findViewById<TextView>(R.id.tvRiskLevel)?.text = getRiskLevelText()
        overlayView?.findViewById<Button>(R.id.btnReport)?.setOnClickListener { reportFraud() }
        overlayView?.findViewById<Button>(R.id.btnDismiss)?.setOnClickListener { removeOverlay() }

        val bgColor = when {
            riskScore >= 70 -> android.graphics.Color.parseColor("#CCDC2626")
            riskScore >= 40 -> android.graphics.Color.parseColor("#CCF59E0B")
            else -> android.graphics.Color.parseColor("#CC22C55E")
        }
        overlayView?.setBackgroundColor(bgColor)

        val layoutFlag = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            WindowManager.LayoutParams.TYPE_PHONE
        }

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            layoutFlag,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
            WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP
            y = 100
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (!android.provider.Settings.canDrawOverlays(this)) {
                showScamNotification()
                return
            }
        }

        try {
            windowManager.addView(overlayView, params)
        } catch (e: Exception) {
            showScamNotification()
        }
    }

    private fun removeOverlay() {
        overlayView?.let {
            try { windowManager.removeView(it) } catch (_: Exception) {}
        }
        overlayView = null
    }

    private fun getRiskLevelText(): String = when {
        riskScore >= 70 -> "HIGH RISK - Likely Scam!"
        riskScore >= 40 -> "SUSPICIOUS - Exercise Caution"
        else -> "SAFE - No threat detected"
    }

    private fun reportFraud() {
        val intent = Intent(this, FraudReportService::class.java).apply {
            putExtra("phone_number", phoneNumber)
            putExtra("risk_score", riskScore)
        }
        ContextCompat.startForegroundService(this, intent)
    }

    private fun showScamNotification() {
        val notification = androidx.core.app.NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("⚠️ ${getRiskLevelText()}")
            .setContentText("Call from $phoneNumber (Risk: $riskScore)")
            .setSmallIcon(android.R.drawable.ic_dialog_alert)
            .setPriority(androidx.core.app.NotificationCompat.PRIORITY_MAX)
            .setVibrate(longArrayOf(0, 500, 200, 500))
            .setAutoCancel(true)
            .build()

        val manager = getSystemService(NOTIFICATION_SERVICE) as android.app.NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = android.app.NotificationChannel(
                CHANNEL_ID, "Scam Alerts",
                android.app.NotificationManager.IMPORTANCE_HIGH
            )
            manager.createNotificationChannel(channel)
        }
        manager.notify(NOTIFICATION_ID, notification)
    }
}