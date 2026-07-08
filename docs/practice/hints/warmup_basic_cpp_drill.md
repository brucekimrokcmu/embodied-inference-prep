# Warm-Up Hint: Basic C++ Drill Questions

**Section:** Warm-Up: Basic C++ Before Core Systems

## Hint

Use these rules of thumb while working through the drill:

- Start with the simplest compiling program: include the header you use, write the smallest function or class, and keep `main` boring.
- Prefer `const&` for read-only parameters and non-const `&` only when the function intentionally modifies the caller's object.
- Treat raw `new` and `delete` as a learning exercise. In real code, prefer RAII types such as `std::vector`, `std::string`, `std::unique_ptr`, and standard library containers.
- If a class owns raw memory, think about the rule of five: destructor, copy constructor, copy assignment, move constructor, and move assignment.
- Use `override` on virtual function overrides and give polymorphic base classes virtual destructors.
- Use `static_cast` for clear compile-time conversions and `dynamic_cast` only for checked casts through polymorphic base classes.
- Reach for STL containers based on access pattern: `vector` for contiguous sequences, `map`/`unordered_map` for key lookup, `set`/`unordered_set` for uniqueness, `queue` for FIFO, and `stack` for LIFO.
- Use algorithms such as `std::sort`, `std::find`, and lambdas before writing manual loops for common operations.
- In threaded code, protect shared mutable state with a mutex and use condition variables to wait for state changes without busy-waiting.
