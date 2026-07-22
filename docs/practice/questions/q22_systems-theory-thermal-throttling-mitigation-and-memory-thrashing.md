# Q22: Systems Theory: Thermal Throttling Mitigation and Memory Thrashing

**Section:** Month 2: Edge Framework Resource Utilization, Stability, & Power

## Question

Explain why memory bandwidth and repeated tensor reads/writes are often a larger runtime bottleneck than raw FLOPs on mobile systems. How do techniques like structural operator fusion and sub-graph layer-level tiling decrease this memory traffic?

## Runtime Engineer Framing

Frame this as memory-traffic reduction visible to a runtime engineer: fewer tensor reads/writes, smaller working sets, better locality, and fewer intermediate buffers. Avoid requiring circuit-level thermal modeling.
