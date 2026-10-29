package app.gsmlg.android_shell

import android.system.Os
import android.util.Log
import java.io.File
import java.io.FileOutputStream
import java.io.InputStream
import java.nio.charset.StandardCharsets
import java.util.zip.GZIPInputStream

/**
 * Pure Kotlin TAR/GZ extractor with support for POSIX ustar and GNU long names,
 * directories, regular files, symbolic links, and file permissions.
 */
object TarExtractor {
    private const val TAG = "TarExtractor"
    private const val BLOCK_SIZE = 512

    fun extractGzipTar(
        inputStream: InputStream,
        targetDir: File,
        totalBytesEstimated: Long = 0,
        onProgress: ((bytesRead: Long, totalBytes: Long) -> Unit)? = null
    ) {
        val gzipStream = GZIPInputStream(inputStream)
        val buffer = ByteArray(BLOCK_SIZE)
        var nextLongName: String? = null
        var nextLongLink: String? = null
        var totalBytesRead: Long = 0

        targetDir.mkdirs()

        while (true) {
            val bytesRead = readFully(gzipStream, buffer, BLOCK_SIZE)
            if (bytesRead < BLOCK_SIZE) break
            totalBytesRead += BLOCK_SIZE
            onProgress?.invoke(totalBytesRead, totalBytesEstimated)

            // Tar archive ends with two consecutive zero blocks
            if (isAllZeros(buffer)) {
                // Check next block
                val nextBuffer = ByteArray(BLOCK_SIZE)
                readFully(gzipStream, nextBuffer, BLOCK_SIZE)
                break
            }

            // Parse header
            val rawName = parseString(buffer, 0, 100)
            val mode = parseOctal(buffer, 100, 8).toInt().let { if (it == 0) 0b111101101 else it } // default 0755
            val size = parseOctal(buffer, 124, 12)
            val typeFlag = buffer[156].toInt().toChar()
            val rawLink = parseString(buffer, 157, 100)
            val prefix = parseString(buffer, 345, 155)

            var entryName = nextLongName ?: if (prefix.isNotEmpty()) "$prefix/$rawName" else rawName
            val entryLink = nextLongLink ?: rawLink
            nextLongName = null
            nextLongLink = null

            // GNU extension for long pathname
            if (typeFlag == 'L') {
                nextLongName = readLongData(gzipStream, size)
                totalBytesRead += roundUpToBlock(size)
                continue
            }
            // GNU extension for long linkname
            if (typeFlag == 'K') {
                nextLongLink = readLongData(gzipStream, size)
                totalBytesRead += roundUpToBlock(size)
                continue
            }

            // Clean path
            entryName = entryName.trimStart('/', '.')
            if (entryName.isEmpty()) continue

            val destFile = File(targetDir, entryName)

            when (typeFlag) {
                '5' -> {
                    // Directory
                    destFile.mkdirs()
                    try {
                        Os.chmod(destFile.absolutePath, mode)
                    } catch (e: Exception) {
                        Log.w(TAG, "Failed to chmod directory $entryName: ${e.message}")
                    }
                }
                '2' -> {
                    // Symbolic link
                    destFile.parentFile?.mkdirs()
                    if (destFile.exists() || destFile.isSymbolicLink()) {
                        destFile.delete()
                    }
                    try {
                        Os.symlink(entryLink, destFile.absolutePath)
                    } catch (e: Exception) {
                        Log.w(TAG, "Failed to create symlink $entryName -> $entryLink: ${e.message}")
                    }
                }
                '0', '\u0000' -> {
                    // Regular file
                    destFile.parentFile?.mkdirs()
                    if (destFile.exists()) {
                        destFile.delete()
                    }
                    FileOutputStream(destFile).use { output ->
                        var remaining = size
                        val fileBuf = ByteArray(8192)
                        while (remaining > 0) {
                            val toRead = minOf(remaining, fileBuf.size.toLong()).toInt()
                            val n = gzipStream.read(fileBuf, 0, toRead)
                            if (n <= 0) break
                            output.write(fileBuf, 0, n)
                            remaining -= n
                            totalBytesRead += n
                            onProgress?.invoke(totalBytesRead, totalBytesEstimated)
                        }
                    }

                    // Skip padding to 512-byte boundary
                    val padding = ((BLOCK_SIZE - (size % BLOCK_SIZE)) % BLOCK_SIZE).toInt()
                    if (padding > 0) {
                        val padBuf = ByteArray(padding)
                        readFully(gzipStream, padBuf, padding)
                        totalBytesRead += padding
                    }

                    try {
                        Os.chmod(destFile.absolutePath, mode)
                    } catch (e: Exception) {
                        Log.w(TAG, "Failed to chmod file $entryName: ${e.message}")
                    }
                }
                else -> {
                    // Skip unknown or unhandled types (char dev, block dev, etc.)
                    val toSkip = roundUpToBlock(size)
                    skipFully(gzipStream, toSkip)
                    totalBytesRead += toSkip
                }
            }
        }
    }

    private fun File.isSymbolicLink(): Boolean {
        return try {
            val canon = if (parent == null) this else File(parentFile?.canonicalFile, name)
            canon.canonicalPath != canon.absolutePath
        } catch (e: Exception) {
            false
        }
    }

    private fun readLongData(stream: InputStream, size: Long): String {
        val data = ByteArray(size.toInt())
        readFully(stream, data, size.toInt())
        val padding = ((BLOCK_SIZE - (size % BLOCK_SIZE)) % BLOCK_SIZE).toInt()
        if (padding > 0) {
            skipFully(stream, padding.toLong())
        }
        var len = data.size
        while (len > 0 && data[len - 1].toInt() == 0) {
            len--
        }
        return String(data, 0, len, StandardCharsets.UTF_8)
    }

    private fun readFully(stream: InputStream, buffer: ByteArray, length: Int): Int {
        var offset = 0
        while (offset < length) {
            val count = stream.read(buffer, offset, length - offset)
            if (count < 0) break
            offset += count
        }
        return offset
    }

    private fun skipFully(stream: InputStream, n: Long) {
        var remaining = n
        val skipBuf = ByteArray(minOf(remaining, 8192L).toInt())
        while (remaining > 0) {
            val toRead = minOf(remaining, skipBuf.size.toLong()).toInt()
            val count = stream.read(skipBuf, 0, toRead)
            if (count <= 0) break
            remaining -= count
        }
    }

    private fun isAllZeros(buffer: ByteArray): Boolean {
        for (b in buffer) {
            if (b.toInt() != 0) return false
        }
        return true
    }

    private fun parseString(buffer: ByteArray, offset: Int, length: Int): String {
        var end = offset
        val max = offset + length
        while (end < max && buffer[end].toInt() != 0) {
            end++
        }
        return String(buffer, offset, end - offset, StandardCharsets.UTF_8).trim()
    }

    private fun parseOctal(buffer: ByteArray, offset: Int, length: Int): Long {
        var result = 0L
        var start = offset
        val end = offset + length
        while (start < end && (buffer[start] == ' '.code.toByte() || buffer[start].toInt() == 0)) {
            start++
        }
        for (i in start until end) {
            val b = buffer[i]
            if (b == ' '.code.toByte() || b.toInt() == 0) break
            if (b < '0'.code.toByte() || b > '7'.code.toByte()) break
            result = (result shl 3) + (b - '0'.code.toByte())
        }
        return result
    }

    private fun roundUpToBlock(size: Long): Long {
        val rem = size % BLOCK_SIZE
        return if (rem == 0L) size else size + (BLOCK_SIZE - rem)
    }
}
