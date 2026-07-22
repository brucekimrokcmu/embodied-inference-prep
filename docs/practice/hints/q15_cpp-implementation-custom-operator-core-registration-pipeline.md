# Q15 Hint: C++ Implementation: Custom Operator Core Registration Pipeline

**Section:** Month 1: LiteRT & LiteRT-LM Framework Internals (Core, Dispatch, & Trade-offs)

## Hint

A good mock has a small interface, a registration table or factory, lifecycle hooks, and clear ownership. `Init` should create persistent state, layout inference should not mutate unrelated state, `Run` should use provided buffers, and cleanup should be deterministic.

**Custom Operator Core:** Look at the abstract pure virtual methods within litert::CustomOpKernel. You must manually unpack information from the configuration buffers using helper functions like LiteRtUnlockTensorBuffer or context layout checks.
