import Flutter
import UIKit
import ios_system
import files
import shell
import text
import tar
import awk

// Direct function references to command main functions from external frameworks
@_silgen_name("ls_main") func ls_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("pwd_main") func pwd_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("cat_main") func cat_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("echo_main") func echo_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("mkdir_main") func mkdir_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("touch_main") func touch_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("rm_main") func rm_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("rmdir_main") func rmdir_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("cp_main") func cp_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("mv_main") func mv_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("ln_main") func ln_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("chmod_main") func chmod_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("head_main") func head_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("tail_main") func tail_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("grep_main") func grep_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("wc_main") func wc_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("sort_main") func sort_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("uniq_main") func uniq_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("tr_main") func tr_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("diff_main") func diff_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("sed_main") func sed_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("date_main") func date_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("env_main") func env_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("printenv_main") func printenv_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("uname_main") func uname_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("basename_main") func basename_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("dirname_main") func dirname_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("realpath_main") func realpath_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("find_main") func find_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("xargs_main") func xargs_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("tar_main") func tar_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("awk_main") func awk_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("df_main") func df_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("du_main") func du_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("gzip_main") func gzip_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("less_main") func less_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("stat_main") func stat_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("id_main") func id_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("sleep_main") func sleep_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("tee_main") func tee_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("base64_main") func base64_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("chksum_main") func chksum_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("compress_main") func compress_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("w_main") func w_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("curl_main") func curl_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("dig_main") func dig_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("host_main") func host_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("nslookup_main") func nslookup_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("ping_main") func ping_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("netcat_main") func netcat_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("whois_main") func whois_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("lua_main") func lua_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("luac_main") func luac_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32

// Command dispatch function type
typealias CommandMain = (Int32, UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32

public class IosShellPlugin: NSObject, FlutterPlugin {
    private let commandQueue = DispatchQueue(label: "app.gsmlg.ios_shell.commands")
    private var isInitialized = false
    private var documentsPath: String = ""
    private var tmpPath: String = ""

    // Map of command names to their main functions
    private static let commandMap: [String: CommandMain] = [
        // files framework
        "ls": ls_main,
        "cp": cp_main,
        "mv": mv_main,
        "rm": rm_main,
        "mkdir": mkdir_main,
        "rmdir": rmdir_main,
        "touch": touch_main,
        "chmod": chmod_main,
        "ln": ln_main,
        "df": df_main,
        "du": du_main,
        "gzip": gzip_main,
        "gunzip": gzip_main,
        "less": less_main,
        "stat": stat_main,
        "base64": base64_main,
        "cksum": chksum_main,
        "sum": chksum_main,
        "compress": compress_main,
        "uncompress": compress_main,
        "link": ln_main,
        "readlink": stat_main,
        "unlink": rm_main,
        // shell framework
        "pwd": pwd_main,
        "echo": echo_main,
        "env": env_main,
        "printenv": printenv_main,
        "date": date_main,
        "uname": uname_main,
        "id": id_main,
        "basename": basename_main,
        "dirname": dirname_main,
        "realpath": realpath_main,
        "find": find_main,
        "xargs": xargs_main,
        "sleep": sleep_main,
        "tee": tee_main,
        "uptime": w_main,
        "whoami": id_main,
        // text framework
        "cat": cat_main,
        "head": head_main,
        "tail": tail_main,
        "grep": grep_main,
        "wc": wc_main,
        "sort": sort_main,
        "uniq": uniq_main,
        "tr": tr_main,
        "diff": diff_main,
        "sed": sed_main,
        "md5": webterminal_md5_main,
        "egrep": grep_main,
        "fgrep": grep_main,
        // tar framework
        "tar": tar_main,
        // awk framework
        "awk": awk_main,
        "curl": curl_main,
        "dig": dig_main,
        "host": host_main,
        "nslookup": nslookup_main,
        "ping": ping_main,
        "nc": netcat_main,
        "whois": whois_main,
        "lua": lua_main,
        "luac": luac_main,
        "lg2": webterminal_lg2_main,
        "python": webterminal_python_main,
        "python3": webterminal_python_main,
    ]

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "app.gsmlg/ios_shell",
            binaryMessenger: registrar.messenger()
        )
        let instance = IosShellPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        commandQueue.async {
            self.handleCall(call) { value in
                DispatchQueue.main.async { result(value) }
            }
        }
    }

    private func handleCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            initialize(result: result)
        case "execute":
            if let args = call.arguments as? [String: Any],
               let command = args["command"] as? String {
                execute(command: command, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing command", details: nil))
            }
        case "listCommands":
            listCommands(result: result)
        case "isCommandAvailable":
            if let args = call.arguments as? [String: Any],
               let command = args["command"] as? String {
                isCommandAvailable(command: command, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing command", details: nil))
            }
        case "isInitialized":
            result(isInitialized)
        case "setCurrentDirectory":
            if let args = call.arguments as? [String: Any],
               let path = args["path"] as? String {
                setCurrentDirectory(path: path, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing path", details: nil))
            }
        case "getCurrentDirectory":
            getCurrentDirectory(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func initialize(result: @escaping FlutterResult) {
        let fileManager = FileManager.default

        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            documentsPath = documentsURL.path
        }

        tmpPath = NSTemporaryDirectory()

        // Load framework symbols into global namespace so ios_system can find them
        let frameworkNames = ["files", "shell", "text", "tar", "awk", "openssl", "libssh2", "curl_ios", "network_ios", "lua_ios", "lg2", "Python"]
        for name in frameworkNames {
            if let frameworkBundle = Bundle(identifier: "Nicolas-Holzschuch.\(name)") ??
                                     Bundle(path: Bundle.main.privateFrameworksPath! + "/\(name).framework") {
                let path = frameworkBundle.executablePath!
                let handle = dlopen(path, RTLD_NOW | RTLD_GLOBAL)
                if handle == nil {
                    NSLog("[IosShell] Failed to load \(name): \(String(cString: dlerror()))")
                } else {
                    NSLog("[IosShell] Loaded \(name) framework globally")
                }
            }
        }

        // Enable sideLoading so ios_system reads commandDictionary.plist from main bundle
        sideLoading = true

        // Initialize ios_system - reads commandDictionary.plist from main bundle
        initializeEnvironment()
        joinMainThread = true
        numPythonInterpreters = 1

        NSLog("[IosShell] ios_system initialized with command dictionary")

        // Set the mini root to sandbox the shell
        ios_setMiniRoot(documentsPath)

        // Create bin directory for user scripts
        let binPath = (documentsPath as NSString).appendingPathComponent("bin")
        try? fileManager.createDirectory(atPath: binPath, withIntermediateDirectories: true)

        // Set up environment variables
        setenv("HOME", documentsPath, 1)
        setenv("PATH", binPath, 1)
        setenv("TMPDIR", tmpPath, 1)
        setenv("TERM", "xterm-256color", 1)
        setenv("LANG", "en_US.UTF-8", 1)
        setenv("CLICOLOR", "1", 1)
        guard let certificates = Bundle(for: IosShellPlugin.self).path(forResource: "cacert", ofType: "pem") ??
                                 Bundle.main.path(forResource: "cacert", ofType: "pem") else {
            result(FlutterError(code: "MISSING_CA_BUNDLE", message: "TLS certificate bundle is missing", details: nil))
            return
        }
        setenv("SSL_CERT_FILE", certificates, 1)
        setenv("CURL_CA_BUNDLE", certificates, 1)

        // Change to home directory
        FileManager.default.changeCurrentDirectoryPath(documentsPath)

        isInitialized = true

        NSLog("[IosShell] Initialized with \(IosShellPlugin.commandMap.count) commands available")

        result([
            "documentsPath": documentsPath,
            "homePath": documentsPath,
            "tmpPath": tmpPath,
            "binPath": binPath,
            "initialized": "true"
        ])
    }

    private func execute(command: String, result: @escaping FlutterResult) {
        guard isInitialized else {
            result(FlutterError(code: "NOT_INITIALIZED", message: "Shell not initialized", details: nil))
            return
        }

        // Parse command
        let trimmed = command.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            result(["exitCode": 0, "stdout": "", "stderr": ""])
            return
        }

        result(webterminal_execute_command(trimmed))
    }

    private func listCommands(result: @escaping FlutterResult) {
        // Return commands from our command map plus ios_system built-ins
        var commands = Array(IosShellPlugin.commandMap.keys)
        commands.append(contentsOf: ["cd", "alias", "unalias", "true", "type", "export", "setenv", "unsetenv"])
        result(commands.sorted())
    }

    private func isCommandAvailable(command: String, result: @escaping FlutterResult) {
        let available = IosShellPlugin.commandMap[command] != nil ||
                       ["cd", "alias", "unalias", "true", "type", "export", "setenv", "unsetenv"].contains(command)
        result(available)
    }

    private func setCurrentDirectory(path: String, result: @escaping FlutterResult) {
        let success = webterminal_set_directory(path)
        result(success)
    }

    private func getCurrentDirectory(result: @escaping FlutterResult) {
        let cwd = FileManager.default.currentDirectoryPath
        result(cwd)
    }
}
