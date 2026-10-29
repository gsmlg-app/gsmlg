package app.gsmlg.android_shell

import java.io.File
import java.io.FileOutputStream
import java.security.MessageDigest

internal data class RootfsUser(
    val name: String,
    val uid: Int,
    val gid: Int,
    val home: String,
    val shell: String
)

internal data class RootfsConfiguration(
    val user: RootfsUser,
    val packages: List<String>,
    val sourcePackages: List<String>,
    val json: String
) {
    val requiredPackages: List<String> get() = (packages + sourcePackages).distinct()
    val fingerprint: String get() = MessageDigest.getInstance("SHA-256")
        .digest(json.toByteArray(Charsets.UTF_8)).joinToString("") { "%02x".format(it) }
}

/** Additive configuration of an installed rootfs; image extraction is never a migration. */
internal class RootfsMigrator {
    fun migrate(
        rootfs: File,
        configuration: RootfsConfiguration,
        installPackages: (List<String>) -> Unit
    ) {
        validate(configuration)
        val user = configuration.user
        val passwd = File(rootfs, "etc/passwd")
        val group = File(rootfs, "etc/group")
        val passwdLines = readLines(passwd)
        val groupLines = readLines(group)
        validateAccounts(passwdLines, groupLines, user)
        val home = File(rootfs, user.home.removePrefix("/"))
        require(home.canonicalPath.startsWith(rootfs.canonicalPath + File.separator)) {
            "Configured home escapes the rootfs: ${user.home}"
        }

        val missing = configuration.requiredPackages.filterNot { it in installedPackages(rootfs) }
        if (missing.isNotEmpty()) {
            installPackages(missing)
            val remaining = missing.filterNot { it in installedPackages(rootfs) }
            check(remaining.isEmpty()) { "Required packages were not installed: ${remaining.joinToString()}" }
        }
        check(File(rootfs, user.shell.removePrefix("/")).exists()) {
            "Configured login shell is missing: ${user.shell}"
        }

        // apk scripts may add accounts; check again before changing any account record.
        val updatedPasswd = readLines(passwd)
        val updatedGroup = readLines(group)
        validateAccounts(updatedPasswd, updatedGroup, user)
        val existing = updatedPasswd.firstOrNull { it.substringBefore(':') == user.name }
        val record = existing?.split(':')?.toMutableList()
            ?: mutableListOf(user.name, "x", user.uid.toString(), user.gid.toString(), user.name, user.home, user.shell)
        record[5] = user.home
        record[6] = user.shell
        writeIfChanged(passwd, replaceAccount(updatedPasswd, user.name, record.joinToString(":")))
        if (updatedGroup.none { it.substringBefore(':') == user.name }) {
            writeIfChanged(group, appendLine(if (group.exists()) group.readText() else "", "${user.name}:x:${user.gid}:"))
        }
        val shadow = File(rootfs, "etc/shadow")
        if (readLines(shadow).none { it.substringBefore(':') == user.name }) {
            writeIfChanged(shadow, appendLine(if (shadow.exists()) shadow.readText() else "", "${user.name}:!:0:0:99999:7:::"), privateFile = true)
        }
        val shells = File(rootfs, "etc/shells")
        if (readLines(shells).none { it == user.shell }) {
            writeIfChanged(shells, appendLine(if (shells.exists()) shells.readText() else "", user.shell))
        }
        check(home.isDirectory || home.mkdirs()) { "Cannot create home: ${user.home}" }
        val zshrc = File(home, ".zshrc")
        if (home.list()?.contains(".zshrc") != true) {
            writeIfChanged(zshrc, "# Web Terminal defaults; customize this file freely.\nPROMPT='%n@%m:%~%# '\n")
        }
        writeIfChanged(File(rootfs, "etc/web-terminal/rootfs-config.json"), configuration.json)
        writeIfChanged(File(rootfs, ".web_terminal_config_sha256"), configuration.fingerprint + "\n")
    }

    internal fun installedPackages(rootfs: File): Set<String> = readLines(File(rootfs, "lib/apk/db/installed"))
        .filter { it.startsWith("P:") }.map { it.removePrefix("P:") }.toSet()

    private fun validate(configuration: RootfsConfiguration) {
        val user = configuration.user
        require(user.name.matches(Regex("[a-z_][a-z0-9_-]*")) && user.name != "root") { "Invalid default username" }
        require(user.uid > 0 && user.gid > 0) { "Default user UID and GID must be positive" }
        for (path in listOf(user.home, user.shell)) {
            require(path.startsWith("/") && path != "/" && path.split('/').none { it == "." || it == ".." } && path.none { it == ':' || it == '\n' || it == '\r' }) {
                "Invalid configured guest path: $path"
            }
        }
        require(configuration.requiredPackages.all { it.matches(Regex("[A-Za-z0-9][A-Za-z0-9+_.-]*")) }) { "Invalid package name" }
    }

    private fun validateAccounts(passwd: List<String>, group: List<String>, user: RootfsUser) {
        for (line in passwd.filter { it.isNotBlank() && !it.startsWith('#') }) {
            val fields = line.split(':')
            require(fields.size >= 7) { "Malformed passwd record" }
            if (fields[0] == user.name) {
                require(fields[2].toIntOrNull() == user.uid && fields[3].toIntOrNull() == user.gid) { "Existing ${user.name} has a different UID/GID" }
            } else {
                require(fields[2].toIntOrNull() != user.uid) { "UID ${user.uid} is already used by ${fields[0]}" }
            }
        }
        for (line in group.filter { it.isNotBlank() && !it.startsWith('#') }) {
            val fields = line.split(':')
            require(fields.size >= 4) { "Malformed group record" }
            if (fields[0] == user.name) {
                require(fields[2].toIntOrNull() == user.gid) { "Existing ${user.name} group has a different GID" }
            } else {
                require(fields[2].toIntOrNull() != user.gid) { "GID ${user.gid} is already used by ${fields[0]}" }
            }
        }
    }

    private fun readLines(file: File): List<String> = if (file.exists()) file.readLines() else emptyList()

    private fun replaceAccount(lines: List<String>, name: String, record: String): String {
        val result = lines.map { if (it.substringBefore(':') == name) record else it }.toMutableList()
        if (lines.none { it.substringBefore(':') == name }) result.add(record)
        return result.joinToString("\n", postfix = "\n")
    }

    private fun appendLine(text: String, line: String): String = text + (if (text.isEmpty() || text.endsWith('\n')) "" else "\n") + line + "\n"

    private fun writeIfChanged(file: File, content: String, privateFile: Boolean = false) {
        if (file.exists() && file.readText() == content) return
        file.parentFile?.mkdirs()
        val temporary = File(file.parentFile, ".${file.name}.web-terminal.tmp")
        FileOutputStream(temporary).use { stream ->
            stream.write(content.toByteArray(Charsets.UTF_8))
            stream.fd.sync()
        }
        temporary.setReadable(!privateFile, false)
        temporary.setWritable(false, false)
        temporary.setReadable(true, true)
        temporary.setWritable(true, true)
        check(temporary.renameTo(file)) { "Cannot update ${file.name}" }
    }
}
