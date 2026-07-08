#include <cassert>
#include <stdexcept>

int main() {
    assert(RequireNonNegative(0) == 0);
    assert(RequireNonNegative(4) == 4);

    bool threw = false;
    try {
        (void)RequireNonNegative(-1);
    } catch (const std::invalid_argument&) {
        threw = true;
    }
    assert(threw);
}
