# Q3: Systems Theory: Exception Safety and Move Semantics

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Question

When creating an on-device tensor allocation buffer, why must custom move constructors and move assignment operators be declared with the noexcept specifier? Tracing back to the internal implementation mechanics of sequence containers such as std::vector::resize, what structural safety hazard occurs if noexcept is omitted?

## Runtime Engineer Framing

Explain this as a container-safety and latency issue in user-space C++. A runtime tensor wrapper may own a buffer, file descriptor, mapping, or accelerator handle. When a `std::vector` grows or compacts such objects, the runtime must know whether moving them can fail, whether ownership can be duplicated, and whether fallback copying is even legal.
