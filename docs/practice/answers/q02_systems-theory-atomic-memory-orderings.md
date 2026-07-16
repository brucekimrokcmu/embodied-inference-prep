# Q2 Answer: Systems Theory: Atomic Memory Orderings

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Answer

This is a publication bug, not an atomicity bug. With std::memory_order_relaxed, the producer can make the pointer visible before the ordinary writes that initialize the pointed-to object are visible to the consumer. On weakly ordered hardware like ARM, that reordering is allowed both by the compiler and by the CPU. The consumer can therefore load a non-null pointer and still observe stale or partially initialized fields when it dereferences the object.

The required pattern is release on the publishing store and acquire on the consuming load. The release store ensures every write that happened before publication in the producer becomes visible before the pointer becomes visible. The acquire load ensures the consumer does not move later reads ahead of the publication point. That pair creates a happens-before relationship on the same atomic variable.

```cpp
// Producer
auto* new_state = new StateVector(latest_data);
// Initialize all fields of *new_state first.
state_ptr.store(new_state, std::memory_order_release);

// Consumer
StateVector* current_state = state_ptr.load(std::memory_order_acquire);
if (current_state != nullptr) {
    EvaluateControlLoop(current_state);
}
```

For the follow-up questions:

- x86 often appears to work because its memory model is much stronger than ARM's, but that is an implementation detail, not a guarantee. Code that relies on x86 TSO is not portable.
- memory_order_acquire is a one-way barrier for subsequent loads and stores; it is narrower than a full fence, which orders both sides of the barrier.
- memory_order_consume is not a practical replacement in most codebases because compiler support is effectively treated as acquire.
- memory_order_seq_cst adds a single global order across seq_cst operations, which is stronger than most pointer-publication cases require and can cost performance.
- For an SPSC queue, the usual pattern is relaxed for private indices, release on the producer's publish step, and acquire on the consumer's observe step.
- For MPMC, you usually need per-slot state, compare-exchange loops, and careful reclamation logic; ABA appears when a location changes A -> B -> A and a thread mistakes the final A for the original one.
- Hazard pointers and epoch-based reclamation solve reclamation by ensuring no thread can still be reading an object before it is freed.
