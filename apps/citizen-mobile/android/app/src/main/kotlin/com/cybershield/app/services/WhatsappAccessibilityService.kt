package com.cybershield.app.services

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Intent
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL

class WhatsappAccessibilityService : AccessibilityService() {

    companion object {
        private const val TAG = "WhatsappAccess"
        private const val API_BASE = "http://10.0.2.2:5000/api"
        var isRunning = false
            private set
        var instance: WhatsappAccessibilityService? = null
            private set
    }

    private val serviceScope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    private var lastProcessedText = ""
    private var lastProcessedTime = 0L

    override fun onServiceConnected() {
        super.onServiceConnected()
        isRunning = true
        instance = this

        serviceInfo = serviceInfo.apply {
            eventTypes = AccessibilityEvent.TYPE_NOTIFICATION_STATE_CHANGED or
                    AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED or
                    AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            flags = AccessibilityServiceInfo.FLAG_INCLUDE_NOT_IMPORTANT_VIEWS or
                    AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS or
                    AccessibilityServiceInfo.FLAG_RETRIEVE_INTERACTIVE_WINDOWS
            notificationTimeout = 500
        }
        Log.i(TAG, "WhatsappAccessibilityService connected")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return

        val packageName = event.packageName?.toString() ?: return

        // Only process WhatsApp notifications and content
        if (packageName != "com.whatsapp" && packageName != "com.whatsapp.w4b") return

        when (event.eventType) {
            AccessibilityEvent.TYPE_NOTIFICATION_STATE_CHANGED -> {
                handleNotification(event)
            }
            AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED -> {
                handleWindowContent(event)
            }
        }
    }

    private fun handleNotification(event: AccessibilityEvent) {
        val texts = event.text?.map { it.toString() } ?: return
        val fullText = texts.joinToString(" ")

        if (fullText.isBlank()) return

        // Deduplicate
        val now = System.currentTimeMillis()
        if (fullText == lastProcessedText && now - lastProcessedTime < 5000) return
        lastProcessedText = fullText
        lastProcessedTime = now

        Log.i(TAG, "WhatsApp notification: ${fullText.take(100)}")

        analyzeMessage("WhatsApp Notification", fullText)
    }

    private fun handleWindowContent(event: AccessibilityEvent) {
        try {
            val rootNode = rootInActiveWindow ?: return
            val packageName = event.packageName?.toString() ?: return

            if (packageName != "com.whatsapp" && packageName != "com.whatsapp.w4b") return

            // Find message text nodes
            val messageNodes = mutableListOf<String>()
            findMessageNodes(rootNode, messageNodes)

            val fullText = messageNodes.joinToString(" ").trim()
            if (fullText.isBlank() || fullText.length < 5) return

            // Deduplicate
            val now = System.currentTimeMillis()
            if (fullText == lastProcessedText && now - lastProcessedTime < 10000) return
            lastProcessedText = fullText
            lastProcessedTime = now

            analyzeMessage("WhatsApp Message", fullText)
        } catch (e: Exception) {
            Log.e(TAG, "Error reading WhatsApp content: ${e.message}")
        }
    }

    private fun findMessageNodes(node: AccessibilityNodeInfo, results: MutableList<String>) {
        if (node.text != null) {
            val text = node.text.toString()
            if (text.length > 5 && !text.matches(Regex("^\\d{1,2}:\\d{2}$"))) {
                results.add(text)
            }
        }
        for (i in 0 until node.childCount) {
            val child = node.getChild(i) ?: continue
            findMessageNodes(child, results)
        }
    }

    private fun analyzeMessage(source: String, messageBody: String) {
        serviceScope.launch {
            try {
                // Local fraud detection
                val fraudKeywords = listOf(
                    "kyc", "verify your account", "account blocked", "urgent action",
                    "winning prize", "lottery", "congratulations you won",
                    "click here", "limited time offer", "act now",
                    "bank account suspended", "share your pin", "cvv", "atm pin",
                    "investment opportunity", "guaranteed returns", "double your money",
                    "crypto investment", "risk free"
                )

                val matched = fraudKeywords.filter { messageBody.contains(it, ignoreCase = true) }
                val hasUrl = Regex("https?://\\S+").containsMatchIn(messageBody)
                var riskScore = matched.size * 15 + if (hasUrl) 15 else 0
                riskScore = riskScore.coerceAtMost(100)

                // Backend analysis
                val apiResult = try {
                    val data = JSONObject().apply {
                        put("message_body", messageBody)
                        put("source", "whatsapp")
                        put("local_risk_score", riskScore)
                    }
                    apiCall("$API_BASE/analysis/whatsapp", data)
                } catch (e: Exception) {
                    null
                }

                val finalScore = apiResult?.optInt("fraud_probability", riskScore) ?: riskScore
                val isFraud = finalScore > 50

                sendToFlutter("whatsapp_analyzed", mapOf(
                    "source" to source,
                    "message_body" to messageBody.take(500),
                    "risk_score" to finalScore.toString(),
                    "is_fraud" to isFraud.toString(),
                    "matched_keywords" to matched.joinToString(",")
                ))

                if (isFraud) {
                    val nm = getSystemService(android.app.NotificationManager::class.java) ?: return@launch
                    val channelId = "cybershield_whatsapp_alerts"
                    val channel = android.app.NotificationChannel(channelId, "WhatsApp Fraud Alerts", android.app.NotificationManager.IMPORTANCE_HIGH)
                    nm.createNotificationChannel(channel)

                    val notif = androidx.core.app.NotificationCompat.Builder(this@WhatsappAccessibilityService, channelId)
                        .setContentTitle("WhatsApp Scam Detected")
                        .setContentText("Suspicious message detected (Risk: $finalScore%)")
                        .setSmallIcon(android.R.drawable.ic_dialog_alert)
                        .setPriority(androidx.core.app.NotificationCompat.PRIORITY_HIGH)
                        .setAutoCancel(true)
                        .build()
                    nm.notify(System.currentTimeMillis().toInt(), notif)
                }
            } catch (e: Exception) {
                Log.e(TAG, "WhatsApp analysis failed: ${e.message}")
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

    private fun sendToFlutter(event: String, data: Map<String, String>) {
        try {
            val engine = FlutterEngineCache.getInstance().get("main_engine")
            val channel = MethodChannel(engine?.dartExecutor?.binaryMessenger ?: return, "com.cybershield/whatsapp_protection")
            val args = mutableMapOf<String, Any>("event" to event)
            args.putAll(data)
            channel.invokeMethod("onWhatsappEvent", args)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to send to Flutter: ${e.message}")
        }
    }

    override fun onInterrupt() {
        isRunning = false
        instance = null
        serviceScope.cancel()
        Log.i(TAG, "WhatsappAccessibilityService interrupted")
    }

    override fun onDestroy() {
        isRunning = false
        instance = null
        serviceScope.cancel()
        super.onDestroy()
    }
}