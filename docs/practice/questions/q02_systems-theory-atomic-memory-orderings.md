# Q2: Systems Theory: Atomic Memory Orderings

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Question

A producer thread constructs a new state object, writes its fields, and then publishes a pointer to it for a real-time consumer thread. On an ARM-based robotics SoC, the consumer sometimes observes a partially initialized object even though both sides use std::memory_order_relaxed.

Explain why this can happen and identify the acquire/release operations needed to establish a happens-before relationship between producer and consumer.

## Follow-Ups

- Why does x86 often appear to work while ARM fails?
- What is the difference between memory_order_acquire and a full fence?
- Can memory_order_consume replace acquire here?
- Why is memory_order_seq_cst not always desirable?
- How would you extend this pattern from a simple publication step to an SPSC queue?
- What changes are needed for MPMC, and where do ABA issues show up?
- How would hazard pointers or epoch-based reclamation solve safe reclamation?

## Runtime Engineer Framing

Frame this as a user-space publication problem: one runtime thread prepares state, another consumes it. Focus on which variables are shared, which atomic operation publishes readiness, and what ordering is sufficient for correctness on weakly ordered CPUs. Avoid treating memory ordering as CPU trivia detached from a real data handoff.
