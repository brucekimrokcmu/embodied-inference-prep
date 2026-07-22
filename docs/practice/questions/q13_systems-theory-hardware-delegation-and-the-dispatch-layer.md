# Q13: Systems Theory: Hardware Delegation and the Dispatch Layer

**Section:** Month 1: LiteRT & LiteRT-LM Framework Internals (Core, Dispatch, & Trade-offs)

## Question

Explain the structural operation of the LiteRT Dispatch API and DispatchDelegate. How does the runtime decouple standard framework operations from third-party vendor NPUs without demanding hardcoded compile-time dependencies or manual operator re-registrations?

## Runtime Engineer Framing

Explain hardware delegation as a runtime boundary: the model runtime owns graph semantics and tensor lifetimes, while a backend or delegate owns execution for supported subgraphs. Focus on capability discovery, partitioning, fallback, and buffer ownership rather than vendor-specific driver internals.
