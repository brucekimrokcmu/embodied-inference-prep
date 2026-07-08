# Architecture Studies

## Scope

This document collects comparison notes across the plan, with emphasis on runtime architecture, memory planning, dispatch behavior, and edge-device execution trade-offs.

## LiteRT vs. ExecuTorch

| Area | LiteRT | ExecuTorch |
| --- | --- | --- |
| Primary design center | Flexible on-device runtime execution | Ahead-of-time execution for deeply embedded targets |
| Allocation model | Unified runtime allocator | Zero-dynamic-allocation memory plan |
| Backend behavior | Dynamic multi-backend fallback | Program schema tailored to selected deployment target |
| Shape behavior | Supports dynamic shape updates | Favors static planning and localized offsets |
| API surface | Standard C API with opaque execution results | Customized ahead-of-time program representation |
| Tensor memory | Runtime-managed tensor and node lifecycles | Tensor pointers and offsets baked into the program plan |

## LiteRT Architectural Notes

Strengths:

- Unified runtime allocator simplifies backend interoperability.
- Dynamic shape support improves flexibility for varied inputs.
- Multi-backend fallback can increase deployment coverage across CPU, GPU, and NPU.
- Opaque C API boundaries help separate application code from backend details.

Risks:

- Runtime flexibility can add allocator and dispatch complexity.
- Backend fallback may make latency harder to predict unless decisions are traced.
- Dynamic behavior requires strong testing around shape updates and memory reuse.

Best fit:

- Devices where hardware capabilities vary.
- Applications needing flexible model loading or backend fallback.
- Systems where runtime adaptability matters more than fully static execution.

## ExecuTorch Architectural Notes

Strengths:

- Zero-dynamic-allocation plans support deterministic embedded execution.
- Ahead-of-time schemas reduce runtime decision-making.
- Localized tensor offsets make memory behavior easier to inspect.
- Strong fit for constrained devices with fixed model and input contracts.

Risks:

- Less flexible when shapes, backends, or model structure vary.
- More burden shifts into the export and compile pipeline.
- Deployment changes may require regenerating program plans.

Best fit:

- Deeply embedded systems.
- Fixed-shape or highly constrained deployments.
- Applications where deterministic memory use is more important than runtime flexibility.

## Cross-Cutting Edge Runtime Trade-Offs

Memory:

- Dynamic allocation improves flexibility but can introduce fragmentation and latency variance.
- Static memory plans improve determinism but require stronger compile-time assumptions.
- Zero-copy memory reduces bandwidth pressure but increases ownership and synchronization complexity.

Dispatch:

- Runtime dispatch can improve portability and fallback.
- Static dispatch can improve predictability.
- Hardware locality matters for multi-model workloads such as speculative decoding.

Power:

- Data movement is often more expensive than arithmetic.
- Operator fusion and tiling reduce intermediate memory traffic.
- Thermal throttling can convert short-term performance gains into long-term instability.

Compiler pipeline:

- Graph rewrites and IR lowering should make memory and shape assumptions visible.
- Quantization and layout decisions must match hardware execution units.
- Compression should be validated against deployment tasks rather than abstract model metrics alone.

Robotics:

- Real-time control loops should remain isolated from heavyweight inference.
- Bounded queues and explicit ownership rules are preferable to shared blocking paths.
- Priority inversion risks should be reviewed wherever control and inference share resources.
