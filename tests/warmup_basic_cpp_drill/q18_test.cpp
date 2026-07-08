#include <cassert>
#include <cmath>

int main() {
    Rectangle rectangle(3.0, 4.0);
    assert(std::abs(rectangle.Area() - 12.0) < 1e-9);
}
