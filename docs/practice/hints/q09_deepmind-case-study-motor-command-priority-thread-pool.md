# Q9 Hint: DeepMind Case Study: Motor Command Priority Thread Pool

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Hint

Do not put 1 kHz control tasks and irregular ML tasks into one FIFO. Separate execution lanes, queues, priorities, and memory pools. The control lane should have bounded work and minimal blocking. Low-priority inference can be dropped, delayed, or rate-limited.

**Priority Thread Pool:** Consider using a synchronized priority queue containing independent work tasks. The real-time threads should sleep on a condition variable and wake instantly only when high-priority tasks arrive, while long-duration tasks are kept behind until critical paths clear.
