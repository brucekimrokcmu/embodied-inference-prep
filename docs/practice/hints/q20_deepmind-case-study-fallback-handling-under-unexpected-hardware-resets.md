# Q20 Hint: DeepMind Case Study: Fallback Handling under Unexpected Hardware Resets

**Section:** Month 1: LiteRT & LiteRT-LM Framework Internals (Core, Dispatch, & Trade-offs)

## Hint

Separate model execution from control safety. The fallback path does not have to match accelerator throughput; it has to preserve a valid output contract or trigger a safe degraded mode. Think about timeouts, circuit breakers, health state, and preloaded CPU kernels.

**Fallback Architecture:** Wrap your primary accelerator execution invocation with strict error-handling code blocks. If the driver returns a non-zero initialization or runtime error code, seamlessly route the tensor tracking pointers into an alternate CPU-bound execution engine.
