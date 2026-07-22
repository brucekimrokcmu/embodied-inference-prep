# Q5 Hint: C++ Implementation: Lock-Free Single-Producer Single-Consumer (SPSC) Ring Buffer

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Hint

For SPSC, do not design an MPMC queue. The producer is the only writer of `head`, and the consumer is the only writer of `tail`. Each side reads the other index to detect full or empty states. Use acquire when observing the other side's published index and release when publishing your own updated index.

Pad or align frequently written indices so producer and consumer do not bounce the same cache line.

**SPSC Ring Buffer:** Use two independent, monotonically increasing atomic indices (head and tail). Ensure you isolate them into separate cache areas via padding to completely prevent false sharing between your producer and consumer threads.
