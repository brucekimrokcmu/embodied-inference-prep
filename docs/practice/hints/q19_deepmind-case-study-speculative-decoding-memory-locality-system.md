# Q19 Hint: DeepMind Case Study: Speculative Decoding Memory Locality System

**Section:** Month 1: LiteRT & LiteRT-LM Framework Internals (Core, Dispatch, & Trade-offs)

## Hint

**Speculative Memory Locality:** Think about unified memory architectures or shared allocation pools across devices. Keeping the candidate verification vectors on a single shared memory plane avoids high-latency bus traffic between isolated processing units.
