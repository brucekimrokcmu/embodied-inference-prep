# Q7 Hint: C++ Implementation: RAII-Guaranteed Thread Wrapper with Explicit Core Affinity

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Hint

**Thread & Affinity:** Access the native system primitive via jthread::native_handle(). For Linux targets, apply cpu_set_t structures along with CPU_ZERO and CPU_SET macros to bind execution to specific CPU cores.
