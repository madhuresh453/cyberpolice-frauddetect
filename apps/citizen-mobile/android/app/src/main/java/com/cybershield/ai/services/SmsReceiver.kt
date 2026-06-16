package com.cybershield.ai.services

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Telephony
import android.telephony.SmsMessage
import android.util.Log
import kotlinx.coroutines.*
import java.net.HttpURLConnection
import java.net.URL
import java.net.URLEncoder

class SmsReceiver : BroadcastReceiver() {
    companion object {
        const val TAG = "RAKSAAR_SMS"
        private val serviceScope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
            val messages = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                Telephony.Sms.Intents.getMessagesFromIntent(intent)
            } else {
                parseSmsMessages(intent)
            }

            for (message in messages) {
                val sender = message.originatingAddress ?: continue
                val text = message.messageBody ?: continue
                Log.d(TAG, "SMS from $sender: ${text.substring(0, minOf(50, text.length))}...")
                analyzeSms(context, sender, text)
            }
        }
    }

    private fun analyzeSms(context: Context, sender: String, text: String) {
        serviceScope.launch {
            try {
                // URL encode the text to handle special characters
                val encodedText = URLEncoder.encode(text, "UTF-8")
                val url = URL("http://10.0.2.2:8000/analyze/sms?text=$encodedText&sender=${URLEncoder.encode(sender, "UTF-8")}")
                val conn = url.openConnection() as HttpURLConnection
                conn.requestMethod = "POST"
                conn.doOutput = true
                conn.connectTimeout = 5000
                conn.readTimeout = 5000

                val response = conn.inputStream.bufferedReader().readText()
                Log.d(TAG, "SMS analysis result: $response")

                val json = org.json.JSONObject(response)
                if (json.optBoolean("is_scam", false)) {
                    // Send broadcast to show notification
                    val alertIntent = Intent("com.cybershield.ai.SCAM_ALERT").apply {
                        putExtra("type", "sms")
                        putExtra("sender", sender)
                        putExtra("risk_score", json.optInt("risk_score", 0))
                        putExtra("scam_type", json.optString("scam_type", "Unknown"))
                        putExtra("message", json.optString("recommendation", ""))
                    }
                    context.sendBroadcast(alertIntent)
                    Log.w(TAG, "⚠️ SMS SCAM DETECTED from $sender: ${json.optString("scam_type")}")
                }
            } catch (e: Exception) {
                Log.e(TAG, "SMS analysis error", e)
            }
        }
    }

    private fun parseSmsMessages(intent: Intent): Array<SmsMessage> {
        val pdus = intent.getSerializableExtra("pdus") as? Array<*> ?: return emptyArray()
        val format = intent.getStringExtra("format")
        return pdus.mapNotNull { pdu ->
            try {
                if (format != null) SmsMessage.createFromPdu(pdu as ByteArray, format)
                else SmsMessage.createFromPdu(pdu as ByteArray)
            } catch (e: Exception) {
                null
            }
        }.toTypedArray()
    }
}