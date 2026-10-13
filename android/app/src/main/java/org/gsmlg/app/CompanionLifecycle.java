package org.gsmlg.app;

/** Main-thread state for one pending or attached companion Activity. */
final class CompanionLifecycle {
    private Integer displayId;
    private long generation;
    private boolean opening;
    private boolean attached;
    private boolean closing;

    static boolean eligible(int candidate, int host, boolean presentation) {
        return presentation && candidate > 0 && candidate != host;
    }

    Integer displayId() { return displayId; }
    long generation() { return generation; }
    boolean isClosing() { return closing; }
    boolean isOpening() { return opening; }
    boolean needsLaunch() { return !opening && !attached && !closing; }

    long show(int id) {
        if (closing || (displayId != null && displayId != id)) {
            throw new IllegalStateException("Close the previous companion first");
        }
        if (needsLaunch()) {
            displayId = id;
            opening = true;
            generation++;
        }
        return generation;
    }

    boolean attach(long token) {
        if (token != generation || !opening) return false;
        opening = false;
        attached = true;
        return !closing;
    }

    /** True means close must wait for the pending/attached Activity to detach. */
    boolean close() {
        closing = opening || attached;
        if (!closing) clear();
        return closing;
    }

    void detached(boolean changingConfigurations) {
        attached = false;
        if (changingConfigurations && !closing) {
            opening = true;
        } else {
            clear();
        }
    }

    void launchFailed() { clear(); }

    private void clear() {
        displayId = null;
        opening = false;
        attached = false;
        closing = false;
    }
}
