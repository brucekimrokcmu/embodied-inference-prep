# Q22 Answer: Systems Theory: Thermal Throttling Mitigation and Memory Thrashing

**Section:** Month 2: Edge Framework Resource Utilization, Stability, & Power

## Answer

On modern embedded platforms, moving bytes to and from external DRAM chips requires significantly more electrical power than performing logical calculations within local processor registers. This continuous memory traffic, often called memory thrashing, is the primary driver of thermal dissipation and battery drain on mobile edge systems.
To reduce this overhead, we use structural graph optimizations:
Operator Fusion: This technique combines multiple operations (such as a 2D Convolution layer followed by a ReLU activation function) into a single execution step. This allows intermediate results to pass directly through local registers, removing the need to write them back to external DRAM.
Sub-graph Layer-Level Tiling: This optimization breaks large multidimensional matrices into smaller, cache-sized blocks. The processor evaluates these blocks sequentially to ensure data stays within local L2/L3 cache lines during calculations, minimizing high-power DRAM access cycles.
