#include "q0_example.h"

#include <cassert>

int main() {
    using embodied::practice::AddForBuildValidation;

    static_assert(AddForBuildValidation(2, 3) == 5);
    assert(AddForBuildValidation(0, 0) == 0);
    assert(AddForBuildValidation(-4, 10) == 6);

    return 0;
}
