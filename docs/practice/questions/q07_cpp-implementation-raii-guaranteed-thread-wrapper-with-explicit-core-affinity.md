# Q7: C++ Implementation: RAII-Guaranteed Thread Wrapper with Explicit Core Affinity

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Question

Write a production-level C++ structural wrapper for a real-time worker thread that guarantees safe execution join patterns via C++20 std::jthread. The constructor must accept a lambda payload and a target CPU core index, enforcing hardware isolation via low-level native thread handles (pthread_setaffinity_np) before executing the payload.

## Runtime Engineer Framing

Focus on the wrapper responsibilities visible to user-space runtime code: lifetime, cancellation, joining, error reporting, and optional affinity. CPU affinity is a tuning knob, not the core abstraction. The wrapper should remain safe if affinity setup fails or is unavailable.
