# Q22 Hint: Systems Theory: Thermal Throttling Mitigation and Memory Thrashing

**Section:** Month 2: Edge Framework Resource Utilization, Stability, & Power

## Hint

Look for intermediate tensors that are written to memory and then immediately read by the next op. Fusion can keep values in registers/cache. Tiling makes the active working set fit cache better. The runtime engineer can measure bandwidth, latency, temperature, and throttling, then choose execution plans accordingly.

**Thermal Throttling & Memory:** Moving bytes over external lines to DRAM consumes significant electrical current. Fusing operators allows a thread to pass data directly through local CPU registers, removing the need to write intermediate results back to main memory.
