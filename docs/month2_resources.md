# Month 2: Edge Framework Resource Utilization, Stability, and Power

## Focus

Maximize runtime efficiency while preserving deterministic behavior under physical edge-device constraints: memory sharing, thermal throttling, fragmentation, and repeated model execution.

## Core Outcomes

- Understand zero-copy memory paths between application code and hardware drivers.
- Identify how memory bandwidth affects battery drain and thermal behavior.
- Design allocation strategies that avoid long-duration fragmentation.
- Explain how KV-cache save and restore can remove redundant prefill work.

## Zero-Copy Memory Paradigms

Key areas:

- DMABUF Heap allocation.
- Ion allocation systems.
- Shared memory structures used by CPU host code and NPU/GPU drivers.
- Avoiding unnecessary copies across process, driver, or accelerator boundaries.

Implementation target:

- `src/month2_hardware/dmabuf_allocator/ion_mem_handler.cpp`

Suggested exercises:

- Mock a hardware buffer handle abstraction.
- Track ownership, mapping state, and release behavior.
- Distinguish logical tensor lifetime from physical backing allocation lifetime.

Design notes:

- Zero-copy does not mean zero ownership complexity.
- Buffer lifetime must outlive every hardware operation that can access the memory.
- Synchronization and cache coherency need to be modeled explicitly in real systems.

## Power and Thermal System Engineering

Key areas:

- Compute-kernel execution style.
- Voltage and frequency throttling.
- Memory bandwidth as a major driver of battery drain.
- Operator fusion.
- Layer-level tiling.
- Cache reuse optimization.

Implementation target:

- `src/month2_hardware/tiling_optimizations/l2_cache_tiling.cpp`

Suggested exercises:

- Implement a tiled matrix or tensor traversal mock.
- Compare sequential traversal with cache-tiled traversal.
- Add counters for simulated cache reuse or memory traffic.

Design notes:

- Power cost often follows data movement more than arithmetic count.
- Tiling should be sized around cache behavior and hardware execution units.
- Operator fusion reduces intermediate writes and repeated memory reads.

## Deterministic Runtime Stability

Key areas:

- Memory fragmentation during long-running robotic execution.
- Static tensor lifetime pre-allocation.
- Session save and restore hooks.
- KV-cache context serialization.
- Avoiding redundant prefill compute across repeated queries.

Suggested exercises:

- Model fixed tensor lifetimes in a simple allocation table.
- Add a mock KV-cache snapshot format.
- Restore session state without reallocating hot-path buffers.

## Validation Checklist

- Buffer ownership and release rules are explicit.
- Tiling code documents assumptions about cache shape and tensor layout.
- Session state can be saved and restored deterministically.
- Notes connect memory movement, thermal behavior, and runtime stability.
