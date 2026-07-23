#include <cassert>
#include <cmath>

int main() {
    assert(Add(2, 3) == 5);
    assert(std::abs(Add(1.5, 2.25) - 3.75) < 1e-9);
}
