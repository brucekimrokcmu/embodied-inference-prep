<!-- Personal practice copy. Source: docs/practice/questions/warmup_basic_cpp_drill.md -->

# Warm-Up: Basic C++ Drill Questions

**Section:** Warm-Up: Basic C++ Before Core Systems

## Question

Work through these drills before starting the Month 0 core systems questions. The goal is not deep mastery yet; it is to refresh core C++ vocabulary, syntax, ownership, and standard library habits.

## Section 1: First Programs, I/O, Booleans, References

1. Write a minimal `main` that prints `Hello, C++` and returns `0`.
2. Read a user's name from `std::cin` and print `hello, <name>`.
3. Write a function `IsEven(int value)` that returns `bool`.
4. Write a function `Increment(int& value)` and explain why it uses a reference.

## Section 2: Strings, Files, Classes, Stack/Heap, Constructors, Const

5. Write a function that takes `const std::string& name` and returns `"hello, " + name`.
6. Open a text file with `std::ifstream` and print each line.
7. Define a `Counter` class using Google-style class layout: public API first, private data members last, and a trailing underscore for private data members. Include a constructor, initializer list, `Increment()`, and `int Value() const`; the validator calls `Value()` on a `const Counter`.
8. Create one `int` on the stack and one `int` on the heap with `new`; print both, release the heap value with `delete`, and explain why manual heap ownership should usually be replaced by RAII.
9. Add two overloaded constructors to a `Point` class using Google-style class layout: a default constructor and one that accepts `x` and `y`. Keep data private and expose `int x() const` and `int y() const` accessors.
10. Write a Google-style RAII class `ScopedFlag` that stores a `bool&`, sets it to `true` in the constructor, and resets it to `false` in the destructor. Delete copy construction and copy assignment.

## Section 3: Copying, Overloading, Operators, Friend, Inheritance

11. Write a copy constructor for a simple class that owns an `int*`. Use Google-style class layout and avoid public data members.
12. Write two overloaded `Add` functions: one for `int`, one for `double`.
13. Overload `operator+` for a small `Point` class with private `x_` and `y_` members plus `int x() const` and `int y() const` accessors.
14. Show a small example where a `friend` function can read a private field in a Google-style class.
15. Create a base class `Shape` and derived class `Circle` using public inheritance and a virtual base destructor.

## Section 4: Polymorphism, Abstract Classes, Interfaces

16. Add a virtual destructor to a base class and explain why it matters.
17. Write an abstract class, also called an interface-style class in C++, with a virtual destructor and a pure virtual function `Area() const`.
18. Override `Area() const` in a derived `Rectangle` class using `override`, a `Rectangle(double width, double height)` constructor, private dimensions, and trailing underscores for private data members.
19. Explain what a virtual table is at a high level.
20. Explain one risk of multiple inheritance.

## Section 5: Casting, Inline, Static Members

21. Show one example of `static_cast`.
22. Show one example where `dynamic_cast` is appropriate.
23. Write an `inline` function `Square(int)`.
24. Add a static member variable that counts how many objects of a class have been created. Keep the class layout public-before-private and use a trailing underscore for private/static data members.

## Section 6: Exceptions, Vectors, Iterators

25. Write a function that throws `std::invalid_argument` when given a negative input.
26. Catch the exception from the previous function and print `error`.
27. Append values to a `std::vector<int>` and sum them with a range-based `for` loop.
28. Sum the same vector with explicit iterators.

## Section 7: Map, Set, Queue, Stack, List

29. Use `std::map<std::string, int>` to count how often words appear.
30. Use `std::set<int>` to keep unique sorted values.
31. Push three integers into a `std::queue<int>` and pop them in FIFO order.
32. Push three integers into a `std::stack<int>` and pop them in LIFO order.
33. Insert values into a `std::list<int>` and remove one value.

## Section 8: Templates, Specialization, Algorithms

34. Write a function template `Max(a, b)`.
35. Specialize a template function for `const char*` comparison.
36. Use `std::sort` on a `std::vector<int>`.
37. Use `std::find` to check whether a vector contains a value.

## Section 9: Modern Keywords and Types

38. Use `auto` to store the result of `values.begin()`.
39. Write a `static_assert` that checks `sizeof(int) >= 4`.
40. Show one use each of `default`, `delete`, `override`, and `final`.
41. Replace a raw null pointer literal with `nullptr`.
42. Define an `enum class Status` and a fixed-width integer variable.

## Section 10: Modern Containers, Range Loops, Unique Ownership

43. Use `std::unordered_map<std::string, int>` for lookup by name.
44. Use `std::unordered_set<int>` to track seen IDs.
45. Print all values in `std::array<int, 3>{10, 20, 30}` with a range-based `for`.
46. Create a `std::unique_ptr<int>` with `std::make_unique`.

## Section 11: Shared/Weak Ownership and Move Semantics

47. Create a `std::shared_ptr<int>` and copy it to another owner.
48. Create a `std::weak_ptr<int>` from a `shared_ptr` and safely lock it.
49. Write a move constructor for a class that owns an `int*`. Use Google-style class layout and delete copy operations.
50. Write a move assignment operator for the same class.

## Section 12: Constexpr, Lambdas, Variadic Templates

51. Write a `constexpr` function named `Square`.
52. Use a lambda to filter even numbers from a vector.
53. Write a variadic template function that returns the number of arguments passed to it.

## Section 13: Filesystem, Modules, Threads, Mutexes, Condition Variables

54. Use `std::filesystem::exists` to check whether a path exists.
55. Explain, at a high level, what C++ modules are meant to improve compared with headers.
56. Start a `std::thread` that prints a message, then `join` it.
57. Protect a shared counter with `std::mutex`.
58. Explain what a `std::condition_variable` is used for.

## My Answer

_Write your answer here._

## My Comments

- 
