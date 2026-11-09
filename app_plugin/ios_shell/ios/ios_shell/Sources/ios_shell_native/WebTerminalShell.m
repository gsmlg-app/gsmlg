#import "WebTerminalShell.h"
#import "WebTerminalPython.h"
#import <ios_system/ios_system.h>
#import <dlfcn.h>

static char shellSession[] = "webterminal-local-shell";

extern int ios_setenv_pid(const char *variableName, const char *value, int overwrite, int pid);
extern int ios_unsetenv_pid(const char *variableName, int pid);

static void selectSession(void) {
    NSString *directory = NSFileManager.defaultManager.currentDirectoryPath;
    ios_switchSession(shellSession);
    ios_setContext(shellSession);
    ios_setDirectoryURL([NSURL fileURLWithPath:directory isDirectory:YES]);
}

static void setStreams(FILE *input, FILE *output, FILE *error) {
    ios_setStreams(input, output, error);
    ios_settty(input);
    thread_stdin = input;
    thread_stdout = output;
    thread_stderr = error;
    thread_context = shellSession;
}

static NSData *readOutput(FILE *stream) {
    rewind(stream);
    NSMutableData *data = [NSMutableData data];
    unsigned char buffer[8192];
    size_t length;
    while ((length = fread(buffer, 1, sizeof(buffer), stream)) > 0) {
        [data appendBytes:buffer length:length];
    }
    return data;
}

// ios_system keeps one environment per pid slot; apply and restore both target
// the slot that is current before the command starts.
static NSDictionary<NSString *, id> *applyEnvironment(NSDictionary<NSString *, NSString *> *environment, pid_t pid) {
    NSMutableDictionary<NSString *, id> *previous = [NSMutableDictionary dictionary];
    [environment enumerateKeysAndObjectsUsingBlock:^(NSString *name, NSString *value, BOOL *stop) {
        const char *current = ios_getenv(name.UTF8String);
        previous[name] = current ? [NSString stringWithUTF8String:current] : NSNull.null;
        ios_setenv_pid(name.UTF8String, value.UTF8String, 1, pid);
    }];
    return previous;
}

static void restoreEnvironment(NSDictionary<NSString *, id> *previous, pid_t pid) {
    [previous enumerateKeysAndObjectsUsingBlock:^(NSString *name, id value, BOOL *stop) {
        if (value == NSNull.null) {
            ios_unsetenv_pid(name.UTF8String, pid);
        } else {
            ios_setenv_pid(name.UTF8String, [value UTF8String], 1, pid);
        }
    }];
}

NSDictionary<NSString *, id> *webterminal_execute_command(NSString *command, NSDictionary<NSString *, NSString *> *environment) {
    FILE *input = tmpfile();
    FILE *output = tmpfile();
    FILE *error = tmpfile();
    if (!input || !output || !error) {
        if (input) fclose(input);
        if (output) fclose(output);
        if (error) fclose(error);
        return @{@"exitCode": @1, @"stdout": [NSData data], @"stderr": [@"Unable to capture command output.\n" dataUsingEncoding:NSUTF8StringEncoding]};
    }

    selectSession();
    pid_t environmentPid = ios_currentPid();
    NSDictionary<NSString *, id> *previousEnvironment = applyEnvironment(environment, environmentPid);
    setStreams(input, output, error);
    int status = ios_system(command.UTF8String);
    webterminal_python_cleanup_inputs();
    restoreEnvironment(previousEnvironment, environmentPid);
    fflush(output);
    fflush(error);
    NSData *stdoutText = readOutput(output);
    NSData *stderrText = readOutput(error);
    setStreams(stdin, stdout, stderr);
    fclose(input);
    fclose(output);
    fclose(error);
    return @{@"exitCode": @(status), @"stdout": stdoutText, @"stderr": stderrText};
}

BOOL webterminal_set_directory(NSString *path) {
    selectSession();
    BOOL success = [NSFileManager.defaultManager changeCurrentDirectoryPath:path];
    if (success) {
        ios_setDirectoryURL([NSURL fileURLWithPath:NSFileManager.defaultManager.currentDirectoryPath isDirectory:YES]);
    }
    return success;
}

int webterminal_lg2_main(int argc, char **argv) {
    static void *library;
    static int (*entrypoint)(int, char **);
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        NSString *path = [NSBundle.mainBundle.privateFrameworksPath stringByAppendingPathComponent:@"lg2.framework/lg2"];
        library = dlopen(path.UTF8String, RTLD_NOW | RTLD_GLOBAL);
        if (library) entrypoint = dlsym(library, "main");
    });
    if (!entrypoint) {
        fprintf(thread_stderr, "lg2: runtime is unavailable\n");
        return 127;
    }
    return entrypoint(argc, argv);
}
