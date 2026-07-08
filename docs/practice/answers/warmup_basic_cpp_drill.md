# Warm-Up Answer: Basic C++ Drill Questions

**Section:** Warm-Up: Basic C++ Before Core Systems

## Answer

## Section 1

1. ```cpp
   #include <iostream>

   int main() {
       std::cout << "Hello, C++\n";
       return 0;
   }
   ```

2. ```cpp
   #include <iostream>
   #include <string>

   int main() {
       std::string name;
       std::cin >> name;
       std::cout << "hello, " << name << '\n';
   }
   ```

3. ```cpp
   bool IsEven(int value) {
       return value % 2 == 0;
   }
   ```

4. ```cpp
   void Increment(int& value) {
       ++value;
   }
   ```

   The reference lets the function modify the caller's original integer.

## Section 2

5. ```cpp
   #include <string>

   std::string Greet(const std::string& name) {
       return "hello, " + name;
   }
   ```

6. ```cpp
   #include <fstream>
   #include <iostream>
   #include <string>

   void PrintFile(const std::string& path) {
       std::ifstream input(path);
       std::string line;
       while (std::getline(input, line)) {
           std::cout << line << '\n';
       }
   }
   ```

7. ```cpp
   class Counter {
   public:
       explicit Counter(int initial) : value_(initial) {}

       void Increment() { ++value_; }
       int Value() const { return value_; }

   private:
       int value_ = 0;
   };
   ```

8. ```cpp
   #include <iostream>

   int stack_value = 7;
   int* heap_value = new int(42);

   std::cout << stack_value << '\n';
   std::cout << *heap_value << '\n';

   delete heap_value;
   ```

   Stack objects are destroyed automatically when they leave scope. Prefer RAII for heap ownership because manual `delete` is easy to miss on early returns or exceptions.

9. ```cpp
   class Point {
   public:
       Point() : x_(0), y_(0) {}
       Point(int x, int y) : x_(x), y_(y) {}

       int x() const { return x_; }
       int y() const { return y_; }

   private:
       int x_ = 0;
       int y_ = 0;
   };
   ```

10. ```cpp
    class ScopedFlag {
    public:
        explicit ScopedFlag(bool& flag) : flag_(flag) {
            flag_ = true;
        }

        ~ScopedFlag() {
            flag_ = false;
        }

        ScopedFlag(const ScopedFlag&) = delete;
        ScopedFlag& operator=(const ScopedFlag&) = delete;

    private:
        bool& flag_;
    };
    ```

    The destructor resets the referenced flag when the object leaves scope, which is the RAII part of the exercise.

## Section 3

11. ```cpp
   class IntOwner {
   public:
       explicit IntOwner(int value) : value_(new int(value)) {}
       ~IntOwner() { delete value_; }

       IntOwner(const IntOwner& other) : value_(new int(*other.value_)) {}

       IntOwner& operator=(const IntOwner& other) {
           if (this != &other) {
               int* copy = new int(*other.value_);
               delete value_;
               value_ = copy;
           }
           return *this;
       }

   private:
       int* value_;
   };
   ```

12. ```cpp
   int Add(int lhs, int rhs) { return lhs + rhs; }
   double Add(double lhs, double rhs) { return lhs + rhs; }
   ```

13. ```cpp
   class Point {
   public:
       Point() = default;
       Point(int x, int y) : x_(x), y_(y) {}

       int x() const { return x_; }
       int y() const { return y_; }

   private:
       int x_ = 0;
       int y_ = 0;
   };

   Point operator+(Point lhs, Point rhs) {
       return Point(lhs.x() + rhs.x(), lhs.y() + rhs.y());
   }
   ```

14. ```cpp
   class Secret {
   public:
       explicit Secret(int value) : value_(value) {}
       friend int ReadSecret(const Secret& secret);

   private:
       int value_;
   };

   int ReadSecret(const Secret& secret) {
       return secret.value_;
   }
   ```

15. ```cpp
   class Shape {
   public:
       virtual ~Shape() = default;
   };

   class Circle : public Shape {};
   ```

## Section 4

16. ```cpp
   class Base {
   public:
       virtual ~Base() = default;
   };
   ```

   It allows deleting derived objects through a base pointer safely.

17. ```cpp
   class Shape {
   public:
       virtual ~Shape() = default;
       virtual double Area() const = 0;
   };
   ```

18. ```cpp
   class Rectangle : public Shape {
   public:
       Rectangle(double width, double height) : width_(width), height_(height) {}

       double Area() const override {
           return width_ * height_;
       }

   private:
       double width_;
       double height_;
   };
   ```

19. A virtual table is an implementation mechanism that lets calls to virtual functions dispatch to the correct derived implementation at runtime.

20. Multiple inheritance can create ambiguity when two base classes provide the same member, and diamond-shaped inheritance can complicate object layout.

## Section 5

21. ```cpp
   double value = 3.7;
   int truncated = static_cast<int>(value);
   ```

22. ```cpp
   Shape* shape = new Rectangle(2.0, 3.0);
   if (auto* rectangle = dynamic_cast<Rectangle*>(shape)) {
       (void)rectangle->Area();
   }
   delete shape;
   ```

23. ```cpp
   inline int Square(int value) {
       return value * value;
   }
   ```

24. ```cpp
   class InstanceCounter {
   public:
       InstanceCounter() { ++created_; }
       static int created() { return created_; }

   private:
       static int created_;
   };

   int InstanceCounter::created_ = 0;
   ```

## Section 6

25. ```cpp
   #include <stdexcept>

   int RequireNonNegative(int value) {
       if (value < 0) {
           throw std::invalid_argument("negative value");
       }
       return value;
   }
   ```

26. ```cpp
   #include <iostream>

   try {
       (void)RequireNonNegative(-1);
   } catch (const std::invalid_argument&) {
       std::cout << "error\n";
   }
   ```

27. ```cpp
   #include <vector>

   std::vector<int> values;
   values.push_back(1);
   values.push_back(2);
   values.push_back(3);

   int sum = 0;
   for (int value : values) {
       sum += value;
   }
   ```

28. ```cpp
   int sum = 0;
   for (auto it = values.begin(); it != values.end(); ++it) {
       sum += *it;
   }
   ```

## Section 7

29. ```cpp
   #include <map>
   #include <string>
   #include <vector>

   std::map<std::string, int> counts;
   for (const auto& word : std::vector<std::string>{"a", "b", "a"}) {
       ++counts[word];
   }
   ```

30. ```cpp
   #include <set>

   std::set<int> values{3, 1, 3, 2};
   ```

31. ```cpp
   #include <queue>

   std::queue<int> q;
   q.push(1);
   q.push(2);
   q.push(3);
   while (!q.empty()) {
       int value = q.front();
       q.pop();
       (void)value;
   }
   ```

32. ```cpp
   #include <stack>

   std::stack<int> s;
   s.push(1);
   s.push(2);
   s.push(3);
   while (!s.empty()) {
       int value = s.top();
       s.pop();
       (void)value;
   }
   ```

33. ```cpp
   #include <list>

   std::list<int> values{1, 2, 3};
   values.remove(2);
   ```

## Section 8

34. ```cpp
   template <typename T>
   T Max(T lhs, T rhs) {
       return lhs < rhs ? rhs : lhs;
   }
   ```

35. ```cpp
   #include <cstring>

   template <typename T>
   bool Less(T lhs, T rhs) {
       return lhs < rhs;
   }

   template <>
   bool Less<const char*>(const char* lhs, const char* rhs) {
       return std::strcmp(lhs, rhs) < 0;
   }
   ```

36. ```cpp
   #include <algorithm>
   #include <vector>

   std::vector<int> values{3, 1, 2};
   std::sort(values.begin(), values.end());
   ```

37. ```cpp
   auto it = std::find(values.begin(), values.end(), 2);
   bool found = it != values.end();
   ```

## Section 9

38. ```cpp
   auto it = values.begin();
   ```

39. ```cpp
   static_assert(sizeof(int) >= 4);
   ```

40. ```cpp
   class Base {
   public:
       Base() = default;
       Base(const Base&) = delete;
       virtual void Run() {}
       virtual ~Base() = default;
   };

   class Derived final : public Base {
   public:
       void Run() override {}
   };
   ```

41. ```cpp
   int* ptr = nullptr;
   ```

42. ```cpp
   #include <cstdint>

   enum class Status {
       Ok,
       Error
   };

   std::int32_t count = 0;
   ```

## Section 10

43. ```cpp
   #include <string>
   #include <unordered_map>

   std::unordered_map<std::string, int> scores{{"ada", 10}};
   int ada_score = scores["ada"];
   ```

44. ```cpp
   #include <unordered_set>

   std::unordered_set<int> seen;
   seen.insert(42);
   bool already_seen = seen.contains(42);
   ```

45. ```cpp
   #include <array>
   #include <iostream>

   for (int value : std::array<int, 3>{10, 20, 30}) {
       std::cout << value << '\n';
   }
   ```

46. ```cpp
   #include <memory>

   auto value = std::make_unique<int>(42);
   ```

## Section 11

47. ```cpp
   #include <memory>

   auto first = std::make_shared<int>(42);
   std::shared_ptr<int> second = first;
   ```

48. ```cpp
   std::weak_ptr<int> weak = first;
   if (auto locked = weak.lock()) {
       (void)*locked;
   }
   ```

49-50. ```cpp
   class MovableInt {
   public:
       explicit MovableInt(int value) : value_(new int(value)) {}
       ~MovableInt() { delete value_; }

       MovableInt(const MovableInt&) = delete;
       MovableInt& operator=(const MovableInt&) = delete;

       MovableInt(MovableInt&& other) noexcept : value_(other.value_) {
           other.value_ = nullptr;
       }

       MovableInt& operator=(MovableInt&& other) noexcept {
           if (this != &other) {
               delete value_;
               value_ = other.value_;
               other.value_ = nullptr;
           }
           return *this;
       }

   private:
       int* value_;
   };
   ```

## Section 12

51. ```cpp
   constexpr int Square(int value) noexcept {
       return value * value;
   }
   ```

52. ```cpp
   #include <algorithm>
   #include <iterator>
   #include <vector>

   std::vector<int> values{1, 2, 3, 4};
   std::vector<int> evens;
   std::copy_if(values.begin(), values.end(), std::back_inserter(evens),
                [](int value) { return value % 2 == 0; });
   ```

53. ```cpp
   #include <cstddef>

   template <typename... Args>
   constexpr std::size_t CountArgs(Args&&...) {
       return sizeof...(Args);
   }
   ```

## Section 13

54. ```cpp
   #include <filesystem>

   bool exists = std::filesystem::exists("README.md");
   ```

55. Modules are meant to provide clearer import boundaries and reduce some costs and fragility of textual `#include` processing.

56. ```cpp
   #include <iostream>
   #include <thread>

   std::thread worker([] {
       std::cout << "worker\n";
   });
   worker.join();
   ```

57. ```cpp
   #include <mutex>

   std::mutex mutex;
   int counter = 0;

   {
       std::lock_guard<std::mutex> lock(mutex);
       ++counter;
   }
   ```

58. A `std::condition_variable` lets one thread sleep until another thread signals that shared state has changed, usually while coordinating through a mutex.
