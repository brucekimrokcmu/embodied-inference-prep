#include <cassert>

int main() {
    Point lhs{1, 2};
    Point rhs{3, 4};
    Point sum = lhs + rhs;
    assert(sum.x() == 4);
    assert(sum.y() == 6);
}
