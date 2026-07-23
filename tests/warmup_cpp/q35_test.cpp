#include <cassert>

int main() {
    assert(Less(1, 2));
    assert(!Less(2, 1));
    assert(Less("ada", "grace"));
    assert(!Less("grace", "ada"));
}
