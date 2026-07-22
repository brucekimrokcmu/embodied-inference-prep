# Q15: C++ Implementation: Custom Operator Core Registration Pipeline

**Section:** Month 1: LiteRT & LiteRT-LM Framework Internals (Core, Dispatch, & Trade-offs)

## Question

Write a minimal C++ compilation block that mocks the registration and instantiation of a custom activation kernel into a LiteRT framework runtime. Implement an implementation matching the unified litert::CustomOpKernel abstract interface, including structured lifecycle wrappers (Init, GetOutputLayouts, Run, and Destroy).

## Runtime Engineer Framing

Treat the custom op as a plugin boundary. The goal is to show how a runtime discovers an op, validates shapes/types, allocates or receives buffers, executes without hidden allocation in the hot path, and cleans up owned state.
