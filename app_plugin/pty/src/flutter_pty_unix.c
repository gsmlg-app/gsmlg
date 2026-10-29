#include <errno.h>
#include <fcntl.h>
#include <poll.h>
#include <pthread.h>
#include <signal.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <termios.h>
#include <sys/ioctl.h>
#include <sys/wait.h>
#ifdef __APPLE__
#include <TargetConditionals.h>
#if TARGET_OS_OSX
#include <libproc.h>
#endif
#elif defined(__linux__)
#include <dirent.h>
#endif

#include "forkpty.h"
#include "flutter_pty.h"

struct PtyHandle
{
    int ptm;
    pid_t pid;
    pid_t foreground_group;
    pthread_mutex_t mutex;
    pthread_cond_t read_ready;
    pthread_t reader;
    pthread_t waiter;
    bool ackRead;
    bool awaiting_ack;
    bool exited;
    bool terminating;
    Dart_Port stdout_port;
    Dart_Port exit_port;
};

static _Thread_local char error_message[256];

static void record_error(const char *operation, int error)
{
    snprintf(error_message, sizeof(error_message), "%s: %s", operation, strerror(error));
}

static void *read_loop(void *arg)
{
    PtyHandle *handle = arg;
    char buffer[1024];
    size_t exit_bytes = 0;
    int64_t drain_deadline = 0;
    struct pollfd descriptor = {.fd = handle->ptm, .events = POLLIN};

    while (1)
    {
        pthread_mutex_lock(&handle->mutex);
        while (handle->ackRead && handle->awaiting_ack && !handle->exited && !handle->terminating)
            pthread_cond_wait(&handle->read_ready, &handle->mutex);
        bool exited = handle->exited;
        pthread_mutex_unlock(&handle->mutex);
        if (exited)
        {
            struct timespec now;
            if (clock_gettime(CLOCK_MONOTONIC, &now) != 0) break;
            int64_t milliseconds = (int64_t)now.tv_sec * 1000 + now.tv_nsec / 1000000;
            if (drain_deadline == 0) drain_deadline = milliseconds + 250;
            if (milliseconds >= drain_deadline || exit_bytes >= 1024 * 1024) break;
        }

        int ready = poll(&descriptor, 1, 50);
        if (ready < 0 && errno == EINTR) continue;
        if (ready < 0 || (ready == 0 && exited)) break;
        if (ready == 0) continue;

        ssize_t length = read(handle->ptm, buffer, sizeof(buffer));
        if (length < 0 && (errno == EINTR || errno == EAGAIN || errno == EWOULDBLOCK)) continue;
        if (length <= 0) break;
        if (exited) exit_bytes += length;

        pthread_mutex_lock(&handle->mutex);
        handle->awaiting_ack = true;
        pthread_mutex_unlock(&handle->mutex);

        Dart_CObject result;
        result.type = Dart_CObject_kTypedData;
        result.value.as_typed_data.type = Dart_TypedData_kUint8;
        result.value.as_typed_data.length = length;
        result.value.as_typed_data.values = (uint8_t *)buffer;
        if (!Dart_PostCObject_DL(handle->stdout_port, &result)) break;
    }

    Dart_CObject done = {.type = Dart_CObject_kNull};
    Dart_PostCObject_DL(handle->stdout_port, &done);
    return NULL;
}

static bool owns_foreground_group(PtyHandle *handle)
{
    pid_t group = handle->foreground_group;
    pid_t session = getsid(group);
    if (session >= 0) return session == handle->pid;
    if (errno != ESRCH) return false;

#if defined(__APPLE__) && TARGET_OS_OSX
    pid_t members[64];
    int count = proc_listpgrppids(group, members, sizeof(members));
    for (int i = 0; i < count && i < 64; i++)
        if (getpgid(members[i]) == group && getsid(members[i]) == handle->pid) return true;
#elif defined(__linux__)
    DIR *processes = opendir("/proc");
    if (processes == NULL) return false;
    bool owned = false;
    struct dirent *entry;
    while (!owned && (entry = readdir(processes)) != NULL)
    {
        char *end;
        long member = strtol(entry->d_name, &end, 10);
        if (member <= 0 || *end != '\0') continue;
        char path[64];
        snprintf(path, sizeof(path), "/proc/%ld/stat", member);
        FILE *input = fopen(path, "r");
        if (input == NULL) continue;
        char buffer[1024];
        size_t length = fread(buffer, 1, sizeof(buffer) - 1, input);
        fclose(input);
        buffer[length] = '\0';
        char *fields = strrchr(buffer, ')');
        char state;
        long parent, process_group, process_session;
        if (fields != NULL && sscanf(fields + 1, " %c %ld %ld %ld",
                &state, &parent, &process_group, &process_session) == 4)
            owned = process_group == group && process_session == handle->pid;
    }
    closedir(processes);
    return owned;
#endif
    return false;
}

static void signal_groups(PtyHandle *handle, int signal_number)
{
    if (handle->foreground_group > 0 && handle->foreground_group != handle->pid &&
        owns_foreground_group(handle))
        kill(-handle->foreground_group, signal_number);
    kill(-handle->pid, signal_number);
}

static void *wait_exit_thread(void *arg)
{
    PtyHandle *handle = arg;
    int status = 0;
    siginfo_t info;
    int observed;
    do { observed = waitid(P_PID, handle->pid, &info, WEXITED | WNOWAIT); }
    while (observed < 0 && errno == EINTR);

    pthread_mutex_lock(&handle->mutex);
    handle->exited = true;
    if (observed == 0 && handle->terminating) signal_groups(handle, SIGKILL);
    pthread_cond_broadcast(&handle->read_ready);
    pthread_mutex_unlock(&handle->mutex);

    pthread_join(handle->reader, NULL);
    pid_t result = -1;
    if (observed == 0)
    {
        do { result = waitpid(handle->pid, &status, 0); } while (result < 0 && errno == EINTR);
    }
    int code = result < 0 ? -1 : WIFEXITED(status) ? WEXITSTATUS(status) : -WTERMSIG(status);
    Dart_PostInteger_DL(handle->exit_port, code);
    return NULL;
}

static void set_environment(char **environment)
{
    if (environment == NULL) return;
    while (*environment != NULL) putenv(*environment++);
}

static void fail_child(int error_fd, int error)
{
    ssize_t result;
    do { result = write(error_fd, &error, sizeof(error)); } while (result < 0 && errno == EINTR);
    _exit(127);
}

FFI_PLUGIN_EXPORT PtyHandle *pty_create(PtyOptions *options)
{
    error_message[0] = '\0';
    int startup[2];
    if (pipe(startup) != 0)
    {
        record_error("pipe", errno);
        return NULL;
    }
    if (fcntl(startup[0], F_SETFD, FD_CLOEXEC) == -1 ||
        fcntl(startup[1], F_SETFD, FD_CLOEXEC) == -1)
    {
        record_error("fcntl", errno);
        close(startup[0]);
        close(startup[1]);
        return NULL;
    }

    struct winsize size = {.ws_row = options->rows, .ws_col = options->cols};
    int master = -1;
    pid_t pid = pty_forkpty(&master, NULL, NULL, &size);
    if (pid == 0)
    {
        close(startup[0]);
        set_environment(options->environment);
        if (options->working_directory != NULL && options->working_directory[0] != '\0' &&
            chdir(options->working_directory) != 0)
            fail_child(startup[1], errno);
        execvp(options->executable, options->arguments);
        fail_child(startup[1], errno);
    }

    close(startup[1]);
    if (pid < 0)
    {
        record_error("pty_forkpty", errno);
        close(startup[0]);
        return NULL;
    }

    int child_error = 0;
    ssize_t length;
    do { length = read(startup[0], &child_error, sizeof(child_error)); } while (length < 0 && errno == EINTR);
    int startup_error = errno;
    close(startup[0]);
    if (length != 0)
    {
        record_error("PTY startup", length > 0 ? child_error : startup_error);
        kill(-pid, SIGKILL);
        while (waitpid(pid, NULL, 0) < 0 && errno == EINTR) {}
        close(master);
        return NULL;
    }

    PtyHandle *handle = calloc(1, sizeof(PtyHandle));
    int error = ENOMEM;
    bool mutex_ready = false;
    bool condition_ready = false;
    bool reader_ready = false;
    if (handle == NULL) goto fail;
    int flags = fcntl(master, F_GETFL);
    if (flags == -1 || fcntl(master, F_SETFL, flags | O_NONBLOCK) == -1)
    {
        error = errno;
        goto fail;
    }
    handle->ptm = master;
    handle->pid = pid;
    handle->ackRead = options->ackRead;
    handle->stdout_port = options->stdout_port;
    handle->exit_port = options->exit_port;
    if ((error = pthread_mutex_init(&handle->mutex, NULL)) != 0) goto fail;
    mutex_ready = true;
    if ((error = pthread_cond_init(&handle->read_ready, NULL)) != 0) goto fail;
    condition_ready = true;
    if ((error = pthread_create(&handle->reader, NULL, read_loop, handle)) != 0) goto fail;
    reader_ready = true;
    if ((error = pthread_create(&handle->waiter, NULL, wait_exit_thread, handle)) != 0) goto fail;
    return handle;

fail:
    record_error("PTY initialization", error);
    kill(-pid, SIGKILL);
    while (waitpid(pid, NULL, 0) < 0 && errno == EINTR) {}
    if (reader_ready)
    {
        pthread_mutex_lock(&handle->mutex);
        handle->exited = true;
        pthread_cond_broadcast(&handle->read_ready);
        pthread_mutex_unlock(&handle->mutex);
        pthread_join(handle->reader, NULL);
    }
    if (condition_ready) pthread_cond_destroy(&handle->read_ready);
    if (mutex_ready) pthread_mutex_destroy(&handle->mutex);
    close(master);
    free(handle);
    return NULL;
}

FFI_PLUGIN_EXPORT int pty_terminate(PtyHandle *handle, int signal_number)
{
    pthread_mutex_lock(&handle->mutex);
    if (!handle->exited)
    {
        pid_t foreground = tcgetpgrp(handle->ptm);
        if (foreground > 0) handle->foreground_group = foreground;
        handle->terminating = true;
        signal_groups(handle, signal_number);
        pthread_cond_broadcast(&handle->read_ready);
    }
    pthread_mutex_unlock(&handle->mutex);
    return 0;
}

FFI_PLUGIN_EXPORT void pty_destroy(PtyHandle *handle)
{
    pthread_join(handle->waiter, NULL);
    close(handle->ptm);
    pthread_cond_destroy(&handle->read_ready);
    pthread_mutex_destroy(&handle->mutex);
    free(handle);
}

FFI_PLUGIN_EXPORT int pty_kill(PtyHandle *handle, int signal_number)
{
    pthread_mutex_lock(&handle->mutex);
    int result = handle->exited ? -1 : kill(handle->pid, signal_number);
    pthread_mutex_unlock(&handle->mutex);
    return result;
}

FFI_PLUGIN_EXPORT void pty_write(PtyHandle *handle, char *buffer, int length)
{
    struct pollfd descriptor = {.fd = handle->ptm, .events = POLLOUT};
    while (length > 0)
    {
        pthread_mutex_lock(&handle->mutex);
        bool stopped = handle->exited || handle->terminating;
        pthread_mutex_unlock(&handle->mutex);
        if (stopped) return;

        ssize_t written = write(handle->ptm, buffer, length);
        if (written > 0)
        {
            buffer += written;
            length -= written;
            continue;
        }
        if (written < 0 && errno == EINTR) continue;
        if (written < 0 && (errno == EAGAIN || errno == EWOULDBLOCK))
        {
            int ready = poll(&descriptor, 1, 50);
            if (ready < 0 && errno != EINTR) return;
            if (ready > 0 && (descriptor.revents & (POLLERR | POLLHUP | POLLNVAL))) return;
            continue;
        }
        return;
    }
}

FFI_PLUGIN_EXPORT void pty_ack_read(PtyHandle *handle)
{
    pthread_mutex_lock(&handle->mutex);
    handle->awaiting_ack = false;
    pthread_cond_signal(&handle->read_ready);
    pthread_mutex_unlock(&handle->mutex);
}

FFI_PLUGIN_EXPORT int pty_resize(PtyHandle *handle, int rows, int cols)
{
    struct winsize size = {.ws_row = rows, .ws_col = cols};
    return ioctl(handle->ptm, TIOCSWINSZ, &size);
}

FFI_PLUGIN_EXPORT int pty_getpid(PtyHandle *handle)
{
    return handle->pid;
}

FFI_PLUGIN_EXPORT char *pty_error(void)
{
    return error_message;
}
