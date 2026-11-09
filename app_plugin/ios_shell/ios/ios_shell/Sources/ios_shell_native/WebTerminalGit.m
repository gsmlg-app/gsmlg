#import "WebTerminalShell.h"
#import "WebTerminalPython.h"
#import <ios_system/ios_system.h>

static const char *lfsEnvironmentNames[] = {"HOME", "GIT_LFS_TOKEN", "GITHUB_TOKEN", "GH_TOKEN", "GIT_LFS_SKIP_SMUDGE"};
static const char *checkoutCommands[] = {"checkout", "pull", "merge", "rebase", "reset", "stash"};

// Python's os.environ is a stale snapshot inside ios_system, so the values the
// LFS helper needs are forwarded explicitly as --env=NAME=VALUE arguments.
static int runLfs(const char *subcommand, int argc, char **argv) {
    @autoreleasepool {
        NSString *script = [NSBundle.mainBundle.resourcePath stringByAppendingPathComponent:@"git_lfs/main.py"];
        if (![NSFileManager.defaultManager fileExistsAtPath:script]) {
            fprintf(thread_stderr, "git-lfs: runtime is unavailable\n");
            return 127;
        }
        NSMutableArray<NSString *> *arguments = [NSMutableArray arrayWithObjects:@"python3", script, nil];
        for (size_t index = 0; index < sizeof(lfsEnvironmentNames) / sizeof(*lfsEnvironmentNames); index++) {
            const char *value = ios_getenv(lfsEnvironmentNames[index]);
            if (value) [arguments addObject:[NSString stringWithFormat:@"--env=%s=%s", lfsEnvironmentNames[index], value]];
        }
        if (subcommand) [arguments addObject:@(subcommand)];
        for (int index = 0; index < argc; index++) {
            [arguments addObject:@(argv[index])];
        }

        int count = (int)arguments.count;
        char **pythonArguments = calloc(count + 1, sizeof(char *));
        if (!pythonArguments) {
            fprintf(thread_stderr, "git-lfs: out of memory\n");
            return 1;
        }
        for (int index = 0; index < count; index++) {
            pythonArguments[index] = strdup(arguments[index].UTF8String);
        }
        int status = webterminal_python_main(count, pythonArguments);
        for (int index = 0; index < count; index++) {
            free(pythonArguments[index]);
        }
        free(pythonArguments);
        return status;
    }
}

static BOOL isCheckoutCommand(const char *command) {
    for (size_t index = 0; index < sizeof(checkoutCommands) / sizeof(*checkoutCommands); index++) {
        if (strcmp(command, checkoutCommands[index]) == 0) return YES;
    }
    return NO;
}

int webterminal_git_main(int argc, char **argv) {
    if (argc < 2) return webterminal_lg2_main(argc, argv);
    const char *command = argv[1];
    if (strcmp(command, "lfs") == 0) {
        return runLfs(NULL, argc - 2, argv + 2);
    }
    if (strcmp(command, "push") == 0) {
        int status = runLfs("pre-push", argc - 2, argv + 2);
        if (status != 0) return status;
        return webterminal_lg2_main(argc, argv);
    }
    if (strcmp(command, "clone") == 0) {
        int status = webterminal_lg2_main(argc, argv);
        if (status != 0) return status;
        return runLfs("post-clone", argc - 2, argv + 2);
    }
    if (isCheckoutCommand(command)) {
        int status = webterminal_lg2_main(argc, argv);
        if (status == 0) runLfs("post-checkout", 0, NULL);
        return status;
    }
    return webterminal_lg2_main(argc, argv);
}
