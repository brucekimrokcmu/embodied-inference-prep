# Q10 Hint: DeepMind Case Study: Real-Time Coordinate Graph Dependency Tracker

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Hint

Separate build time from run time. During initialization, validate the graph, assign integer node IDs, compute parents/depths or topological order, and cache common paths. During inference, avoid parsing strings, allocating vectors, or walking arbitrary containers.

**Coordinate Graph:** Use a flat std::vector layout where child nodes link explicitly back to their parents via integer indexes instead of raw pointers, ensuring excellent memory cache locality during iterations.
