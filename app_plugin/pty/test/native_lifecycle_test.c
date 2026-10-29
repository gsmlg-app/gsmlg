#include <assert.h>
#include <dirent.h>
#include <dlfcn.h>
#include <errno.h>
#include <signal.h>
#include <stdatomic.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/resource.h>
#ifdef __APPLE__
#include <mach/mach.h>
#endif

static int fail_thread;
static int thread_attempts;

static int create_thread(pthread_t *thread, const pthread_attr_t *attributes,
                         void *(*entry)(void *), void *argument) {
    if (++thread_attempts == fail_thread) return EAGAIN;
    return pthread_create(thread, attributes, entry, argument);
}

#define pthread_create create_thread
#include "../src/flutter_pty.c"
#undef pthread_create

static atomic_int exits;
static atomic_int bytes;
static atomic_int last_exit_code;
static pid_t children[64];
static int child_count;

static void cleanup(int signal_number) {
    for (int i = 0; i < child_count; i++) kill(-children[i], SIGKILL);
    _exit(128 + signal_number);
}

static bool post_object(Dart_Port port, Dart_CObject *object) {
    if (object->type == Dart_CObject_kTypedData)
        atomic_fetch_add(&bytes, object->value.as_typed_data.length);
    return true;
}

static bool post_integer(Dart_Port port, int64_t value) {
    atomic_store(&last_exit_code, value);
    atomic_fetch_add(&exits, 1);
    return true;
}

static int count_directory(const char *path) {
    DIR *directory = opendir(path);
    assert(directory != NULL);
    int count = 0;
    struct dirent *entry;
    while ((entry = readdir(directory)) != NULL)
        if (entry->d_name[0] != '.') count++;
    closedir(directory);
    return count;
}

static int threads(void) {
#ifdef __APPLE__
    thread_act_array_t list;
    mach_msg_type_number_t count;
    assert(task_threads(mach_task_self(), &list, &count) == KERN_SUCCESS);
    for (mach_msg_type_number_t i = 0; i < count; i++)
        mach_port_deallocate(mach_task_self(), list[i]);
    vm_deallocate(mach_task_self(), (vm_address_t)list, count * sizeof(thread_t));
    return count;
#else
    return count_directory("/proc/self/task");
#endif
}

static int descriptors(void) {
#ifdef __APPLE__
    return count_directory("/dev/fd");
#else
    return count_directory("/proc/self/fd");
#endif
}

static void assert_resources_released(int before_fds, int before_threads) {
    assert(descriptors() == before_fds);
    for (int i = 0; i < 100 && threads() != before_threads; i++) usleep(1000);
    assert(threads() == before_threads);
}

static PtyHandle *spawn(const char *executable, char **arguments, bool ack,
                        char *directory) {
    PtyOptions options = {0};
    options.rows = 24;
    options.cols = 80;
    options.executable = (char *)executable;
    options.arguments = arguments;
    options.working_directory = directory;
    options.ackRead = ack;
    pid_t parent = getpid();
    PtyHandle *handle = pty_create(&options);
    if (getpid() != parent) _exit(90);
    if (handle != NULL) children[child_count++] = pty_getpid(handle);
    return handle;
}

static void await_exits(int count) {
    for (int i = 0; i < 3000 && atomic_load(&exits) < count; i++) usleep(1000);
    assert(atomic_load(&exits) == count);
}

int main(int argc, char **argv) {
    assert(argc == 2);
    if (strcmp(argv[1], "read-input") == 0) {
        struct termios raw;
        assert(tcgetattr(STDIN_FILENO, &raw) == 0);
        cfmakeraw(&raw);
        assert(tcsetattr(STDIN_FILENO, TCSANOW, &raw) == 0);
        assert(write(STDOUT_FILENO, "ready", 5) == 5);
        usleep(100000);
        int remaining = 256 * 1024;
        char buffer[4096];
        while (remaining > 0) {
            ssize_t length = read(STDIN_FILENO, buffer, sizeof(buffer));
            assert(length > 0);
            for (ssize_t i = 0; i < length; i++) assert(buffer[i] == 'k');
            remaining -= length;
        }
        _exit(0);
    }
    if (strcmp(argv[1], "orphan-writer") == 0 ||
        strcmp(argv[1], "orphan-slow-writer") == 0) {
        bool slow = strcmp(argv[1], "orphan-slow-writer") == 0;
        signal(SIGHUP, SIG_IGN);
        pid_t leader = getpid();
        pid_t writer = fork();
        assert(writer >= 0);
        if (writer == 0) {
            while (getppid() == leader) usleep(1000);
            while (write(STDOUT_FILENO, "x", 1) == 1) {
                if (slow) usleep(20000);
            }
        }
        _exit(0);
    }
    signal(SIGALRM, cleanup);
    signal(SIGABRT, cleanup);
    alarm(10);
    Dart_PostCObject_DL = post_object;
    Dart_PostInteger_DL = post_integer;
    void (*destroy)(PtyHandle *) = dlsym(RTLD_DEFAULT, "pty_destroy");
    int (*terminate)(PtyHandle *, int) = dlsym(RTLD_DEFAULT, "pty_terminate");
    int (*signal_process)(PtyHandle *, int) = dlsym(RTLD_DEFAULT, "pty_kill");
    int before_fds = descriptors();
    int before_threads = threads();

    if (strcmp(argv[1], "natural") == 0 || strcmp(argv[1], "ack") == 0) {
        bool ack = strcmp(argv[1], "ack") == 0;
        for (int i = 0; i < 32; i++) {
            char *args[] = {"sh", "-c", "printf final-output", NULL};
            PtyHandle *handle = spawn("/bin/sh", args, ack, NULL);
            assert(handle != NULL);
            await_exits(i + 1);
            assert(signal_process != NULL && signal_process(handle, SIGCONT) == -1);
            if (destroy != NULL) destroy(handle);
        }
        usleep(20000);
        fprintf(stderr, "fds %d -> %d; threads %d -> %d; bytes %d\n",
                before_fds, descriptors(), before_threads, threads(), atomic_load(&bytes));
        assert_resources_released(before_fds, before_threads);
        assert(atomic_load(&bytes) == 32 * strlen("final-output"));
    } else if (strcmp(argv[1], "group-ownership") == 0) {
        char *args[] = {"sh", "-c", "exec sleep 60", NULL};
        PtyHandle *first = spawn("/bin/sh", args, false, NULL);
        PtyHandle *second = spawn("/bin/sh", args, false, NULL);
        assert(first != NULL && second != NULL);
        pthread_mutex_lock(&first->mutex);
        first->foreground_group = pty_getpid(second);
        first->terminating = true;
        signal_groups(first, SIGKILL);
        pthread_mutex_unlock(&first->mutex);
        await_exits(1);
        destroy(first);
        assert(signal_process(second, 0) == 0);
        terminate(second, SIGKILL);
        await_exits(2);
        destroy(second);
        assert_resources_released(before_fds, before_threads);
    } else if (strcmp(argv[1], "full-write") == 0) {
        char *args[] = {argv[0], "read-input", NULL};
        PtyHandle *handle = spawn(argv[0], args, false, NULL);
        assert(handle != NULL);
        for (int i = 0; i < 3000 && atomic_load(&bytes) < 5; i++) usleep(1000);
        assert(atomic_load(&bytes) == 5);
        char *input = malloc(256 * 1024);
        assert(input != NULL);
        memset(input, 'k', 256 * 1024);
        pty_write(handle, input, 256 * 1024);
        free(input);
        await_exits(1);
        assert(atomic_load(&last_exit_code) == 0);
        destroy(handle);
        assert_resources_released(before_fds, before_threads);
    } else if (strcmp(argv[1], "exec") == 0 || strcmp(argv[1], "cwd") == 0) {
        for (int i = 0; i < 16; i++) {
            bool cwd = strcmp(argv[1], "cwd") == 0;
            char *args[] = {"sh", "-c", "exit 0", NULL};
            PtyHandle *handle = spawn(cwd ? "/bin/sh" : "/missing-pty-shell",
                                      args, false, cwd ? "/missing-pty-directory" : NULL);
            assert(handle == NULL);
            assert(pty_error() != NULL && strlen(pty_error()) > 0);
        }
        assert_resources_released(before_fds, before_threads);
        assert(waitpid(-1, NULL, WNOHANG) == -1 && errno == ECHILD);
    } else if (strcmp(argv[1], "background-output") == 0 ||
               strcmp(argv[1], "slow-background-output") == 0) {
        char *args[] = {argv[0], strcmp(argv[1], "background-output") == 0
            ? "orphan-writer" : "orphan-slow-writer", NULL};
        PtyHandle *handle = spawn(argv[0], args, true, NULL);
        assert(handle != NULL);
        pid_t pid = pty_getpid(handle);
        await_exits(1);
        destroy(handle);
        kill(-pid, SIGKILL);
        assert_resources_released(before_fds, before_threads);
    } else if (strcmp(argv[1], "reader-failure") == 0 ||
               strcmp(argv[1], "waiter-failure") == 0 ||
               strcmp(argv[1], "fd-failure") == 0) {
        struct rlimit original;
        bool fd_failure = strcmp(argv[1], "fd-failure") == 0;
        if (fd_failure) {
            assert(getrlimit(RLIMIT_NOFILE, &original) == 0);
            struct rlimit limited = original;
            limited.rlim_cur = 5;
            assert(setrlimit(RLIMIT_NOFILE, &limited) == 0);
        } else {
            fail_thread = strcmp(argv[1], "reader-failure") == 0 ? 1 : 2;
        }
        char *args[] = {"sh", "-c", "sleep 60", NULL};
        assert(spawn("/bin/sh", args, true, NULL) == NULL);
        if (fd_failure) assert(setrlimit(RLIMIT_NOFILE, &original) == 0);
        assert_resources_released(before_fds, before_threads);
        assert(waitpid(-1, NULL, WNOHANG) == -1 && errno == ECHILD);
    } else {
        assert(destroy != NULL && terminate != NULL);
        char *args[] = {"bash", "--noprofile", "--norc", "-i", NULL};
        PtyHandle *handle = spawn("/bin/bash", args, true, NULL);
        assert(handle != NULL);
        for (int i = 0; i < 3000 && atomic_load(&bytes) == 0; i++) usleep(1000);
        pid_t pid = pty_getpid(handle);
        assert(terminate(handle, SIGHUP) == 0);
        usleep(250000);
        if (atomic_load(&exits) == 0) terminate(handle, SIGTERM);
        usleep(250000);
        if (atomic_load(&exits) == 0) terminate(handle, SIGKILL);
        await_exits(1);
        destroy(handle);
        assert(kill(pid, 0) == -1 && errno == ESRCH);
        assert_resources_released(before_fds, before_threads);
    }
    alarm(0);
    return 0;
}
