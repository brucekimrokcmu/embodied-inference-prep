# Q2 Hint: Systems Theory: Atomic Memory Orderings

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Hint

**Atomic Memory Orderings:** Think in terms of publication, not just atomicity. The producer must finish all ordinary writes to the new object before it stores the pointer with memory_order_release. The consumer must load that same atomic with memory_order_acquire before dereferencing the pointer. Relaxed operations are fine for local bookkeeping, but they do not establish a happens-before edge.

For the follow-up questions, compare the stronger ordering guarantees of x86 with the weaker model on ARM, and be ready to explain why acquire/release is narrower than seq_cst but usually sufficient for safe pointer publication.
