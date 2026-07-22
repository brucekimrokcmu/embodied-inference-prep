# Q18: C++ Implementation: Multi-Token Prediction (MTP) Speculative Decoding Dispatcher

**Section:** Month 1: LiteRT & LiteRT-LM Framework Internals (Core, Dispatch, & Trade-offs)

## Question

Implement a structural C++ manager class that coordinates speculative decoding for LiteRT-LM. The class must manage two distinct CompiledModel targets: a small "draft" model and a larger primary model. It must dispatch the draft model to generate K candidate tokens sequentially, and then feed the complete token sequence into the primary model for parallel validation in a single execution step.

## Runtime Engineer Framing

Explain speculative decoding as runtime orchestration: two model handles, token buffers, KV-cache ownership, validation, rollback, and scheduling. The key is reducing end-to-end latency without corrupting model state when draft tokens are rejected.
