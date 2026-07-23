# Month 3: Tensor Compilers, IR Lowering, and Graph Optimization

## Focus

Study how high-level neural network graphs are compiled into hardware-optimized execution instructions through intermediate representations and deterministic graph transformations.

## Core Ecosystems

- Torch-MLIR.
- XLA.
- StableHLO.
- Linalg IR.

## Core Outcomes

- Understand the role of intermediate representations in model compilation.
- Write deterministic graph rewrite passes.
- Recognize optimization opportunities before backend lowering.
- Map dynamic model dimensions into static compiler structures safely.

## Key Topics

Graph optimization:

- Dead code elimination.
- Constant propagation.
- Operator fusion.
- Shape simplification.
- Redundant node removal.

IR lowering:

- Translating high-level tensor operations into lower-level IR.
- Preserving semantics through each lowering stage.
- Making memory layout decisions explicit before backend code generation.

Dynamic-to-static conversion:

- Bounding dynamic dimensions.
- Specializing common shapes.
- Guarding unsafe assumptions.
- Producing fallback paths when static specialization does not apply.

## Suggested Exercises

- Build a small graph representation with nodes, tensors, and edges.
- Implement constant folding for a simple arithmetic graph.
- Implement dead code elimination from marked outputs.
- Add a mock lowering pass from graph ops to a simpler instruction list.

## Validation Checklist

- Graph rewrites preserve observable outputs.
- Pass ordering is documented.
- Dynamic shape assumptions are explicit.
- Lowered instructions retain enough metadata for debugging.
