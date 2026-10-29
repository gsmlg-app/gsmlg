package app.gsmlg.android_shell

import java.io.File
import java.nio.file.Files
import org.junit.After
import org.junit.Assert.assertArrayEquals
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertThrows
import org.junit.Assert.assertTrue
import org.junit.Assert.fail
import org.junit.Before
import org.junit.Test

class RootfsMigratorTest {
    private lateinit var rootfs: File
    private val migrator = RootfsMigrator()
    private val config = RootfsConfiguration(
        RootfsUser("gao", 1000, 1000, "/home/gao", "/bin/zsh"),
        listOf("bash", "zsh"), listOf("lrzsz"), "{\"schemaVersion\":1}"
    )

    @Before fun setUp() {
        rootfs = Files.createTempDirectory("rootfs-migration-").toFile()
        put("etc/passwd", "root:x:0:0:root:/root:/bin/sh\n")
        put("etc/group", "root:x:0:root\n")
        put("etc/shadow", "root:fixture:20000:0:99999:7:::\n")
        put("etc/apk/world", "bash\nzsh\nlrzsz\ncustom-user-package\n")
        put("lib/apk/db/installed", "P:bash\nV:1\n\nP:zsh\nV:1\n\nP:lrzsz\nV:1\n\nP:custom-user-package\nV:1\n")
        put("bin/zsh", "fixture-shell")
        put(".rootfs_version", "2.0.0")
        put("root/.profile", "user-customized-profile\n")
        put("root/.dotfiles/oh-my-zsh/zshrc", "user-customized-zshrc\n")
        Files.createSymbolicLink(File(rootfs, "root/.zshrc").toPath(), File("/root/.dotfiles/oh-my-zsh/zshrc").toPath())
    }

    @After fun tearDown() { rootfs.deleteRecursively() }

    @Test fun preservesInstalledPackagesRootHomeAndImageMarker() {
        val before = snapshot()
        migrator.migrate(rootfs, config) { fail("Packages already installed: $it") }
        for ((path, bytes) in before) {
            if (path != "etc/passwd" && path != "etc/group" && path != "etc/shadow") {
                assertArrayEquals(path, bytes, File(rootfs, path).readBytes())
            }
        }
        assertTrue(File(rootfs, "etc/passwd").readText().contains("root:x:0:0:root:/root:/bin/sh\ngao:x:1000:1000:gao:/home/gao:/bin/zsh\n"))
        assertEquals("/root/.dotfiles/oh-my-zsh/zshrc", Files.readSymbolicLink(File(rootfs, "root/.zshrc").toPath()).toString())
        assertTrue(File(rootfs, "home/gao/.zshrc").isFile)
    }

    @Test fun repeatedMigrationDoesNotRewriteFilesOrDuplicateAccounts() {
        migrator.migrate(rootfs, config) { fail("Unexpected install") }
        val before = snapshot()
        val files = rootfs.walkTopDown().filter { it.isFile }.toList()
        files.forEach { assertTrue(it.setLastModified(1_000_000L)) }
        migrator.migrate(rootfs, config) { fail("Unexpected reinstall") }
        assertEquals(before.keys, snapshot().keys)
        for ((path, bytes) in before) assertArrayEquals(path, bytes, File(rootfs, path).readBytes())
        files.forEach { assertEquals(it.path, 1_000_000L, it.lastModified()) }
        assertEquals(1, File(rootfs, "etc/passwd").readLines().count { it.startsWith("gao:") })
    }

    @Test fun installsOnlyMissingPackagesThroughInstaller() {
        put("lib/apk/db/installed", "P:bash\nV:custom\n\nP:custom-user-package\nV:1\n")
        var calls = 0
        migrator.migrate(rootfs, config) { missing ->
            calls++
            assertEquals(listOf("zsh", "lrzsz"), missing)
            assertFalse(File(rootfs, "etc/passwd").readText().contains("gao:"))
            File(rootfs, "lib/apk/db/installed").appendText("\nP:zsh\n\nP:lrzsz\n")
        }
        assertEquals(1, calls)
        assertTrue(File(rootfs, "lib/apk/db/installed").readText().contains("P:custom-user-package"))
        assertTrue(File(rootfs, "lib/apk/db/installed").readText().contains("V:custom"))
    }

    @Test fun packageFailureDoesNotChangeAccountsOrImageMarker() {
        put("lib/apk/db/installed", "P:bash\n")
        val before = snapshot()
        assertThrows(IllegalStateException::class.java) {
            migrator.migrate(rootfs, config) { error("offline package failure") }
        }
        for ((path, bytes) in before) assertArrayEquals(path, bytes, File(rootfs, path).readBytes())
        assertFalse(File(rootfs, ".web_terminal_config_sha256").exists())
        assertFalse(File(rootfs, "home/gao").exists())
    }

    @Test fun installerMustActuallyInstallRequiredPackages() {
        put("lib/apk/db/installed", "P:bash\n")
        assertThrows(IllegalStateException::class.java) { migrator.migrate(rootfs, config) {} }
        assertFalse(File(rootfs, "etc/passwd").readText().contains("gao:"))
    }

    @Test fun conflictingUidFailsBeforePackagesOrFilesChange() {
        File(rootfs, "etc/passwd").appendText("another:x:1000:1000:Another:/home/another:/bin/sh\n")
        assertConflict("UID 1000")
    }

    @Test fun conflictingGidFailsBeforePackagesOrFilesChange() {
        File(rootfs, "etc/group").appendText("another:x:1000:\n")
        assertConflict("GID 1000")
    }

    @Test fun existingUsernameWithDifferentIdsFailsClearly() {
        File(rootfs, "etc/passwd").appendText("gao:x:1001:1001:Gao:/home/gao:/bin/sh\n")
        assertConflict("different UID/GID")
    }

    @Test fun existingCompatibleAccountAndRcArePreserved() {
        File(rootfs, "etc/passwd").appendText("gao:custom:1000:1000:Custom Name:/home/gao:/bin/sh\n")
        File(rootfs, "etc/group").appendText("gao:x:1000:extra-member\n")
        File(rootfs, "etc/shadow").appendText("gao:existing-password:20000:0:99999:7:::\n")
        put("home/gao/.zshrc", "custom-user-zshrc\n")
        migrator.migrate(rootfs, config) { fail("Unexpected install") }
        assertTrue(File(rootfs, "etc/passwd").readText().contains("gao:custom:1000:1000:Custom Name:/home/gao:/bin/zsh"))
        assertTrue(File(rootfs, "etc/group").readText().contains("gao:x:1000:extra-member"))
        assertTrue(File(rootfs, "etc/shadow").readText().contains("gao:existing-password:"))
        assertEquals("custom-user-zshrc\n", File(rootfs, "home/gao/.zshrc").readText())
    }

    @Test fun brokenUserRcSymlinkIsPreserved() {
        File(rootfs, "home/gao").mkdirs()
        Files.createSymbolicLink(File(rootfs, "home/gao/.zshrc").toPath(), File("/missing/user/zshrc").toPath())
        migrator.migrate(rootfs, config) { fail("Unexpected install") }
        assertEquals("/missing/user/zshrc", Files.readSymbolicLink(File(rootfs, "home/gao/.zshrc").toPath()).toString())
    }

    @Test fun packageScriptsCannotIntroduceAnAccountConflict() {
        put("lib/apk/db/installed", "P:bash\n")
        assertThrows(IllegalArgumentException::class.java) {
            migrator.migrate(rootfs, config) {
                File(rootfs, "lib/apk/db/installed").appendText("P:zsh\nP:lrzsz\n")
                File(rootfs, "etc/passwd").appendText("package-user:x:1000:1000::/var/empty:/bin/false\n")
            }
        }
        assertFalse(File(rootfs, "etc/passwd").readText().contains("gao:"))
    }

    private fun assertConflict(message: String) {
        val before = snapshot()
        val error = assertThrows(IllegalArgumentException::class.java) {
            migrator.migrate(rootfs, config) { fail("Conflict must be checked before installation") }
        }
        assertTrue(error.message, error.message!!.contains(message))
        for ((path, bytes) in before) assertArrayEquals(path, bytes, File(rootfs, path).readBytes())
    }

    private fun snapshot(): Map<String, ByteArray> = rootfs.walkTopDown()
        .filter { it.isFile }.associate { it.relativeTo(rootfs).path to it.readBytes() }

    private fun put(path: String, text: String) {
        File(rootfs, path).apply { parentFile?.mkdirs(); writeText(text) }
    }
}
