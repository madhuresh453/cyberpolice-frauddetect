package com.cybershield.ai.sms;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.provider.Telephony;
import android.telephony.SmsMessage;
import android.util.Log;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class SmsReceiver extends BroadcastReceiver {
    private static final String TAG = "SmsReceiver";
    private static final String SMS_RECEIVED = "android.provider.Telephony.SMS_RECEIVED";
    private final ExecutorService executorService = Executors.newSingleThreadExecutor();

    @Override
    public void onReceive(Context context, Intent intent) {
        if (!SMS_RECEIVED.equals(intent.getAction())) return;

        Bundle bundle = intent.getExtras();
        if (bundle == null) return;

        Object[] pdus;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            pdus = (Object[]) bundle.get("pdus");
        } else {
            pdus = (Object[]) bundle.get("pdus");
        }

        if (pdus == null || pdus.length == 0) return;

        StringBuilder fullMessage = new StringBuilder();
        String sender = "";

        for (Object pdu : pdus) {
            SmsMessage message;
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                String format = bundle.getString("format");
                message = SmsMessage.createFromPdu((byte[]) pdu, format);
            } else {
                message = SmsMessage.createFromPdu((byte[]) pdu);
            }

            if (message != null) {
                sender = message.getOriginatingAddress() != null ? message.getOriginatingAddress() : "";
                fullMessage.append(message.getMessageBody());
            }
        }

        if (sender.isEmpty()) return;
        Log.d(TAG, "SMS received from: " + sender);

final String finalSender = sender;
final String finalMessage = fullMessage.toString();

executorService.execute(() -> {
    try {
        SmsScanner scanner = new SmsScanner(context);
        scanner.analyzeSms(finalSender, finalMessage);
    } catch (Exception e) {
        Log.e(TAG, "Error analyzing SMS", e);
    }
});
    }
}