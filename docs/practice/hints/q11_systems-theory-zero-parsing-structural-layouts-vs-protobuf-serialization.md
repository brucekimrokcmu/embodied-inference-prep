# Q11 Hint: Systems Theory: Zero-Parsing Structural Layouts vs. Protobuf Serialization

**Section:** Month 1: LiteRT & LiteRT-LM Framework Internals (Core, Dispatch, & Trade-offs)

## Hint

Think about `mmap`, pointer-like table access, allocation count, and cold-start path length. A runtime engineer cares about how much work happens before the first inference: validation, metadata lookup, tensor planning, and whether model structures are copied into new objects.

**FlatBuffers vs. Protobuf:** Remember that FlatBuffers store data layouts in a binary format that matches memory-mapped execution requirements perfectly, removing the need to parse, read, and reconstruct objects into a secondary memory tree.
