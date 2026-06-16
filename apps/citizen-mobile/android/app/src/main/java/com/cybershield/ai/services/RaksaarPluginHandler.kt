package com.cybershield.ai.services

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Settings
import android.telephony.TelephonyManager
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel

/**
 * RAKSAAR Flutter Plugin Handler
 * Bridges Flutter (Dart) with Android Native services
 */
class RaksaarPluginHandler(
    private val context: Context,
    private val activity: Activity?
) : MethodChannel.MethodCallHandler {

    companion object {
        private const val CHANNEL = "com.cybershield.ai/bridge"
        private const val EVENT_CHANNEL = "com.cybershield.ai/events"
        
        fun register(flutterEngine: FlutterEngine, context: Context, activity: Activity?) {
            val handler = RaksaarPluginHandler(context, activity)
            
            // Method channel
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
                .setMethodCallHandler(handler)
            
            // Event channel for streaming events
            EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
                .setStreamHandler(handler.EventStreamHandler())
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startCallProtection" -> handleStartCallProtection(result)
            "stopCallProtection" -> handleStopCallProtection(result)
            "getCallState" -> handleGetCallState(result)
            "startSmsProtection" -> handleStartSmsProtection(result)
            "analyzeNumber" -> handleAnalyzeNumber(call, result)
            "showFraudAlert" -> handleShowFraudAlert(call, result)
            "encryptFile" -> handleEncryptFile(call, result)
            "generateHash" -> handleGenerateHash(call, result)
            "triggerSOS" -> handleTriggerSOS(call, result)
            "shareLocation" -> handleShareLocation(result)
            "startRecording" -> handleStartRecording(result)
            "stopRecording" -> handleStopRecording(result)
            "analyzeNotification" -> handleAnalyzeNotification(call, result)
            "isAccessibilityServiceEnabled" -> handleIsAccessibilityServiceEnabled(result)
            else -> result.notImplemented()
        }
    }

    // ===== Call Protection =====
    private fun handleStartCallProtection(result: MethodChannel.Result) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val intent = Intent(context, CallDetectionService::class.java)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.startForegroundService(intent)
                } else {
                    context.startService(intent)
                }
                result.success(true)
            } else {
                result.success(false)
            }
        } catch (e: Exception) {
            result.error("START_FAILED", e.message, null)
        }
    }

    private fun handleStopCallProtection(result: MethodChannel.Result) {
        try {
            context.stopService(Intent(context, CallDetectionService::class.java))
            result.success(true)
        } catch (e: Exception) {
            result.error("STOP_FAILED", e.message, null)
        }
    }

    private fun handleGetCallState(result: MethodChannel.Result) {
        try {
            val tm = context.getSystemService(Context.TELEPHONY_SERVICE) as? TelephonyManager
            val callState = tm?.callState ?: TelephonyManager.CALL_STATE_IDLE
            val state = when (callState) {
                TelephonyManager.CALL_STATE_IDLE -> "IDLE"
                TelephonyManager.CALL_STATE_RINGING -> "RINGING"
                TelephonyManager.CALL_STATE_OFFHOOK -> "OFFHOOK"
                else -> "UNKNOWN"
            }
            result.success(mapOf("state" to state, "number" to null))
        } catch (e: Exception) {
            result.success(mapOf("state" to "IDLE", "number" to null))
        }
    }

    // ===== SMS Protection =====
    private fun handleStartSmsProtection(result: MethodChannel.Result) {
        val hasSmsPermission = ContextCompat.checkSelfPermission(
            context, Manifest.permission.RECEIVE_SMS
        ) == PackageManager.PERMISSION_GRANTED
        result.success(hasSmsPermission)
    }

    // ===== Number Analysis =====
    private fun handleAnalyzeNumber(call: MethodCall, result: MethodChannel.Result) {
        val number = call.argument<String>("number") ?: ""
        // Use native classifier
        val classifier = com.cybershield.ai.sms.FraudClassifier()
        val score = classifier.analyzeNumber(number)
        result.success(mapOf(
            "number" to number,
            "score" to score,
            "risk" to if (score > 70) "high" else if (score > 40) "medium" else "low",
            "sources" to listOf("native_classifier", "fraud_db")
        ))
    }

    // ===== Fraud Alert Overlay =====
    private fun handleShowFraudAlert(call: MethodCall, result: MethodChannel.Result) {
        val riskScore = call.argument<Int>("riskScore") ?: 0
        val number = call.argument<String>("number") ?: "Unknown"
        val scamType = call.argument<String>("scamType") ?: "Suspicious"
        
        val overlayIntent = Intent(context, com.cybershield.ai.overlay.FraudAlertOverlay::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
            putExtra("risk_score", riskScore)
            putExtra("phone_number", number)
            putExtra("scam_type", scamType)
        }
        context.startActivity(overlayIntent)
        result.success(true)
    }

    // ===== Evidence Encryption =====
    private fun handleEncryptFile(call: MethodCall, result: MethodChannel.Result) {
        val path = call.argument<String>("path") ?: ""
        try {
            val hashService = com.cybershield.ai.evidence.EvidenceHashService.getInstance(context)
            val hash = hashService.hashFile(path)
            result.success(hash)
        } catch (e: Exception) {
            result.error("ENCRYPT_FAILED", e.message, null)
        }
    }

    private fun handleGenerateHash(call: MethodCall, result: MethodChannel.Result) {
        val data = call.argument<String>("data") ?: ""
        try {
            val hashService = com.cybershield.ai.evidence.EvidenceHashService.getInstance(context)
            val hash = hashService.hashString(data)
            result.success(hash)
        } catch (e: Exception) {
            result.error("HASH_FAILED", e.message, null)
        }
    }

    // ===== Emergency SOS =====
    private fun handleTriggerSOS(call: MethodCall, result: MethodChannel.Result) {
        val silent = call.argument<Boolean>("silent") ?: false
        // TODO: Implement actual SOS with location + audio
        result.success(true)
    }

    private fun handleShareLocation(result: MethodChannel.Result) {
        result.success(true)
    }

    // ===== Audio Recording =====
    private fun handleStartRecording(result: MethodChannel.Result) {
        result.success(null)
    }

    private fun handleStopRecording(result: MethodChannel.Result) {
        result.success(null)
    }

    // ===== Notification Analysis (WhatsApp etc.) =====
    private fun handleAnalyzeNotification(call: MethodCall, result: MethodChannel.Result) {
        val text = call.argument<String>("text") ?: ""
        val title = call.argument<String>("title") ?: ""
        
        val classifier = com.cybershield.ai.sms.FraudClassifier()
        val score = classifier.analyzeText("$title $text")
        
        result.success(mapOf(
            "is_fraud" to (score > 50),
            "score" to score,
            "risk" to if (score > 70) "high" else if (score > 40) "medium" else "low"
        ))
    }

    // ===== Accessibility Service Check =====
    private fun handleIsAccessibilityServiceEnabled(result: MethodChannel.Result) {
        try {
            val accessibilityEnabled = Settings.Secure.getInt(
                context.contentResolver,
                Settings.Secure.ACCESSIBILITY_ENABLED, 0
            ) == 1
            if (!accessibilityEnabled) {
                result.success(false)
                return
            }
            // Check if OUR specific accessibility service is running
            val servicePackage = context.packageName
            val serviceClass = "${servicePackage}.services.WhatsappAccessibilityService"
            val enabledServices = Settings.Secure.getString(
                context.contentResolver,
                Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
            ) ?: ""
            val isOurServiceEnabled = enabledServices.contains(serviceClass)
            result.success(isOurServiceEnabled)
        } catch (e: Exception) {
            result.success(false)
        }
    }

    // ===== Event Stream Handler =====
    inner class EventStreamHandler : EventChannel.StreamHandler {
        private var eventSink: EventChannel.EventSink? = null
        
        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            eventSink = events
            // Start broadcasting events
            notifyEvent("service_started", mapOf("status" to "running"))
        }

        override fun onCancel(arguments: Any?) {
            eventSink = null
        }

        fun notifyEvent(event: String, data: Map<String, Any>) {
            eventSink?.success(mapOf("event" to event, "data" to data))
        }
    }
}