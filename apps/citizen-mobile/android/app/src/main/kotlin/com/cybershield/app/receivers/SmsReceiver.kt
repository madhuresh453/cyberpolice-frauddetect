package com.cybershield.app.receivers

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import android.util.Log
import com.cybershield.app.services.SmsProtectionService

class SmsReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "SmsReceiver"
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action != Telephony.Sms.Intents.SMS_RECEIVED_ACTION) return

        val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
        if (messages.isNullOrEmpty()) return

        // Group messages by originating address (handles multi-part SMS)
        val groupedMessages = messages.groupBy { it.displayOriginatingAddress }
        
        for ((sender, parts) in groupedMessages) {
            val fullMessage = parts.joinToString("") { it.messageBody ?: "" }
            val senderNumber = sender ?: "Unknown"
            
            Log.i(TAG, "SMS received from: $senderNumber (${fullMessage.length} chars)")

            // Forward to SmsProtectionService for analysis
            try {
                val serviceIntent = Intent(context, SmsProtectionService::class.java).apply {
                    putExtra("from_number", senderNumber)
                    putExtra("message_body", fullMessage)
                }
                context?.startService(serviceIntent)
            } catch (e: Exception) {
                Log.e(TAG, "Failed to start SmsProtectionService: ${e.message}")
            }
        }
    }
}