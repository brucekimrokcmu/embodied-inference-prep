#include <cassert>

int main() {
    static_assert(Square(6) == 36);
    assert(Square(-3) == 9);
}
