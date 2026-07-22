# Q17: C++ Implementation: Dynamic Tensor Lifetime Tracking Node

**Section:** Month 1: LiteRT & LiteRT-LM Framework Internals (Core, Dispatch, & Trade-offs)

## Question

Write a lightweight C++ mock component that acts as a runtime sub-graph executor. It must accept a series of custom operator links, evaluate their memory block dependencies, and handle internal tensor buffer recycling using reference-counting wrappers to ensure intermediate buffers are freed immediately after their last operator read.

## Runtime Engineer Framing

Focus on tensor lifetime planning in user-space: who produces a buffer, who consumes it, when the last read occurs, and when memory can be reused. Reference counting is one approach, but static use-count planning may be better in hot paths.
