# Q13 Answer: Systems Theory: Hardware Delegation and the Dispatch Layer

**Section:** Month 1: LiteRT & LiteRT-LM Framework Internals (Core, Dispatch, & Trade-offs)

## Answer

The LiteRT framework decouples generic operational code from hardware-specific acceleration through the LiteRT Dispatch API and a structured DispatchDelegate. When a model compiles at runtime via the CompiledModel interface, the runtime identifies sub-graphs targeted for hardware acceleration and passes them to the registered vendor compiler plugin.
This compiler plugin transforms the high-level sub-graph into an optimized, vendor-specific machine instruction binary. The runtime then encapsulates this binary blob within a vendor-managed DispatchDeviceContext and creates an execution handle known as a DispatchInvocationContext. During model execution, instead of registering and managing individual nodes manually, LiteRT simply passes the input/output tensor memory handles across an opaque boundary to the vendor's runtime library via the LiteRtDispatchExecute C-API interface. This architectural boundary allows full hardware acceleration while keeping the core framework code completely decoupled from vendor-specific driver updates.
