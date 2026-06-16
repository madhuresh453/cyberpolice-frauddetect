package com.cybershield.ai.services

import android.app.*
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import org.json.JSONObject
import java.io.File
import java.io.FileOutputStream
import java.net.HttpURLConnection
import java.net.URL
import java.text.SimpleDateFormat
import java.util.*

class FraudReportService : Service() {
    companion object {
        const val TAG = "FraudReportService"
        const val CHANNEL_ID = "fraud_report_channel"
        const val NOTIFICATION_ID = 2001

        fun start(context: Context, phoneNumber: String, riskScore: Int, scamType: String = "unknown") {
            val intent = Intent(context, FraudReportService::class.java).apply {
                putExtra("phone_number", phoneNumber)
                putExtra("risk_score", riskScore)
                putExtra("scam_type", scamType)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val phoneNumber = intent?.getStringExtra("phone_number") ?: "unknown"
        val riskScore = intent?.getIntExtra("risk_score", 0) ?: 0
        val scamType = intent?.getStringExtra("scam_type") ?: "unknown"

        val notification = createNotification("Reporting fraud: $phoneNumber")
        startForeground(NOTIFICATION_ID, notification)

        // Process in background thread
        Thread {
            try {
                val report = buildReportJson(phoneNumber, riskScore, scamType)
                saveReportLocally(report)
                uploadReport(report)
                Log.d(TAG, "Fraud report submitted for $phoneNumber")
            } catch (e: Exception) {
                Log.e(TAG, "Failed to submit fraud report", e)
            } finally {
                stopForeground(true)
                stopSelf()
            }
        }.start()

        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun buildReportJson(phoneNumber: String, riskScore: Int, scamType: String): String {
        val timestamp = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US).format(Date())
        val reportId = UUID.randomUUID().toString()

        return JSONObject().apply {
            put("report_id", reportId)
            put("phone_number", phoneNumber)
            put("risk_score", riskScore)
            put("scam_type", scamType)
            put("timestamp", timestamp)
            put("device_model", Build.MODEL)
            put("android_version", Build.VERSION.RELEASE)
            put("app_version", "1.0.0")
            put("status", "submitted")
        }.toString()
    }

    private fun saveReportLocally(report: String) {
        try {
            val dir = File(filesDir, "fraud_reports")
            if (!dir.exists()) dir.mkdirs()
            val file = File(dir, "report_${System.currentTimeMillis()}.json")
            FileOutputStream(file).use { it.write(report.toByteArray()) }
            Log.d(TAG, "Report saved locally: ${file.absolutePath}")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to save report locally", e)
        }
    }

    private fun uploadReport(report: String) {
        try {
            val url = URL("http://10.0.2.2:5000/api/v1/citizen/reports")
            val conn = url.openConnection() as HttpURLConnection
            conn.requestMethod = "POST"
            conn.setRequestProperty("Content-Type", "application/json")
            conn.doOutput = true
            conn.connectTimeout = 10000
            conn.readTimeout = 10000

            conn.outputStream.use { os ->
                os.write(report.toByteArray())
            }

            val responseCode = conn.responseCode
            Log.d(TAG, "Upload response: $responseCode")
        } catch (e: Exception) {
            Log.e(TAG, "Upload failed (will retry later)", e)
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID, "Fraud Reports",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Fraud report submission status"
            }
            getSystemService(NotificationManager::class.java)?.createNotificationChannel(channel)
        }
    }

    private fun createNotification(text: String): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("RAKSAAR - Reporting Fraud")
            .setContentText(text)
            .setSmallIcon(android.R.drawable.ic_menu_report_image)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
            .build()
    }
}