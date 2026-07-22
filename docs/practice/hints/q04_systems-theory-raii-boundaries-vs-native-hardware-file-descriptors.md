# Q4 Hint: Systems Theory: RAII boundaries vs. Native Hardware File Descriptors

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Hint

RAII handles normal scope exit and exception unwinding. It does not mean destructors run after every possible crash mode. For user-space runtime work, separate "C++ exception unwinds the stack" from "the process is killed or segfaults." The kernel closes file descriptors when a process exits, but device state may still need driver cleanup, reset logic, or an external supervisor.

**RAII & Linux FDs:** Remember that file descriptors are standard integers referencing an interior kernel structure. If an object holding a file descriptor goes out of scope due to an exception without invoking close(), the underlying system handle remains open indefinitely, inducing a resource leak.
