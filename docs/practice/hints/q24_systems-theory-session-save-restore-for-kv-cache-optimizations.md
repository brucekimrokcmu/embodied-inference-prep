# Q24 Hint: Systems Theory: Session Save/Restore for KV-Cache Optimizations

**Section:** Month 2: Edge Framework Resource Utilization, Stability, & Power

## Hint

**KV-Cache Save/Restore:** The prefill stage processes text blocks by computing attention matrix keys and values. Saving these matrices allows a subsequent turn to skip reprocessing past tokens, changing a slow matrix computation into a fast lookup.
