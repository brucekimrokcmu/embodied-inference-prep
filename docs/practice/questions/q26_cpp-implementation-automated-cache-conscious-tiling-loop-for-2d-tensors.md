# Q26: C++ Implementation: Automated Cache-Conscious Tiling Loop for 2D Tensors

**Section:** Month 2: Edge Framework Resource Utilization, Stability, & Power

## Question

Write a hardware-optimized C++ matrix manipulation function that breaks a large 2D input tensor into distinct, smaller memory tiles matched to a target CPU L2 cache footprint. The code must process elements iteratively using cache-friendly layouts and explicit SIMD alignment operations.

## Runtime Engineer Framing

Make this a cache-locality loop design problem. The implementation should choose tile sizes from element size and cache budget, preserve correctness at boundaries, and improve locality without requiring hand-written SIMD for the basic answer.
