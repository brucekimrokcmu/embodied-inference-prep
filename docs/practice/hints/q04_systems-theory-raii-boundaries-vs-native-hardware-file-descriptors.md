# Q4 Hint: Systems Theory: RAII boundaries vs. Native Hardware File Descriptors

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Hint

**RAII & Linux FDs:** Remember that file descriptors are standard integers referencing an interior kernel structure. If an object holding a file descriptor goes out of scope due to an exception without invoking close(), the underlying system handle remains open indefinitely, inducing a resource leak.
