package com.app.system_metrics

import android.app.ActivityManager
import android.content.Context
import android.os.Build
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.Date

/** SystemMetricsPlugin */
class SystemMetricsPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "app_system_metrics")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getData" -> {
                try {
                    val data = getData()
                    result.success(data)
                } catch (e: Exception) {
                    result.error("ERROR", "Failed to get system metrics: ${e.message}", null)
                }
            }
            "refresh" -> {
                try {
                    result.success(null)
                } catch (e: Exception) {
                    result.error("ERROR", "Failed to refresh: ${e.message}", null)
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun getData(): Map<String, Any> {
        val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val mi = ActivityManager.MemoryInfo()
        activityManager.getMemoryInfo(mi)
        val totalMem = mi.totalMem.toDouble()
        val availMem = mi.availMem.toDouble()
        val memUsage = ((totalMem - availMem) / totalMem) * 100.0

        var cpuUsage = 0.0
        try {
            val loadAvgStr = java.io.File("/proc/loadavg").readText().trim()
            val load = loadAvgStr.split(" ")[0].toDoubleOrNull()
            if (load != null) {
                val cores = Runtime.getRuntime().availableProcessors()
                cpuUsage = (load / cores * 100.0).coerceIn(0.0, 100.0)
            }
        } catch (e: Exception) {
            cpuUsage = 0.0
        }

        return mapOf(
            "platform" to "android",
            "timestamp" to Date().toInstant().toString(),
            "cpuUsage" to cpuUsage,
            "gpuUsage" to 0.0,
            "npuUsage" to 0.0,
            "memoryUsage" to memUsage,
            "additionalData" to mapOf(
                "manufacturer" to Build.MANUFACTURER,
                "model" to Build.MODEL,
                "brand" to Build.BRAND,
                "device" to Build.DEVICE,
                "sdkInt" to Build.VERSION.SDK_INT,
                "release" to Build.VERSION.RELEASE
            )
        )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
