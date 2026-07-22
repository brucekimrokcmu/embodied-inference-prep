# Q12: Systems Theory: LiteRT Graph Traversal and Node Lifecycles

**Section:** Month 1: LiteRT & LiteRT-LM Framework Internals (Core, Dispatch, & Trade-offs)

## Question

Walk through the exact internal lifecycle phases of a LiteRT node (LiteRtSubgraph) across the four main stages: Init, Prepare, Invoke, and Free. Detail precisely what operational steps occur in Prepare regarding tensor dimension resolution and memory offset allocation.

## Runtime Engineer Framing

Answer in terms of the lifecycle any model runtime needs: create resources, plan shapes and buffers, execute repeatedly, then release resources. You do not need private LiteRT internals to explain why `Prepare` should do planning work outside the hot `Invoke` path.
