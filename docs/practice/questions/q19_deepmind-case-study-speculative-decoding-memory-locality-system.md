# Q19: DeepMind Case Study: Speculative Decoding Memory Locality System

**Section:** Month 1: LiteRT & LiteRT-LM Framework Internals (Core, Dispatch, & Trade-offs)

## Question

During LiteRT-LM deployment, keeping a 1B draft model and an 8B primary model on separate execution backends (for example, draft on CPU and primary on NPU) can create synchronization and buffer-transfer penalties. Design a runtime strategy that improves memory locality using backend placement, shared-buffer APIs, batching, and clear ownership of token/KV-cache state.

## Runtime Engineer Framing

Avoid pretending user-space code can directly control all physical address behavior. Frame this as minimizing cross-device synchronization and copies using placement choices, shared buffer APIs, batching, pinned/user-locked memory where available, and clear backend ownership.
