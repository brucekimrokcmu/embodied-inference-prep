# Q17 Hint: C++ Implementation: Dynamic Tensor Lifetime Tracking Node

**Section:** Month 1: LiteRT & LiteRT-LM Framework Internals (Core, Dispatch, & Trade-offs)

## Hint

Build a small dependency graph. Count how many future consumers each tensor has. After an operator runs, decrement counts for its inputs. When a count reaches zero, the buffer can return to the pool. Avoid general heap allocation in the execution loop.

**Dynamic Lifetime Node:** Use an explicit tracking table to log when individual tensor buffers are read for the last time. When that specific operator finishing executing, immediately release or recycle that buffer block.
