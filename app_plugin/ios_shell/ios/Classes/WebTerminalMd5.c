#include <errno.h>
#include <err.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../Vendor/md5/ios_error.h"

static void md5Diagnostic(int includeError, const char *format, ...) {
    int error = errno;
    fprintf(thread_stderr, "md5: ");
    if (format) {
        va_list arguments;
        va_start(arguments, format);
        vfprintf(thread_stderr, format, arguments);
        va_end(arguments);
    }
    if (includeError) fprintf(thread_stderr, ": %s", strerror(error));
    fprintf(thread_stderr, "\n");
}

#define printf(...) fprintf(thread_stdout, __VA_ARGS__)
#define warn(...) md5Diagnostic(1, __VA_ARGS__)
#define err(status, ...) do { md5Diagnostic(1, __VA_ARGS__); ios_exit(status); } while (0)
#define errx(status, ...) do { md5Diagnostic(0, __VA_ARGS__); ios_exit(status); } while (0)
#define md5_main webterminal_md5_main
#define md5_qflag webterminal_md5_qflag
#define md5_rflag webterminal_md5_rflag
#define md5_sflag webterminal_md5_sflag
#define Algorithm webterminal_md5_algorithms
#include "../Vendor/md5/md5.c"
