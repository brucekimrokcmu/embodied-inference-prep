# Q4: Systems Theory: RAII boundaries vs. Native Hardware File Descriptors

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Question

When interfacing with hardware elements like an external camera driver via Linux device paths (/dev/videoX), how does standard RAII prevent file descriptor leaks during unexpected application crashes, and what happens to physical hardware resources if an unhandled exception triggers stack unwinding?

## Runtime Engineer Framing

Answer from the perspective of a Linux user-space runtime process. Distinguish ordinary stack unwinding from hard process termination. Focus on what your C++ wrapper can guarantee for file descriptors, mappings, buffers, and driver sessions, and what still requires process-level supervision or driver support.
