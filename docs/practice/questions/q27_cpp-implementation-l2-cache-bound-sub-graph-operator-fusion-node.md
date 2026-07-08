# Q27: C++ Implementation: L2-Cache Bound Sub-graph Operator Fusion Node

**Section:** Month 2: Edge Framework Resource Utilization, Stability, & Power

## Question

Implement a custom C++ processing node that combines a standard 2D convolution routine with a following non-linear activation operator (e.g., Hard-Swish). The combined node must process elements sequentially within the same hardware register lifecycle, avoiding intermediary write-backs to external system memory.
