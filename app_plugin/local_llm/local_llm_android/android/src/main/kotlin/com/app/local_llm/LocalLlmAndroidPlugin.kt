package com.app.local_llm

import android.app.ActivityManager
import android.os.Handler
import android.os.Looper
import java.io.File
import java.security.MessageDigest
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
            "prepareTitleModel" -> prepareTitleModel(result)
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

    // A file path is required by llama.cpp. Stream from the install-time APK
    // asset without allocating a model-sized JVM or Dart buffer.
    private fun prepareTitleModel(result: Result) {
        val appContext = context
        Thread {
            try {
                val manager = appContext.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                val memory = ActivityManager.MemoryInfo()
                manager.getMemoryInfo(memory)
                check(!manager.isLowRamDevice && memory.availMem >= 2L * 1024 * 1024 * 1024) {
                    "Insufficient available memory for optional title inference"
                }
                val digest = "81b64d05a23b17b34c475f42b3e72fbde62d4b92cc34541f7a8031d0752deafa"
                val directory = File(appContext.noBackupFilesDir, "conversation_title/$digest")
                directory.mkdirs()
                val target = File(directory, "MiniCPM5-1B-Q4_K_M.gguf")
                if (!target.exists() || target.length() != 688065920L) {
                    val temporary = File(directory, "model.partial")
                    try {
                        val hash = MessageDigest.getInstance("SHA-256")
                        val asset = "models/conversation_title/MiniCPM5-1B-Q4_K_M.gguf"
                        val stream = try {
                            appContext.assets.open(asset) // install-time AAB asset pack
                        } catch (_: java.io.FileNotFoundException) {
                            appContext.assets.open("flutter_assets/assets/$asset") // standalone APK
                        }
                        stream.use { input ->
                            temporary.outputStream().use { output ->
                                val buffer = ByteArray(1024 * 1024)
                                while (true) {
                                    val count = input.read(buffer)
                                    if (count < 0) break
                                    hash.update(buffer, 0, count)
                                    output.write(buffer, 0, count)
                                }
                            }
                        }
                        check(hash.digest().joinToString("") { "%02x".format(it) } == digest) { "Invalid title model checksum" }
                        check(temporary.renameTo(target)) { "Cannot install title model" }
                    } finally { temporary.delete() }
                }
                Handler(Looper.getMainLooper()).post { result.success(target.absolutePath) }
            } catch (error: Exception) {
                Handler(Looper.getMainLooper()).post { result.error("title_model_unavailable", error.message, null) }
            }
        }.start()
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
