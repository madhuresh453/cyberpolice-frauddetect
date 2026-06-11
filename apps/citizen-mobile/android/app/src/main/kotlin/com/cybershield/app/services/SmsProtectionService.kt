package com.cybershield.app.services

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import com.cybershield.app.MainActivity
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL

class SmsProtectionService : Service() {

    companion object {
        private const val TAG = "SmsProtection"
        private const val CHANNEL_ID = "cybershield_sms_protection"
        private const val NOTIFICATION_ID = 1002
        private const val API_BASE = "http://10.0.2.2:5000/api"

        // Fraud keywords that indicate scam SMS
        private val FRAUD_KEYWORDS = listOf(
            "kyc", "verify your account", "account blocked", "urgent action",
            "winning prize", "lottery", "congratulations you won",
            "click here to claim", "limited time offer", "act now",
            "bank account suspended", "verify immediately", "otp",
            "share your pin", "cvv", "atm pin", "net banking password",
            "aadhaar", "pan card verification", "tax refund",
            "investment opportunity", "guaranteed returns", "double your money",
            "crypto investment", "forex trading", "recovery agent",
            "cyber crime", "police complaint", "court notice",
            "legal action pending", "arrest warrant", "final notice"
        )

        // Known scam patterns
        private val SCAM_PATTERNS = listOf(
            "won.*prize", "claim.*reward", "click.*link",
            "verify.*account", "suspend.*account", "limited.*time",
            "guarantee.*return", "double.*money", "risk.*free",
            "urgent.*action", "immediate.*response", "last.*warning"
        )

        var isRunning = false
            private set
    }

    private val serviceScope = CoroutineScope(Dispatchers.IO + SupervisorJob())

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        isRunning = true
        createNotificationChannel()
        startForeground(NOTIFICATION_ID, buildNotification("SMS protection active"))
        Log.i(TAG, "SmsProtectionService started")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int = START_STICKY

    override fun onDestroy() {
        isRunning = false
        serviceScope.cancel()
        Log.i(TAG, "SmsProtectionService stopped")
        super.onDestroy()
    }

    private fun createNotificationChannel() {
        val channel = NotificationChannel(CHANNEL_ID, "SMS Protection", NotificationManager.IMPORTANCE_LOW).apply {
            description = "Scanning incoming SMS for fraud detection"
            setSound(null, null)
            enableVibration(false)
        }
        getSystemService(NotificationManager::class.java)?.createNotificationChannel(channel)
    }

    private fun buildNotification(text: String): Notification {
        val pendingIntent = PendingIntent.getActivity(this, 0,
            Intent(this, MainActivity::class.java), PendingIntent.FLAG_IMMUTABLE)
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("CyberShield AI")
            .setContentText(text)
            .setSmallIcon(android.R.drawable.ic_dialog_email)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .build()
    }

    /**
     * Called by SmsReceiver when a new SMS arrives.
     * Analyzes the message content for fraud indicators.
     */
    fun analyzeSms(fromNumber: String, messageBody: String) {
        serviceScope.launch {
            try {
                // Local keyword analysis
                val matchedKeywords = FRAUD_KEYWORDS.filter { keyword ->
                    messageBody.contains(keyword, ignoreCase = true)
                }

                val matchesScamPattern = SCAM_PATTERNS.any { pattern ->
                    Regex(pattern, RegexOption.IGNORE_CASE).containsMatchIn(messageBody)
                }

                val hasUrl = Regex("https?://\\S+").containsMatchIn(messageBody)
                val hasPhone = Regex("\\+?\\d{10,13}").containsMatchIn(messageBody)

                // Calculate local risk score
                var localRiskScore = 0
                localRiskScore += matchedKeywords.size * 15
                if (matchesScamPattern) localRiskScore += 30
                if (hasUrl) localRiskScore += 10
                if (hasPhone) localRiskScore += 5
                localRiskScore = localRiskScore.coerceAtMost(100)

                // Send to backend for AI analysis
                val apiResult = try {
                    val data = JSONObject().apply {
                        put("from_number", fromNumber)
                        put("message_body", messageBody)
                        put("local_risk_score", localRiskScore)
                    }
                    apiCall("$API_BASE/analysis/sms", data)
                } catch (e: Exception) {
                    Log.w(TAG, "Backend analysis failed, using local score")
                    null
                }

                val finalScore = apiResult?.optInt("fraud_probability", localRiskScore) ?: localRiskScore
                val isFraud = finalScore > 50

                if (isFraud) {
                    sendAlertNotification(
                        "Sms Scam Detected",
                        "From: $fromNumber\nRisk: $finalScore%\nKeywords: ${matchedKeywords.take(3).joinToString(", ")}"
                    )
                }

                // Send result to Flutter
                sendToFlutter("sms_analyzed", mapOf(
                    "from_number" to fromNumber,
                    "message_body" to messageBody,
                    "risk_score" to finalScore.toString(),
                    "is_fraud" to isFraud.toString(),
                    "matched_keywords" to matchedKeywords.joinToString(","),
                    "has_url" to hasUrl.toString(),
                    "has_scam_pattern" to matchesScamPattern.toString()
                ))

            } catch (e: Exception) {
                Log.e(TAG, "SMS analysis failed: ${e.message}", e)
            }
        }
    }

    private suspend fun apiCall(urlStr: String, data: JSONObject): JSONObject {
        return withContext(Dispatchers.IO) {
            val conn = URL(urlStr).openConnection() as HttpURLConnection
            try {
                conn.requestMethod = "POST"
                conn.setRequestProperty("Content-Type", "application/json")
                conn.doOutput = true
                conn.connectTimeout = 10000
                conn.readTimeout = 10000
                conn.outputStream.bufferedWriter().use { it.write(data.toString()) }
                val body = if (conn.responseCode in 200..299) {
                    conn.inputStream.bufferedReader().use { it.readText() }
                } else throw Exception("HTTP ${conn.responseCode}")
                JSONObject(body)
            } finally {
                conn.disconnect()
            }
        }
    }

    private fun sendAlertNotification(title: String, text: String) {
        val nm = getSystemService(NotificationManager::class.java) ?: return
        val notif = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(text)
            .setSmallIcon(android.R.drawable.ic_dialog_alert)
            .setStyle(NotificationCompat.BigTextStyle().bigText(text))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .build()
        nm.notify(System.currentTimeMillis().toInt(), notif)
    }

    private fun sendToFlutter(event: String, data: Map<String, String>) {
        try {
            val engine = FlutterEngineCache.getInstance().get("main_engine")
            val channel = MethodChannel(engine?.dartExecutor?.binaryMessenger ?: return, "com.cybershield/sms_protection")
            val args = mutableMapOf<String, Any>("event" to event)
            args.putAll(data)
            channel.invokeMethod("onSmsEvent", args)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to send to Flutter: ${e.message}")
        }
    }
}