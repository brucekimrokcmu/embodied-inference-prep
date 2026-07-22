# Q27 Hint: C++ Implementation: L2-Cache Bound Sub-graph Operator Fusion Node

**Section:** Month 2: Edge Framework Resource Utilization, Stability, & Power

## Hint

At runtime level, the fused node computes convolution output and immediately applies activation before storing. Do not allocate a full intermediate activation input unless needed for correctness or debugging.

**Operator Fusion:** Write an integrated mathematical execution block. Instead of storing the output of your convolution operation back into an intermediate array, pass the value directly into your non-linear formula loop.
