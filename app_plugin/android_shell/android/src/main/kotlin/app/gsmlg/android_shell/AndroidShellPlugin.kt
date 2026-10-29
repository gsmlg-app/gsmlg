package app.gsmlg.android_shell

import android.content.Context
import android.content.pm.ApplicationInfo
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.system.Os
import android.system.OsConstants
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.util.concurrent.Executors
import org.json.JSONObject

class AndroidShellPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private val executor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    companion object {
        private const val TAG = "AndroidShellPlugin"
        private const val VERSION = "2.0.0"  // PRoot + Alpine Linux Rootfs
        private const val CHANNEL_NAME = "app.gsmlg/android_shell"
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initialize" -> initialize(result)
            "getArchitecture" -> result.success(getArchitecture())
            "isInitialized" -> result.success(isInitialized())
            "getVersion" -> result.success(getInstalledVersion())
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun getNativeLibDir(): String {
        val appInfo: ApplicationInfo = context.applicationInfo
        return appInfo.nativeLibraryDir
    }

    private fun getArchitecture(): String {
        val supportedAbis = Build.SUPPORTED_ABIS
        return when {
            supportedAbis.contains("arm64-v8a") -> "arm64-v8a"
            supportedAbis.contains("x86_64") -> "x86_64"
            supportedAbis.contains("armeabi-v7a") -> "armeabi-v7a"
            supportedAbis.contains("x86") -> "x86"
            else -> "arm64-v8a"
        }
    }

    private fun isInitialized(): Boolean {
        val versionFile = File(context.filesDir, "rootfs/.rootfs_version")
        val prootBin = File(getNativeLibDir(), "libproot.so")
        return versionFile.exists() && versionFile.readText().trim() == VERSION && prootBin.exists()
    }

    private fun getInstalledVersion(): String? {
        val versionFile = File(context.filesDir, "rootfs/.rootfs_version")
        return if (versionFile.exists()) versionFile.readText().trim() else null
    }

    private fun initialize(result: Result) {
        executor.execute {
            try {
                val legacyFiles = File("/data/data/${context.packageName}/files")
                val filesDir = if (legacyFiles.canonicalFile == context.filesDir.canonicalFile) {
                    legacyFiles.absolutePath
                } else {
                    context.filesDir.absolutePath
                }
                val arch = getArchitecture()
                val rootfsDir = File(filesDir, "rootfs")
                val tmpDir = File(filesDir, "tmp")
                val nativeLibDir = getNativeLibDir()
                val prootBin = File(nativeLibDir, "libproot.so")

                Log.d(TAG, "Initializing PRoot + Alpine Linux shell environment")
                Log.d(TAG, "filesDir: $filesDir")
                Log.d(TAG, "nativeLibDir: $nativeLibDir")
                Log.d(TAG, "arch: $arch")

                val configuration = readConfiguration()
                val versionFile = File(rootfsDir, ".rootfs_version")
                tmpDir.mkdirs()
                if (!versionFile.exists()) {
                    check(rootfsDir.list()?.isNotEmpty() != true) {
                        "Existing rootfs has no image marker; refusing to overwrite user data"
                    }
                    val fresh = File(filesDir, "rootfs-install-staging")
                    removeStaging(fresh)
                    try {
                        context.assets.open("shell/$arch/rootfs.tgz").use { assetStream ->
                            TarExtractor.extractGzipTar(assetStream, fresh)
                        }
                        verifyBundledConfiguration(fresh, configuration)
                        configureRootfs(fresh)
                        File(fresh, ".rootfs_version").writeText(VERSION)
                        check(!rootfsDir.exists() || rootfsDir.delete()) { "Cannot replace empty rootfs directory" }
                        check(fresh.renameTo(rootfsDir)) { "Cannot activate prepared rootfs" }
                    } finally {
                        removeStaging(fresh)
                    }
                }
                check(versionFile.readText().trim() == VERSION) {
                    "Unsupported installed rootfs version; refusing to overwrite user data"
                }
                RootfsMigrator().migrate(rootfsDir, configuration) { missingPackages ->
                    installOfflinePackages(rootfsDir, tmpDir, nativeLibDir, prootBin, arch, missingPackages, configuration)
                }

                mainHandler.post {
                    result.success(buildResultMap(filesDir, rootfsDir, nativeLibDir, prootBin, tmpDir, arch, configuration.user))
                }
            } catch (e: Exception) {
                Log.e(TAG, "Failed to initialize shell environment", e)
                mainHandler.post {
                    result.error("INIT_ERROR", "Failed to initialize rootfs: ${e.message}", null)
                }
            }
        }
    }

    private fun buildResultMap(
        filesDir: String,
        rootfsDir: File,
        nativeLibDir: String,
        prootBin: File,
        tmpDir: File,
        arch: String,
        user: RootfsUser
    ): Map<String, String> {
        return mapOf(
            "filesDir" to filesDir,
            "rootfsPath" to rootfsDir.absolutePath,
            "nativeLibDir" to nativeLibDir,
            "prootPath" to prootBin.absolutePath,
            "loaderPath" to File(nativeLibDir, "libloader.so").absolutePath,
            "loader32Path" to File(nativeLibDir, "libloader32.so").absolutePath,
            "tmpPath" to tmpDir.absolutePath,
            "homePath" to File(rootfsDir, user.home.removePrefix("/")).absolutePath,
            "userName" to user.name,
            "userId" to user.uid.toString(),
            "groupId" to user.gid.toString(),
            "guestHome" to user.home,
            "guestShell" to user.shell,
            "arch" to arch
        )
    }

    private fun readConfiguration(): RootfsConfiguration {
        val json = context.assets.open("shell/rootfs-config.json").bufferedReader().use { it.readText() }
        val config = JSONObject(json)
        require(config.getInt("schemaVersion") == 1) { "Unsupported rootfs configuration schema" }
        val user = config.getJSONObject("user")
        fun packages(key: String): List<String> {
            val array = config.getJSONArray(key)
            return (0 until array.length()).map { array.getString(it) }
        }
        return RootfsConfiguration(
            RootfsUser(user.getString("name"), user.getInt("uid"), user.getInt("gid"), user.getString("home"), user.getString("shell")),
            packages("packages"), packages("sourcePackages"), json
        )
    }

    private fun installOfflinePackages(
        rootfs: File,
        temporary: File,
        nativeLibDir: String,
        proot: File,
        arch: String,
        packages: List<String>,
        configuration: RootfsConfiguration
    ) {
        check(proot.exists()) { "PRoot is required to provision missing packages" }
        val staging = File(rootfs.parentFile, "rootfs-package-staging")
        removeStaging(staging)
        try {
            context.assets.open("shell/$arch/rootfs.tgz").use { TarExtractor.extractGzipTar(it, staging) }
            verifyBundledConfiguration(staging, configuration)
            val repository = File(staging, "opt/web-terminal/apks")
            check(File(repository, "APKINDEX.tar.gz").isFile) { "Bundled offline package index is missing" }
            File(rootfs, "opt/web-terminal/apks").mkdirs()
            val command = listOf(
                proot.absolutePath, "-r", rootfs.absolutePath, "-0", "--link2symlink", "--sysvipc", "--kill-on-exit",
                "-b", "/dev", "-b", "/proc", "-b", "/sys",
                "-b", "${temporary.absolutePath}:/tmp",
                "-b", "${repository.absolutePath}:/opt/web-terminal/apks",
                "-w", "/", "/sbin/apk", "--no-network", "--allow-untrusted",
                "--repositories-file", "/dev/null", "--repository", "/opt/web-terminal/apks", "add"
            ) + packages
            val processBuilder = ProcessBuilder(command).redirectErrorStream(true)
            processBuilder.environment().putAll(mapOf(
                "LD_LIBRARY_PATH" to nativeLibDir,
                "PROOT_LOADER" to File(nativeLibDir, "libloader.so").absolutePath,
                "PROOT_TMP_DIR" to temporary.absolutePath,
                "PROOT_IGNORE_MISSING_BINDINGS" to "1",
                "HOME" to "/root", "USER" to "root", "LOGNAME" to "root",
                "PATH" to "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                "TMPDIR" to "/tmp"
            ))
            val loader32 = File(nativeLibDir, "libloader32.so")
            if (loader32.exists()) processBuilder.environment()["PROOT_LOADER_32"] = loader32.absolutePath
            val process = processBuilder.start()
            try {
                process.outputStream.close()
                val output = process.inputStream.bufferedReader().use { it.readText() }
                check(process.waitFor() == 0) { "Offline package provisioning failed: $output" }
            } finally {
                process.destroy()
                process.waitFor()
            }
        } finally {
            removeStaging(staging)
        }
    }

    private fun verifyBundledConfiguration(rootfs: File, configuration: RootfsConfiguration) {
        val manifest = JSONObject(File(rootfs, "etc/web-terminal/rootfs.json").readText())
        check(manifest.getString("configSha256") == configuration.fingerprint) {
            "Bundled rootfs configuration does not match shell/rootfs-config.json"
        }
    }

    private fun removeStaging(file: File) {
        val mode = try { Os.lstat(file.absolutePath).st_mode } catch (_: Exception) { return }
        if (OsConstants.S_ISDIR(mode)) file.listFiles()?.forEach { removeStaging(it) }
        check(file.delete()) { "Cannot remove package staging path: ${file.name}" }
    }

    private fun configureRootfs(rootfsDir: File) {
        val etcDir = File(rootfsDir, "etc").apply { mkdirs() }
        val rootDir = File(rootfsDir, "root").apply { mkdirs() }

        // 1. DNS resolver
        val resolvFile = File(etcDir, "resolv.conf")
        resolvFile.writeText("nameserver 8.8.8.8\nnameserver 1.1.1.1\n")

        // 2. Hosts
        val hostsFile = File(etcDir, "hosts")
        if (!hostsFile.exists()) {
            hostsFile.writeText("127.0.0.1 localhost\n::1 localhost\n")
        }

        // 3. Setup user profile
        val profileContent = """
            # Default profile for Web Terminal
            export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
            export HOME=/root
            export USER=root
            export TERM=xterm-256color
            export PS1='\[\033[01;32m\]\u@android\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]# '
            alias ll='ls -la'
            alias l='ls -lah'

        """.trimIndent() + "\n"

        val userProfile = File(rootDir, ".profile")
        if (!userProfile.exists()) {
            userProfile.writeText(profileContent)
        }

        // 4. Extract bundled custom profile if present
        try {
            val customProfile = context.assets.open("shell/profile").bufferedReader().use { it.readText() }
            val profileD = File(etcDir, "profile.d").apply { mkdirs() }
            File(profileD, "web_terminal.sh").writeText(customProfile)
        } catch (e: IOException) {
            // Optional custom profile
        }
    }
}
