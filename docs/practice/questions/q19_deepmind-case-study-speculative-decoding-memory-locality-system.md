# Q19: DeepMind Case Study: Speculative Decoding Memory Locality System

**Section:** Month 1: LiteRT & LiteRT-LM Framework Internals (Core, Dispatch, & Trade-offs)

## Question

During LiteRT-LM deployment, keeping a 1B draft model and an 8B primary model on distinct, isolated physical computing units (e.g., Draft on CPU, Primary on NPU) incurs high cross-bus token synchronization penalties. Design an architectural strategy that enforces memory locality to eliminate these stalls, detailing how memory addresses should be pinned.
