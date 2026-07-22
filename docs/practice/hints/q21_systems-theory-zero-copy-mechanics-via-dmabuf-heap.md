# Q21 Hint: Systems Theory: Zero-Copy Mechanics via DMABUF Heap

**Section:** Month 2: Edge Framework Resource Utilization, Stability, & Power

## Hint

DMABUF is about sharing a buffer handle across subsystems. The runtime engineer manages file descriptors, mappings, cache synchronization, fences, and ownership. Zero-copy means avoiding redundant CPU-visible copies; it does not mean zero synchronization or zero cost.

**DMABUF Heap:** Focus on the distinction between sharing file descriptors and copying memory. A file descriptor points directly to a single shared physical memory page in the kernel, allowing multiple physical hardware accelerators to access the same memory pool.
