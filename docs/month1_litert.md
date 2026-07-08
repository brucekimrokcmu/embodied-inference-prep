# Month 1: LiteRT and LiteRT-LM Framework Internals

## Focus

Study Google's next-generation edge execution framework internals, especially the Core and Dispatch layers, and compare their design choices against Meta's ExecuTorch.

## Core Outcomes

- Understand how model serialization affects runtime startup cost.
- Trace tensor and node lifecycles through initialization, preparation, invocation, and teardown.
- Explain how LiteRT delegates work to CPU, GPU, and NPU backends.
- Compare dynamic runtime flexibility with ahead-of-time embedded execution planning.
- Prototype small dispatch and custom-op experiments.

## Core Framework and Serialization Architecture

Key areas:

- FlatBuffers-based model storage and loading.
- Zero-parsing or low-overhead model initialization.
- Internal graph representations such as `LiteRtSubgraph`.
- Tensor and node lifecycle management across runtime phases.

Runtime lifecycle:

1. Load serialized model representation.
2. Initialize graph, tensors, and nodes.
3. Prepare memory and backend execution plans.
4. Invoke computation.
5. Tear down resources deterministically.

Implementation targets:

- `src/month1_runtime/custom_op/fused_relu.cpp`
- `tests/month1_tests/test_custom_op.cpp`

Suggested exercises:

- Implement a mock fused ReLU operation.
- Represent a small tensor metadata structure.
- Add tests for shape handling and element-wise output correctness.

## Dispatch Layer

Key areas:

- LiteRT Dispatch API orchestration.
- Routing workloads across CPU, GPU, and NPU backends.
- Automated hardware delegate selection.
- Fallback behavior when a backend cannot support an operation.

Implementation target:

- `src/month1_runtime/speculative_decoding/token_dispatcher.cpp`

Suggested exercises:

- Build a small mock dispatcher that selects between fake CPU/GPU/NPU backends.
- Track backend selection decisions.
- Add fallback behavior for unsupported operations.
- Keep dispatch results opaque behind a C-style API boundary.

## LiteRT-LM Extensions

Key areas:

- Multi-Token Prediction.
- Speculative decoding.
- Hardware-level memory locality.
- Keeping draft and primary models on the same hardware IP.
- Avoiding cross-accelerator synchronization stalls.

Design notes:

- Speculative decoding is not only an algorithmic optimization; it is also a memory-placement and scheduling problem.
- The draft model and verification model should avoid unnecessary accelerator boundary crossings.
- KV-cache locality is a first-order performance concern for repeated decoding workloads.

## Validation Checklist

- Custom-op behavior is tested independently of backend dispatch.
- Dispatch logic exposes deterministic backend selection.
- Unsupported backend paths are represented and tested.
- Notes clearly separate LiteRT Core, Dispatch, and LiteRT-LM concerns.
