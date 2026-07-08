# Q4: Systems Theory: RAII boundaries vs. Native Hardware File Descriptors

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Question

When interfacing with hardware elements like an external camera driver via Linux device paths (/dev/videoX), how does standard RAII prevent file descriptor leaks during unexpected application crashes, and what happens to physical hardware resources if an unhandled exception triggers stack unwinding?
