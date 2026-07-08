# Q19 Answer: DeepMind Case Study: Speculative Decoding Memory Locality System

**Section:** Month 1: LiteRT & LiteRT-LM Framework Internals (Core, Dispatch, & Trade-offs)

## Answer

To avoid high-latency PCIe/system bus transfers between distinct hardware units, you must design a unified memory architecture using a shared memory pool managed via a hardware-abstracted runtime layer.
+-----------------------------------------------------------------------+
|                       Unified System Memory Pool                      |
|                                                                       |
|  +--------------------+                     +----------------------+  |
|  | Draft Model Tokens | ------------------> | Primary Model Inputs |  |
|  |   (Pinned Pages)   | Zero-Copy Reference |    (Pinned Pages)    |  |
|  +--------------------+                     +----------------------+  |
+-----------------------------------------------------------------------+
           |                                              |
           v                                              v
+-----------------------+                      +------------------------+
|      Edge CPU Core    |                      |      On-Device NPU     |
+-----------------------+                      +------------------------+

By mapping both the 1B draft model and the 8B primary model into a single unified memory space, token generation outputs from the draft model can be passed directly to the primary model as input references. This zero-copy approach bypasses host-to-device memory transfers entirely, keeping synchronization costs inside local cache lines and eliminating bus bottleneck delays.
