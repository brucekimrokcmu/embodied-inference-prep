#include <cassert>

int main() {
    assert(IsEven(0));
    assert(IsEven(2));
    assert(!IsEven(3));
    assert(!IsEven(-1));
}
