# Q14 Answer: Systems Theory: Framework Architecture Trade-offs (LiteRT vs. ExecuTorch)

**Section:** Month 1: LiteRT & LiteRT-LM Framework Internals (Core, Dispatch, & Trade-offs)

## Answer

LiteRT: Employs an adaptable, multi-layered architecture featuring an internal memory allocation engine that handles dynamic fallback execution paths. If a target NPU accelerator cannot evaluate a specific tensor layer due to an unmapped runtime condition, LiteRT catches the exception and routes the workload back to optimized CPU references (e.g., via XNNPACK). This architecture natively supports dynamic input shapes, but introduces slight runtime validation overhead and pointer indirection.
ExecuTorch: Enforces a highly rigid, deterministic execution strategy designed for deeply embedded systems. It computes a fixed, zero-dynamic-allocation memory map ahead of time during an offline compilation step. This memory map bakes raw pointer offsets directly into a static program configuration schema. While this approach minimizes framework overhead and ensures exceptional predictability on microcontrollers, it makes handling dynamic token lengths or runtime structural changes highly difficult, requiring the memory planner to always allocate buffers matching the absolute worst-case sequence dimensions.
