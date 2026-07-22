# Q21: Systems Theory: Zero-Copy Mechanics via DMABUF Heap

**Section:** Month 2: Edge Framework Resource Utilization, Stability, & Power

## Question

Explain how DMABUF Heap (or Ion memory systems) supports zero-copy tensor sharing across heterogeneous hardware boundaries. Trace the user-space/runtime ownership path of a raw image buffer from camera capture to NPU input, and analyze why extra `memcpy` operations can increase latency, memory bandwidth pressure, power, and thermal load.

## Runtime Engineer Framing

Answer from the user-space runtime boundary: allocation through platform APIs, file-descriptor handles, import/export between drivers, synchronization, and avoiding CPU copies. Do not require DRAM-controller detail or claim exact voltage behavior unless measured.
