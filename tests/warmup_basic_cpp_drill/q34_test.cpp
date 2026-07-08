#include <cassert>
#include <string>

int main() {
    assert(Max(2, 5) == 5);
    assert(Max(-1, -3) == -1);
    assert(Max(std::string("ada"), std::string("grace")) == "grace");
}
