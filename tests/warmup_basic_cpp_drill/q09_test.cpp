#include <cassert>

int main() {
    Point origin;
    assert(origin.x() == 0);
    assert(origin.y() == 0);

    Point point(3, 4);
    assert(point.x() == 3);
    assert(point.y() == 4);
}
