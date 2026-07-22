# Q16: C++ Implementation: Asynchronous Model Execution Layer via CompiledModel

**Section:** Month 1: LiteRT & LiteRT-LM Framework Internals (Core, Dispatch, & Trade-offs)

## Question

Write a high-performance C++ execution wrapper around the LiteRT CompiledModel API. The implementation must asynchronously feed input buffers, trigger low-latency model evaluation on an available NPU accelerator target, and utilize synchronization events (litert::Event) to handle completion callbacks without stalling the primary calling loop.

## Runtime Engineer Framing

Explain async execution as a user-space coordination problem: input ownership, output ownership, completion signaling, cancellation/timeouts, and avoiding blocking the caller. The accelerator API details are secondary to the lifecycle of submitted work.
