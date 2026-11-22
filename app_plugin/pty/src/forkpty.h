#ifndef FORKPTY_H_
#define FORKPTY_H_

#include <termios.h>
#include <unistd.h>

/// Step of the child's setup that failed, reported over the startup pipe.
enum pty_child_stage
{
    PTY_CHILD_SETSID = 1,
    PTY_CHILD_CONTROLLING_TERMINAL,
    PTY_CHILD_STDIO,
    PTY_CHILD_WORKING_DIRECTORY,
    PTY_CHILD_EXEC,
};

/// Writes [stage] and [error] to [error_fd] and ends the child.
void pty_child_fail(int error_fd, int stage, int error);

/// Like forkpty(3). A child that cannot set up its terminal reports the
/// failed stage and errno through [error_fd] instead of running on.
pid_t pty_forkpty(int *master, int *slave, const struct termios *termp,
                  const struct winsize *winp, int error_fd);

#endif