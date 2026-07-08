# Q2 Answer: Systems Theory: Atomic Memory Orderings

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Answer

On weakly-ordered hardware architectures like ARM, the compiler and CPU can reorder memory reads and writes to optimize performance, provided single-thread logic remains consistent. Using std::memory_order_relaxed strips away all thread synchronization requirements, meaning the CPU is free to reorder write operations arbitrarily. If a background worker allocates a new state vector and updates its atomic pointer using relaxed ordering, the pointer assignment might become visible to the real-time thread before the actual data contents are committed to main memory. Consequently, the real-time thread could dereference a stale or uninitialized memory address, leading to an immediate application crash.
To fix this, you must apply a structured Acquire-Release ordering model:
```cpp
// Background Inference Thread (Producer)
auto* new_vector = new StateVector(latest_data);
// Ensure all memory writes are fully committed before the pointer becomes visible
state_ptr.store(new_vector, std::memory_order_release);

// Real-Time Control Thread (Consumer)
// Ensure subsequent read operations cannot be reordered before this pointer load
StateVector* current_vector = state_ptr.load(std::memory_order_acquire);
if (current_vector) {
    EvaluateControlLoop(current_vector);
}

```
