#import "WebTerminalShell.h"
#import "WebTerminalPython.h"
#import <ios_system/ios_system.h>
#import <dlfcn.h>

static char shellSession[] = "webterminal-local-shell";

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

static NSString *readOutput(FILE *stream) {
    rewind(stream);
    NSMutableData *data = [NSMutableData data];
    unsigned char buffer[8192];
    size_t length;
    while ((length = fread(buffer, 1, sizeof(buffer), stream)) > 0) {
        [data appendBytes:buffer length:length];
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ?: @"";
}

NSDictionary<NSString *, id> *webterminal_execute_command(NSString *command) {
    FILE *input = tmpfile();
    FILE *output = tmpfile();
    FILE *error = tmpfile();
    if (!input || !output || !error) {
        if (input) fclose(input);
        if (output) fclose(output);
        if (error) fclose(error);
        return @{@"exitCode": @1, @"stdout": @"", @"stderr": @"Unable to capture command output.\n"};
    }

    selectSession();
    setStreams(input, output, error);
    int status = ios_system(command.UTF8String);
    webterminal_python_cleanup_inputs();
    fflush(output);
    fflush(error);
    NSString *stdoutText = readOutput(output);
    NSString *stderrText = readOutput(error);
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
