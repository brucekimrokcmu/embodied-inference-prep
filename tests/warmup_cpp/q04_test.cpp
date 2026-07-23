#include <cassert>

int main() {
    int value = 41;
    Increment(value);
    assert(value == 42);
}
