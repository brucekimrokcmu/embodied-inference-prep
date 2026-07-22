# Q2 Hint: Systems Theory: Atomic Memory Orderings

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Hint

At runtime level, identify the publication point. Writes that initialize the object must happen before the producer performs a release store. The consumer must perform an acquire load before reading the object. Relaxed atomics only make the atomic operation indivisible; they do not publish the surrounding non-atomic writes.

Prefer explaining the smallest sufficient ordering first. `seq_cst` may be correct, but a runtime engineer should know why acquire/release is usually the intended handoff pattern.

**Atomic Memory Orderings:** Think in terms of publication, not just atomicity. The producer must finish all ordinary writes to the new object before it stores the pointer with memory_order_release. The consumer must load that same atomic with memory_order_acquire before dereferencing the pointer. Relaxed operations are fine for local bookkeeping, but they do not establish a happens-before edge.

For the follow-up questions, compare the stronger ordering guarantees of x86 with the weaker model on ARM, and be ready to explain why acquire/release is narrower than seq_cst but usually sufficient for safe pointer publication.
