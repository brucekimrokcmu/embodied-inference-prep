# Q21: Systems Theory: Zero-Copy Mechanics via DMABUF Heap

**Section:** Month 2: Edge Framework Resource Utilization, Stability, & Power

## Question

Explain how DMABUF Heap (or Ion memory systems) achieves zero-copy tensor sharing across heterogeneous hardware boundaries. Trace the physical path of a raw image buffer from a camera controller module to an NPU engine, and analyze why using standard Unix memory copy operations (memcpy) causes dramatic voltage drops and latency penalties.
