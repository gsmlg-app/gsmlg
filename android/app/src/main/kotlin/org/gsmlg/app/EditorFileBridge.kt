package org.gsmlg.app

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Process
import android.provider.DocumentsContract
import android.provider.OpenableColumns
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.File
import java.util.concurrent.Executors

/** Keeps document-provider URIs as identities; never substitutes a cache copy. */
internal class EditorFileBridge(
    private val activity: Activity,
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler {
    private val channel = MethodChannel(messenger, "gsmlg/editor")
    private val io = Executors.newSingleThreadExecutor()
    private val pendingOpens = mutableListOf<String>()
    private var ready = false
    private var pickerResult: MethodChannel.Result? = null
    private var exportBytes: ByteArray? = null

    init { channel.setMethodCallHandler(this) }

    fun openIntent(intent: Intent?) {
        if (intent?.action != Intent.ACTION_VIEW && intent?.action != Intent.ACTION_EDIT) return
        val uris = mutableListOf<Uri>()
        intent?.data?.let { uris.add(it) }
        intent?.clipData?.let { clip ->
            for (index in 0 until clip.itemCount) clip.getItemAt(index).uri?.let { uris.add(it) }
        }
        val files = uris.distinct().filter { it.scheme == "content" || it.scheme == "file" }
        files.forEach { retainGrant(it, intent?.flags ?: 0) }
        val values = files.map { it.toString() }
        if (values.isEmpty()) return
        if (ready) channel.invokeMethod("openFiles", values) else pendingOpens.addAll(values)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "ready" -> {
                ready = true
                result.success(pendingOpens.toList())
                pendingOpens.clear()
            }
            "pickFile" -> launchPicker(result, null, null)
            "saveFileAs" -> {
                val bytes = call.argument<ByteArray>("bytes")
                if (bytes == null) result.error("write_failed", "Missing file contents.", null)
                else launchPicker(result, call.argument<String>("name") ?: "untitled.txt", bytes)
            }
            "readFile" -> perform(result, "read_failed") { read(uri(call)) }
            "writeFile" -> perform(result, "write_failed") {
                val bytes = requireNotNull(call.argument<ByteArray>("bytes"))
                write(uri(call), bytes)
                true
            }
            else -> result.notImplemented()
        }
    }

    private fun uri(call: MethodCall): Uri {
        val uri = Uri.parse(requireNotNull(call.argument<String>("uri")))
        require(uri.scheme == "content" || uri.scheme == "file")
        return uri
    }

    private fun launchPicker(result: MethodChannel.Result, name: String?, bytes: ByteArray?) {
        if (pickerResult != null) {
            result.error(if (bytes == null) "read_failed" else "write_failed", "A document picker is already open.", null)
            return
        }
        pickerResult = result
        exportBytes = bytes
        val intent = Intent(if (bytes == null) Intent.ACTION_OPEN_DOCUMENT else Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "*/*"
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION or Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION)
            if (name != null) putExtra(Intent.EXTRA_TITLE, File(name).name.ifBlank { "untitled.txt" })
        }
        try {
            activity.startActivityForResult(intent, if (bytes == null) OPEN_REQUEST else SAVE_REQUEST)
        } catch (_: Exception) {
            pickerResult = null
            exportBytes = null
            result.error(if (bytes == null) "read_failed" else "write_failed", "Unable to open the document picker.", null)
        }
    }

    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != OPEN_REQUEST && requestCode != SAVE_REQUEST) return false
        val result = pickerResult ?: return true
        val bytes = exportBytes
        pickerResult = null
        exportBytes = null
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) {
            result.success(null)
            return true
        }
        retainGrant(uri, data?.flags ?: 0)
        if (requestCode == OPEN_REQUEST) perform(result, "read_failed") { read(uri) }
        else perform(result, "write_failed") {
            write(uri, requireNotNull(bytes))
            metadata(uri)
        }
        return true
    }

    private fun retainGrant(uri: Uri, flags: Int) {
        if (uri.scheme != "content" || flags and Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION == 0) return
        val grants = flags and (Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
        try { activity.contentResolver.takePersistableUriPermission(uri, grants) } catch (_: SecurityException) {
            // Some providers offer only the activity-lifetime grant. Keep the original URI.
        }
    }

    private fun metadata(uri: Uri): Map<String, Any> {
        if (uri.scheme == "file") {
            val file = File(requireNotNull(uri.path))
            return mapOf("uri" to uri.toString(), "name" to file.name, "writable" to file.canWrite())
        }
        var name = uri.lastPathSegment ?: "document.txt"
        var supportsWrite = true
        activity.contentResolver.query(uri, null, null, null, null)?.use { cursor ->
            if (cursor.moveToFirst()) {
                val nameIndex = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                if (nameIndex >= 0 && !cursor.isNull(nameIndex)) name = cursor.getString(nameIndex)
                val flagsIndex = cursor.getColumnIndex(DocumentsContract.Document.COLUMN_FLAGS)
                if (flagsIndex >= 0) supportsWrite = cursor.getInt(flagsIndex) and DocumentsContract.Document.FLAG_SUPPORTS_WRITE != 0
            }
        }
        val granted = activity.checkUriPermission(uri, Process.myPid(), Process.myUid(), Intent.FLAG_GRANT_WRITE_URI_PERMISSION) == PackageManager.PERMISSION_GRANTED
        return mapOf("uri" to uri.toString(), "name" to name, "writable" to (granted && supportsWrite))
    }

    private fun read(uri: Uri): Map<String, Any> {
        val stream = if (uri.scheme == "file") File(requireNotNull(uri.path)).inputStream()
            else activity.contentResolver.openInputStream(uri) ?: error("No input stream")
        val bytes = stream.use { input ->
            val output = ByteArrayOutputStream()
            val buffer = ByteArray(64 * 1024)
            while (true) {
                val count = input.read(buffer)
                if (count < 0) break
                if (output.size() + count > MAX_BYTES) throw FileTooLarge()
                output.write(buffer, 0, count)
            }
            output.toByteArray()
        }
        return metadata(uri) + ("bytes" to bytes)
    }

    private fun write(uri: Uri, bytes: ByteArray) {
        if (uri.scheme == "file") File(requireNotNull(uri.path)).outputStream().use { it.write(bytes) }
        else {
            // "wt" explicitly requests truncation; "w" alone can leave an old suffix.
            val output = activity.contentResolver.openOutputStream(uri, "wt") ?: error("No output stream")
            output.use { it.write(bytes) }
        }
    }

    private fun perform(result: MethodChannel.Result, errorCode: String, operation: () -> Any) {
        io.execute {
            try {
                val value = operation()
                activity.runOnUiThread { result.success(value) }
            } catch (_: FileTooLarge) {
                activity.runOnUiThread { result.error("too_large", "Files must be 16 MiB or smaller.", null) }
            } catch (_: Exception) {
                activity.runOnUiThread { result.error(errorCode, if (errorCode == "write_failed") "Unable to write the document." else "Unable to read the document.", null) }
            }
        }
    }

    fun close() {
        channel.setMethodCallHandler(null)
        pickerResult?.success(null)
        pickerResult = null
        exportBytes = null
        io.shutdown()
    }

    private class FileTooLarge : Exception()

    companion object {
        private const val MAX_BYTES = 16 * 1024 * 1024
        private const val OPEN_REQUEST = 7311
        private const val SAVE_REQUEST = 7312
    }
}
