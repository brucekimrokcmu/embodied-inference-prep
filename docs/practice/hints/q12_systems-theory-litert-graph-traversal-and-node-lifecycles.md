# Q12 Hint: Systems Theory: LiteRT Graph Traversal and Node Lifecycles

**Section:** Month 1: LiteRT & LiteRT-LM Framework Internals (Core, Dispatch, & Trade-offs)

## Hint

Separate one-time setup from per-inference execution. `Init` owns persistent resources, `Prepare` resolves shapes and memory plans, `Invoke` should run with minimal allocation, and `Free` releases owned runtime resources.

**LiteRT Node Lifecycle:** Focus on the critical role of Prepare. This step checks the shape of input tensors, propagates dimension constraints through the subgraph, and tells the runtime allocator exactly how much memory to reserve before execution begins.
