#include <cassert>

int main() {
    static_assert(CountArgs() == 0);
    static_assert(CountArgs(1, 2, 3) == 3);
    assert(CountArgs("a", 2, 3.0, true) == 4);
}
