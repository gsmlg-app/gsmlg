package com.app.local_llm

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class LocalLlmAndroidPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "app_local_llm_android/service")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "startService" -> startService(call, result)
            "stopService" -> {
                LocalLlmForegroundService.stop(context)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun startService(call: MethodCall, result: Result) {
        val title = call.argument<String>("title") ?: "Local LLM"
        val message = call.argument<String>("message") ?: "Local model is running."
        try {
            LocalLlmForegroundService.start(context, title, message)
            result.success(null)
        } catch (error: Exception) {
            result.error(
                "foreground_service_start_failed",
                "Failed to start local LLM foreground service: ${error.message}",
                null
            )
        }
    }
}
