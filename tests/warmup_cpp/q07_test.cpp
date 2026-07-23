#include <cassert>

int main() {
    Counter counter(10);
    assert(counter.Value() == 10);
    counter.Increment();
    assert(counter.Value() == 11);

    const Counter const_counter(3);
    assert(const_counter.Value() == 3);
}
