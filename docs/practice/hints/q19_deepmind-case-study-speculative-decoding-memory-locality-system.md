# Q19 Hint: DeepMind Case Study: Speculative Decoding Memory Locality System

**Section:** Month 1: LiteRT & LiteRT-LM Framework Internals (Core, Dispatch, & Trade-offs)

## Hint

Ask where each byte is produced, consumed, and synchronized. If draft output is tiny but synchronization is frequent, batching may matter more than pinning. If KV cache is large, backend placement and avoiding copies matter more.

**Speculative Memory Locality:** Think about unified memory architectures or shared allocation pools across devices. Keeping the candidate verification vectors on a single shared memory plane avoids high-latency bus traffic between isolated processing units.
