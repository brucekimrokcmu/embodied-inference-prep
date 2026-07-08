# Q7: C++ Implementation: RAII-Guaranteed Thread Wrapper with Explicit Core Affinity

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Question

Write a production-level C++ structural wrapper for a real-time worker thread that guarantees safe execution join patterns via C++20 std::jthread. The constructor must accept a lambda payload and a target CPU core index, enforcing hardware isolation via low-level native thread handles (pthread_setaffinity_np) before executing the payload.
