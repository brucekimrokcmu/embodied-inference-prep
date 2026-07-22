# Q12 Answer: Systems Theory: LiteRT Graph Traversal and Node Lifecycles

**Section:** Month 1: LiteRT & LiteRT-LM Framework Internals (Core, Dispatch, & Trade-offs)

## Answer

Runtime lifecycle is about moving expensive planning out of the hot path. `Init` creates or records persistent operator state. `Prepare` checks input/output shapes, resolves tensor dimensions when possible, chooses buffer sizes, and builds a memory plan. `Invoke` executes using the prepared plan. `Free` releases resources owned by the node or subgraph.

For an edge runtime, the key is that `Invoke` may run hundreds or thousands of times. If shape inference, allocation, or graph traversal happens there unnecessarily, latency becomes harder to bound. `Prepare` is where the runtime should discover dynamic dimensions, allocate or assign tensor buffers, and validate that delegates or kernels can support the final layout.

If input shapes change at runtime, the system may need to re-run some preparation. The design question is how to contain that cost and avoid surprising allocations in the control loop.

Init: The framework instantiates the operator kernel instance and allocates local operational state tracking blocks. It reads configuration properties directly from the model's serialized FlatBuffer file.
Prepare: This is a critical stage for performance tuning. The framework verifies input tensor configurations, evaluates dynamic input lengths, and computes output tensor shapes. It also maps memory requirements to specific buffer layouts, determines internal layer sizing constraints, and builds a static memory execution plan before running the core network blocks.
Invoke: The framework executes the core kernel logic. It reads data from input memory addresses, triggers numerical processing loops via hardware instructions or accelerator commands, and writes output values to the designated memory locations.
Free: The framework destroys the internal state tracking structures, unbinds local execution references, and releases transient allocation tracking elements.
