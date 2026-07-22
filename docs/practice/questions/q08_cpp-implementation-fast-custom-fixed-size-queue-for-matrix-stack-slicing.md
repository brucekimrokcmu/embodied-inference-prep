# Q8: C++ Implementation: Fast Custom Fixed-Size Queue for Matrix Stack Slicing

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Question

Implement a stack-allocated, fixed-size priority structure in C++ to sort and track the top-K highest confidence target classifications parsed during robot path estimation. It must contain zero pointers, store all internal metadata inline, and operate without utilizing standard library container overheads.

## Runtime Engineer Framing

Make this a bounded top-K container for a hot inference path. The user-space concern is predictable memory and branch/simple-loop behavior, not avoiding the STL for its own sake. Explain capacity, insertion cost, and what happens when a new score does not enter the top K.
