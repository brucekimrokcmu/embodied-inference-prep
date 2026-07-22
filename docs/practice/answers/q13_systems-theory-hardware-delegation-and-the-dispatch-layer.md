# Q13 Answer: Systems Theory: Hardware Delegation and the Dispatch Layer

**Section:** Month 1: LiteRT & LiteRT-LM Framework Internals (Core, Dispatch, & Trade-offs)

## Answer

At runtime level, a dispatch/delegate layer decouples graph execution from specific accelerator implementations. The core runtime understands operators, tensors, shapes, and scheduling. A delegate reports which operators or subgraphs it supports and provides an execution path for those portions.

The runtime can then partition the graph: supported regions go to the delegate, unsupported regions stay on CPU or another backend. This avoids hardcoding every vendor NPU into the core framework. The stable boundary is metadata, tensor buffers, synchronization, and error reporting.

The runtime engineer's concerns are capability negotiation, buffer lifetime, zero-copy compatibility, fallback behavior, and synchronization. Vendor driver details matter, but they should sit behind the delegate boundary instead of leaking throughout the framework.

The LiteRT framework decouples generic operational code from hardware-specific acceleration through the LiteRT Dispatch API and a structured DispatchDelegate. When a model compiles at runtime via the CompiledModel interface, the runtime identifies sub-graphs targeted for hardware acceleration and passes them to the registered vendor compiler plugin.
This compiler plugin transforms the high-level sub-graph into an optimized, vendor-specific machine instruction binary. The runtime then encapsulates this binary blob within a vendor-managed DispatchDeviceContext and creates an execution handle known as a DispatchInvocationContext. During model execution, instead of registering and managing individual nodes manually, LiteRT simply passes the input/output tensor memory handles across an opaque boundary to the vendor's runtime library via the LiteRtDispatchExecute C-API interface. This architectural boundary allows full hardware acceleration while keeping the core framework code completely decoupled from vendor-specific driver updates.
