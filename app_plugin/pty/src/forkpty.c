#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include <errno.h>
#include <fcntl.h>
#include <pthread.h>
#include <unistd.h>
#include <termios.h>
#include <sys/ioctl.h>

#include "forkpty.h"

void pty_child_fail(int error_fd, int stage, int error)
{
    int report[2] = {stage, error};
    ssize_t result;
    do { result = write(error_fd, report, sizeof(report)); } while (result < 0 && errno == EINTR);
    _exit(127);
}

pid_t pty_forkpty(
    int *master,
    int *slave,
    const struct termios *termp,
    const struct winsize *winp,
    int error_fd)
{
    int ptm = open("/dev/ptmx", O_RDWR | O_NOCTTY);

    if (ptm < 0)
    {
        return -1;
    }

    fcntl(ptm, F_SETFD, FD_CLOEXEC);

    if (grantpt(ptm) || unlockpt(ptm))
    {
        close(ptm);
        return -1;
    }

    char *devname;

    if ((devname = ptsname(ptm)) == NULL)
    {
        close(ptm);
        return -1;
    }

    int pts = open(devname, O_RDWR | O_NOCTTY);
    if (pts < 0)
    {
        close(ptm);
        return -1;
    }

    if (termp)
    {
        tcsetattr(pts, TCSAFLUSH, termp);
    }

    if (winp)
    {
        ioctl(pts, TIOCSWINSZ, winp);
    }

    pid_t pid = fork();

    if (pid < 0)
    {
        close(pts);
        close(ptm);
        return -1;
    }

    if (pid == 0)
    {
        close(ptm);
        if (setsid() == -1)
            pty_child_fail(error_fd, PTY_CHILD_SETSID, errno);
        if (ioctl(pts, TIOCSCTTY, (char *)NULL) == -1)
            pty_child_fail(error_fd, PTY_CHILD_CONTROLLING_TERMINAL, errno);

        if (dup2(pts, STDIN_FILENO) == -1 ||
            dup2(pts, STDOUT_FILENO) == -1 ||
            dup2(pts, STDERR_FILENO) == -1)
            pty_child_fail(error_fd, PTY_CHILD_STDIO, errno);

        if (pts > 2)
        {
            close(pts);
        }
    }
    else
    {
        *master = ptm;
        if (slave)
        {
            *slave = pts;
        }
        else
        {
            close(pts);
        }
    }

    return pid;
}
