# Q3: Systems Theory: Exception Safety and Move Semantics

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Question

When creating an on-device tensor allocation buffer, why must custom move constructors and move assignment operators be declared with the noexcept specifier? Tracing back to the internal implementation mechanics of sequence containers such as std::vector::resize, what structural safety hazard occurs if noexcept is omitted?
