package org.gsmlg.app

import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.net.Uri
import android.provider.OpenableColumns
import android.webkit.MimeTypeMap
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import kotlin.math.max
import kotlin.math.roundToInt

class MainActivity : FlutterActivity() {
    private var editorBridge: EditorFileBridge? = null
    private var clipboardChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        CompanionHost.bind(this, flutterEngine)
        editorBridge = EditorFileBridge(this, flutterEngine.dartExecutor.binaryMessenger).also {
            it.openIntent(intent)
        }
        clipboardChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "gsmlg/clipboard",
        ).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "readAttachments" -> result.success(readClipboardAttachments())
                    "normalizeImage" -> {
                        val bytes = call.argument<ByteArray>("bytes")
                        if (bytes == null) {
                            result.success(null)
                        } else {
                            val maxDimension = call.argument<Int>("maxDimension") ?: 1568
                            val quality = call.argument<Int>("quality") ?: 82
                            val maxBytes = call.argument<Int>("maxBytes") ?: (512 * 1024)
                            result.success(normalizeImageBytes(bytes, maxDimension, quality, maxBytes))
                        }
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    private fun readClipboardAttachments(): List<Map<String, Any?>> {
        val manager = getSystemService(Context.CLIPBOARD_SERVICE) as? ClipboardManager
            ?: return emptyList()
        val clip = manager.primaryClip ?: return emptyList()
        val maxBytes = 25 * 1024 * 1024
        val items = mutableListOf<Map<String, Any?>>()
        val timestamp = System.currentTimeMillis()

        for (i in 0 until clip.itemCount) {
            val uri = clip.getItemAt(i).uri ?: continue
            val entry = readUriAttachment(uri, maxBytes, timestamp, i) ?: continue
            items.add(entry)
        }
        return items
    }

    private fun readUriAttachment(
        uri: Uri,
        maxBytes: Int,
        timestamp: Long,
        index: Int,
    ): Map<String, Any?>? {
        return try {
            val mimeType = contentResolver.getType(uri)
            val ext = mimeType?.let { MimeTypeMap.getSingleton().getExtensionFromMimeType(it) }
            val fallbackName = if (ext != null) {
                "pasted_${timestamp}_${index + 1}.$ext"
            } else {
                "pasted_${timestamp}_${index + 1}"
            }
            val displayName = queryDisplayName(uri) ?: fallbackName
            val bytes = contentResolver.openInputStream(uri)?.use { input ->
                val out = ByteArrayOutputStream()
                val buffer = ByteArray(16 * 1024)
                var total = 0
                while (true) {
                    val read = input.read(buffer)
                    if (read == -1) break
                    total += read
                    if (total > maxBytes) return null
                    out.write(buffer, 0, read)
                }
                out.toByteArray()
            } ?: return null
            mapOf(
                "name" to displayName,
                "mimeType" to mimeType,
                "bytes" to bytes,
                "sizeBytes" to bytes.size,
            )
        } catch (_: Exception) {
            null
        }
    }

    private fun queryDisplayName(uri: Uri): String? {
        return contentResolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null)
            ?.use { cursor ->
                if (cursor.moveToFirst()) {
                    val col = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                    if (col >= 0) cursor.getString(col) else null
                } else {
                    null
                }
            }
    }

    private fun normalizeImageBytes(
        bytes: ByteArray,
        maxDimension: Int,
        quality: Int,
        maxBytes: Int,
    ): Map<String, Any>? {
        return try {
            val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
            BitmapFactory.decodeByteArray(bytes, 0, bytes.size, bounds)
            val width = bounds.outWidth
            val height = bounds.outHeight
            if (width <= 0 || height <= 0) return null
            val longest = max(width, height)
            if (bytes.size <= maxBytes && longest <= maxDimension) return null

            var sampleSize = 1
            while ((longest / (sampleSize * 2)) >= maxDimension) {
                sampleSize *= 2
            }
            val decodeOpts = BitmapFactory.Options().apply { inSampleSize = sampleSize }
            val decoded = BitmapFactory.decodeByteArray(bytes, 0, bytes.size, decodeOpts)
                ?: return null
            val scale = if (max(decoded.width, decoded.height) > maxDimension) {
                maxDimension.toFloat() / max(decoded.width, decoded.height).toFloat()
            } else {
                1.0f
            }
            val targetWidth = max(1, (decoded.width * scale).roundToInt())
            val targetHeight = max(1, (decoded.height * scale).roundToInt())
            val scaled = if (targetWidth != decoded.width || targetHeight != decoded.height) {
                Bitmap.createScaledBitmap(decoded, targetWidth, targetHeight, true)
            } else {
                decoded
            }
            val flattened = Bitmap.createBitmap(targetWidth, targetHeight, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(flattened)
            canvas.drawColor(Color.WHITE)
            canvas.drawBitmap(scaled, 0f, 0f, null)
            val out = ByteArrayOutputStream()
            flattened.compress(Bitmap.CompressFormat.JPEG, quality.coerceIn(40, 95), out)
            if (scaled !== decoded) scaled.recycle()
            decoded.recycle()
            flattened.recycle()
            val jpegBytes = out.toByteArray()
            if (jpegBytes.size >= bytes.size) return null
            mapOf(
                "bytes" to jpegBytes,
                "mimeType" to "image/jpeg",
                "extension" to "jpg",
            )
        } catch (_: Exception) {
            null
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        editorBridge?.openIntent(intent)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (editorBridge?.onActivityResult(requestCode, resultCode, data) == true) return
        super.onActivityResult(requestCode, resultCode, data)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        clipboardChannel?.setMethodCallHandler(null)
        clipboardChannel = null
        editorBridge?.close()
        editorBridge = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    override fun onResume() {
        super.onResume()
        CompanionHost.resume(this)
    }

    override fun onDestroy() {
        CompanionHost.unbind(this, isChangingConfigurations)
        super.onDestroy()
    }
}
