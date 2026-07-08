# Month 4: Model Compression, Quantization, and Hardware-Aware Distillation

## Focus

Reduce model size and execution cost while preserving accuracy and fitting hardware-specific execution units, memory layouts, and bandwidth constraints.

## Core Outcomes

- Understand precision scaling for FP8 and INT4 execution.
- Compare outlier-preserving quantization methods.
- Relate quantized weight layouts to NPU memory alignment.
- Apply pruning and distillation as structural compression tools.

## Quantization

Key areas:

- FP8 precision boundaries.
- INT4 precision boundaries.
- SmoothQuant.
- Activation-aware Weight Quantization.
- Outlier preservation.

Design notes:

- Quantization must account for both weights and activation distributions.
- Outliers can dominate error if they are not isolated or rescaled.
- Hardware layout constraints can determine whether a theoretically good format is practical.

## Hardware-Aware Layout

Key areas:

- Matching quantized weights to NPU memory layout.
- Alignment requirements.
- Packed integer formats.
- Tile sizes and channel grouping.

Suggested exercises:

- Define a packed INT4 weight layout.
- Write a small unpacking routine for reference validation.
- Document how channel count affects alignment and padding.

## Pruning and Distillation

Key areas:

- Structural channel-level pruning.
- Edge-native student models.
- Knowledge distillation from larger models.
- Task-specific compression for focused deployment.

Design notes:

- Channel pruning is easier to accelerate than unstructured sparsity on many edge devices.
- Student models should be designed around target hardware limits, not just copied from server-side architectures.
- Accuracy validation must be tied to the actual deployment task.

## Validation Checklist

- Quantization assumptions are documented by tensor type.
- Packed layout rules include padding and alignment behavior.
- Compression strategy separates numerical precision, architecture size, and hardware layout.
- Distillation goals are tied to measurable deployment tasks.
