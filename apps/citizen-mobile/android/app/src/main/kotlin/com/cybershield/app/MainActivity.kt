package com.cybershield.app

import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.cybershield.ai.services.RaksaarPluginHandler

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Register RAKSAAR native plugin handler for MethodChannel/EventChannel
        RaksaarPluginHandler.register(flutterEngine, this, this)
        
        // Register accessibility service check channel (used by PermissionManager)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.cybershield/accessibility"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "isAccessibilityServiceEnabled" -> {
                    try {
                        val enabled = Settings.Secure.getInt(
                            contentResolver,
                            Settings.Secure.ACCESSIBILITY_ENABLED, 0
                        ) == 1
                        if (!enabled) {
                            result.success(false)
                            return@setMethodCallHandler
                        }
                        val packageName = applicationContext.packageName
                        val serviceClass = "${packageName}.services.WhatsappAccessibilityService"
                        val enabledServices = Settings.Secure.getString(
                            contentResolver,
                            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
                        ) ?: ""
                        result.success(enabledServices.contains(serviceClass))
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
