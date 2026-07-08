# Q3 Hint: Systems Theory: Exception Safety and Move Semantics

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Hint

**Exception Safety & Move:** Consider what happens when an allocation fails or an adjustment triggers a resize sequence. If a custom move constructor throws an exception midway through shifting elements, restoring the original state becomes impossible unless the move is explicitly guaranteed to be exception-free via noexcept.
