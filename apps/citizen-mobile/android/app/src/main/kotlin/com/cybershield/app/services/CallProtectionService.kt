package com.cybershield.app.services

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.IBinder
import android.telephony.PhoneStateListener
import android.telephony.TelephonyManager
import android.util.Log
import androidx.core.app.NotificationCompat
import com.cybershield.app.MainActivity
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL

class CallProtectionService : Service() {

    companion object {
        private const val TAG = "CallProtection"
        private const val CHANNEL_ID = "cybershield_call_protection"
        private const val NOTIFICATION_ID = 1001
        private const val API_BASE = "http://10.0.2.2:5000/api"
        var isRunning = false
            private set
    }

    private var telephonyManager: TelephonyManager? = null
    private var phoneStateListener: PhoneStateListener? = null
    private val serviceScope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    private var currentCallNumber: String? = null
    private var callStartTime: Long = 0

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        isRunning = true
        createNotificationChannel()
        startForeground(NOTIFICATION_ID, buildNotification("Monitoring calls..."))
        startCallMonitoring()
        Log.i(TAG, "CallProtectionService started")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int = START_STICKY

    override fun onDestroy() {
        isRunning = false
        serviceScope.cancel()
        telephonyManager?.listen(phoneStateListener, PhoneStateListener.LISTEN_NONE)
        Log.i(TAG, "CallProtectionService stopped")
        super.onDestroy()
    }

    private fun createNotificationChannel() {
        val channel = NotificationChannel(CHANNEL_ID, "Call Protection", NotificationManager.IMPORTANCE_LOW).apply {
            description = "Monitoring incoming calls for fraud protection"
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
            .setSmallIcon(android.R.drawable.ic_dialog_phone)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .build()
    }

    private fun startCallMonitoring() {
        telephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as? TelephonyManager

        @Suppress("DEPRECATION")
        phoneStateListener = object : PhoneStateListener() {
            override fun onCallStateChanged(state: Int, phoneNumber: String?) {
                when (state) {
                    TelephonyManager.CALL_STATE_RINGING -> {
                        currentCallNumber = phoneNumber
                        callStartTime = System.currentTimeMillis()
                        Log.i(TAG, "Incoming call from: $phoneNumber")
                        evaluateNumberAsync(phoneNumber, "INCOMING")
                    }
                    TelephonyManager.CALL_STATE_OFFHOOK -> {
                        if (currentCallNumber != null) {
                            callStartTime = System.currentTimeMillis()
                        }
                    }
                    TelephonyManager.CALL_STATE_IDLE -> {
                        if (currentCallNumber != null) {
                            val duration = ((System.currentTimeMillis() - callStartTime) / 1000).toInt()
                            recordCallLog(currentCallNumber!!, duration)
                            currentCallNumber = null
                        }
                    }
                }
            }
        }

        @Suppress("DEPRECATION")
        telephonyManager?.listen(phoneStateListener, PhoneStateListener.LISTEN_CALL_STATE)
    }

    private fun evaluateNumberAsync(phoneNumber: String?, callType: String) {
        if (phoneNumber.isNullOrBlank()) return

        serviceScope.launch {
            try {
                val data = JSONObject().apply {
                    put("phone_number", phoneNumber)
                    put("call_type", callType)
                }
                val result = apiCall("$API_BASE/trust-score", data)
                val trustScore = result.optInt("trust_score", 50)
                val riskCategory = result.optString("risk_category", "unknown")

                val eventName = if (trustScore < 30 || riskCategory == "high") {
                    if (trustScore < 20) sendAlertNotification("HIGH RISK CALL", "Caller: $phoneNumber (Trust: $trustScore/100)")
                    else sendAlertNotification("SUSPICIOUS CALL", "Caller: $phoneNumber (Trust: $trustScore/100)")
                    "call_warning"
                } else {
                    "call_safe"
                }

                sendToFlutter(eventName, mapOf(
                    "phoneNumber" to phoneNumber,
                    "trust_score" to trustScore.toString(),
                    "risk_category" to riskCategory,
                    "call_type" to callType
                ))
            } catch (e: Exception) {
                Log.e(TAG, "API call failed: ${e.message}", e)
                sendToFlutter("call_error", mapOf("phoneNumber" to phoneNumber.orEmpty(), "error" to e.message.orEmpty()))
            }
        }
    }

    private fun recordCallLog(phoneNumber: String, duration: Int) {
        serviceScope.launch {
            try {
                val data = JSONObject().apply {
                    put("caller_number", phoneNumber)
                    put("duration", duration)
                }
                apiCall("$API_BASE/reports/call", data)
            } catch (e: Exception) {
                Log.e(TAG, "Failed to report call: ${e.message}")
            }
        }
    }

    private suspend fun apiCall(urlStr: String, data: JSONObject): JSONObject {
        return withContext(Dispatchers.IO) {
            val conn = URL(urlStr).openConnection() as HttpURLConnection
            try {
                conn.requestMethod = "POST"
                conn.setRequestProperty("Content-Type", "application/json")
                conn.setRequestProperty("Accept", "application/json")
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
            val channel = MethodChannel(engine?.dartExecutor?.binaryMessenger ?: return, "com.cybershield/call_protection")
            val args = mutableMapOf<String, Any>("event" to event)
            args.putAll(data)
            channel.invokeMethod("onCallEvent", args)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to send to Flutter: ${e.message}")
        }
    }
}