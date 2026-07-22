# Q22 Answer: Systems Theory: Thermal Throttling Mitigation and Memory Thrashing

**Section:** Month 2: Edge Framework Resource Utilization, Stability, & Power

## Answer

For edge runtimes, power and heat are often dominated by moving data, not just doing arithmetic. Reading and writing large tensors through external memory costs energy and can saturate shared bandwidth. When bandwidth pressure persists, the device may heat up and throttle CPU/GPU/NPU frequencies.

Operator fusion reduces memory traffic by avoiding unnecessary intermediate tensor materialization. For example, convolution followed by activation can write the final activated value once instead of writing a full convolution output and reading it back for activation.

Tiling reduces the active working set. A runtime or kernel processes chunks that fit cache better, improving reuse before data is evicted. The runtime-level skill is to identify memory-bound parts of the graph, choose fused kernels or tiled execution, and measure whether bandwidth and thermal behavior improve.

On modern embedded platforms, moving large tensors through memory can cost more time and energy than the arithmetic itself. Continuous memory traffic is often a major driver of thermal dissipation and battery drain on mobile edge systems.
To reduce this overhead, we use structural graph optimizations:
Operator Fusion: This technique combines multiple operations (such as a 2D Convolution layer followed by a ReLU activation function) into a single execution step. This can avoid writing a full intermediate tensor to memory and reading it back immediately.
Sub-graph Layer-Level Tiling: This optimization breaks large multidimensional matrices into smaller, cache-sized blocks. The processor evaluates these blocks sequentially to improve locality and reduce repeated trips through the memory hierarchy.
