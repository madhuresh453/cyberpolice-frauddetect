package com.cybershield.ai.services
import android.telephony.PhoneStateListener
import android.Manifest
import android.app.*
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.os.IBinder
import android.telephony.TelephonyManager
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import kotlinx.coroutines.*
import java.io.File
import java.io.FileOutputStream
import java.net.HttpURLConnection
import java.net.URL

class CallDetectionService : Service() {
    companion object {
        const val TAG = "RAKSAAR_CALL"
        const val CHANNEL_ID = "raksaar_call_protection"
        const val NOTIFICATION_ID = 1001
        const val FOREGROUND_CHANNEL_ID = "raksaar_foreground"
        const val FOREGROUND_NOTIFICATION_ID = 1002
    }

    private lateinit var telephonyManager: TelephonyManager
    private lateinit var callStateReceiver: CallStateReceiver
    private var audioRecord: AudioRecord? = null
    private var isRecording = false
    private val serviceScope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    private var currentCallNumber: String? = null

    // ===== ANDROID 11+ (API 30) PERMISSION HANDLING =====
    // PHONE: READ_PHONE_STATE, CALL_PHONE
    // AUDIO: RECORD_AUDIO
    // FOREGROUND: FOREGROUND_SERVICE, FOREGROUND_SERVICE_MICROPHONE (Android 14+)
    // OVERLAY: SYSTEM_ALERT_WINDOW

    override fun onCreate() {
        super.onCreate()
        createNotificationChannels()
        telephonyManager = getSystemService(TELEPHONY_SERVICE) as TelephonyManager
        callStateReceiver = CallStateReceiver()

        // Register phone state listener
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            // Android 12+ requires READ_PHONE_STATE permission
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE)
                == PackageManager.PERMISSION_GRANTED
            ) {
                telephonyManager.listen(phoneStateListener, PhoneStateListener.LISTEN_CALL_STATE)
            }
        } else {
            // Android 11 and below
            telephonyManager.listen(phoneStateListener, PhoneStateListener.LISTEN_CALL_STATE)
        }

        // Register broadcast receiver for call state changes
        val filter = IntentFilter().apply {
            addAction(TelephonyManager.ACTION_PHONE_STATE_CHANGED)
            addAction("android.intent.action.PHONE_STATE")
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                // Android 14+ requires declaring broadcast receiver in manifest
            }
        }
        registerReceiver(callStateReceiver, filter)
        Log.d(TAG, "CallDetectionService created")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val notification = createForegroundNotification()
        startForeground(FOREGROUND_NOTIFICATION_ID, notification)
        Log.d(TAG, "CallDetectionService foreground started")
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        super.onDestroy()
        telephonyManager.listen(phoneStateListener, PhoneStateListener.LISTEN_NONE)
        unregisterReceiver(callStateReceiver)
        stopRecording()
        serviceScope.cancel()
        Log.d(TAG, "CallDetectionService destroyed")
    }

    private val phoneStateListener = object : PhoneStateListener() {
        override fun onCallStateChanged(state: Int, phoneNumber: String?) {
            when (state) {
                TelephonyManager.CALL_STATE_RINGING -> {
                    currentCallNumber = phoneNumber
                    Log.d(TAG, "Incoming call from: $phoneNumber")
                    handleIncomingCall(phoneNumber)
                }
                TelephonyManager.CALL_STATE_OFFHOOK -> {
                    Log.d(TAG, "Call answered - starting audio analysis")
                    startCallAnalysis()
                }
                TelephonyManager.CALL_STATE_IDLE -> {
                    Log.d(TAG, "Call ended")
                    stopCallAnalysis()
                    currentCallNumber = null
                }
            }
        }
    }

    private fun handleIncomingCall(phoneNumber: String?) {
        val number = phoneNumber ?: return
        serviceScope.launch {
            try {
                // Step 1: Check number reputation via AI Gateway
                val reputation = checkNumberReputation(number)
                Log.d(TAG, "Number reputation: $reputation")

                // Step 2: Show overlay warning based on risk
                val riskLevel = reputation.optInt("risk_score", 0)
                showCallOverlay(number, riskLevel)

            } catch (e: Exception) {
                Log.e(TAG, "Error handling incoming call", e)
            }
        }
    }

    private suspend fun checkNumberReputation(phoneNumber: String): org.json.JSONObject {
        return withContext(Dispatchers.IO) {
            try {
                val url = URL("${getAIGatewayUrl()}/threat-intel/phone/$phoneNumber")
                val conn = url.openConnection() as HttpURLConnection
                conn.requestMethod = "GET"
                conn.connectTimeout = 5000
                conn.readTimeout = 5000
                val response = conn.inputStream.bufferedReader().readText()
                org.json.JSONObject(response)
            } catch (e: Exception) {
                Log.e(TAG, "Failed to check reputation", e)
                org.json.JSONObject().apply { put("risk_score", 0) }
            }
        }
    }

    private fun getAIGatewayUrl(): String {
        return "http://10.0.2.2:8000" // Android emulator → host localhost
    }

    private fun showCallOverlay(phoneNumber: String, riskScore: Int) {
        val intent = Intent(this, CallOverlayService::class.java).apply {
            putExtra("phone_number", phoneNumber)
            putExtra("risk_score", riskScore)
        }
        ContextCompat.startForegroundService(this, intent)
    }

    private fun startCallAnalysis() {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO)
            != PackageManager.PERMISSION_GRANTED
        ) {
            Log.w(TAG, "RECORD_AUDIO permission not granted")
            return
        }

        isRecording = true
        serviceScope.launch {
            try {
                val bufferSize = AudioRecord.getMinBufferSize(
                    16000, AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT
                )
                audioRecord = AudioRecord(
                    MediaRecorder.AudioSource.VOICE_COMMUNICATION,
                    16000, AudioFormat.CHANNEL_IN_MONO,
                    AudioFormat.ENCODING_PCM_16BIT, bufferSize
                )

                audioRecord?.startRecording()
                val buffer = ByteArray(bufferSize)
                val audioFile = File(cacheDir, "call_analysis_${System.currentTimeMillis()}.wav")
                val outputStream = FileOutputStream(audioFile)

                // Record 30 seconds max for analysis
                var bytesRead: Int
                var totalBytes = 0
                val maxBytes = 16000 * 2 * 30 // 30 seconds of 16kHz 16-bit mono

                while (isRecording && totalBytes < maxBytes) {
                    bytesRead = audioRecord?.read(buffer, 0, buffer.size) ?: -1
                    if (bytesRead > 0) {
                        outputStream.write(buffer, 0, bytesRead)
                        totalBytes += bytesRead

                        // Send chunks every 2 seconds to AI Gateway for real-time analysis
                        if (totalBytes % (16000 * 2 * 2) < buffer.size) {
                            sendAudioChunk(buffer.copyOf(), bytesRead)
                        }
                    }
                }

                outputStream.close()
                audioRecord?.stop()
                audioRecord?.release()
                audioRecord = null

                // Send full audio for complete analysis
                sendFullAudio(audioFile)
                Log.d(TAG, "Call analysis complete: ${audioFile.length()} bytes")

            } catch (e: Exception) {
                Log.e(TAG, "Error during call recording", e)
            }
        }
    }

    private suspend fun sendAudioChunk(chunk: ByteArray, size: Int) {
        withContext(Dispatchers.IO) {
            try {
                val url = URL("${getAIGatewayUrl()}/analyze/call")
                val conn = url.openConnection() as HttpURLConnection
                conn.requestMethod = "POST"
                conn.doOutput = true
                conn.setRequestProperty("Content-Type", "audio/wav")
                conn.outputStream.write(chunk, 0, size)
                val response = conn.inputStream.bufferedReader().readText()
                Log.d(TAG, "Chunk analysis: $response")
            } catch (e: Exception) {
                Log.e(TAG, "Failed to send chunk", e)
            }
        }
    }

    private suspend fun sendFullAudio(audioFile: File) {
        withContext(Dispatchers.IO) {
            try {
                val url = URL("${getAIGatewayUrl()}/analyze/call?phone_number=$currentCallNumber")
                val conn = url.openConnection() as HttpURLConnection
                conn.requestMethod = "POST"
                conn.doOutput = true
                conn.setRequestProperty("Content-Type", "audio/wav")
                audioFile.inputStream().use { it.copyTo(conn.outputStream) }
                val response = conn.inputStream.bufferedReader().readText()
                Log.d(TAG, "Full analysis result: $response")

                // Generate evidence if scam detected
                val json = org.json.JSONObject(response)
                if (json.optInt("risk_score", 0) >= 70) {
                    generateEvidencePackage(json)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Failed to send full audio", e)
            }
        }
    }

    private suspend fun generateEvidencePackage(analysisResult: org.json.JSONObject) {
        withContext(Dispatchers.IO) {
            val evidence = EvidencePackageGenerator(this@CallDetectionService).generate(
                callNumber = currentCallNumber ?: "unknown",
                transcript = analysisResult.optString("transcript", ""),
                riskScore = analysisResult.optInt("risk_score", 0),
                scamType = analysisResult.optJSONObject("scam_classification")?.optString("primary_type") ?: "unknown",
                metadata = mapOf(
                    "device" to Build.MODEL,
                    "android_version" to Build.VERSION.RELEASE,
                    "app_version" to "1.0.0"
                )
            )
            Log.d(TAG, "Evidence package generated: ${evidence.evidenceId}")
        }
    }

    private fun stopCallAnalysis() {
        isRecording = false
        audioRecord?.let {
            try {
                it.stop()
                it.release()
            } catch (e: Exception) {
                Log.e(TAG, "Error stopping recording", e)
            }
        }
        audioRecord = null

        // Stop overlay
        stopService(Intent(this, CallOverlayService::class.java))
    }

    private fun stopRecording() {
        isRecording = false
        audioRecord?.let {
            try {
                it.stop()
                it.release()
            } catch (e: Exception) {
                Log.e(TAG, "Error in stopRecording", e)
            }
        }
        audioRecord = null
    }

    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val callChannel = NotificationChannel(
                CHANNEL_ID, "Call Protection",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Scam call alerts"
                enableVibration(true)
                setSound(null, null)
            }

            val foregroundChannel = NotificationChannel(
                FOREGROUND_CHANNEL_ID, "RAKSAAR Protection",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Always-on protection service"
                setShowBadge(false)
            }

            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(callChannel)
            manager.createNotificationChannel(foregroundChannel)
        }
    }

    private fun createForegroundNotification(): Notification {
        return NotificationCompat.Builder(this, FOREGROUND_CHANNEL_ID)
            .setContentTitle("RAKSAAR Active")
            .setContentText("Call protection is running")
            .setSmallIcon(android.R.drawable.ic_menu_compass)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
            .build()
    }

    inner class CallStateReceiver : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val state = intent.getStringExtra(TelephonyManager.EXTRA_STATE)
            val number = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER)
            Log.d(TAG, "Broadcast: state=$state number=$number")
        }
    }
}