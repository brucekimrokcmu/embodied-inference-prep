// Create one int on the stack and one int on the heap with new; 
// print both, release the heap value with delete, 
// and explain why manual heap ownership should usually be replaced by RAII.

#include <iostream>


int main() {

    int stk_val = 10;
    int* heap_val = new int(12);

    std::cout << stk_val << std::endl;
    std::cout << *heap_val << std::endl;

    delete heap_val;

    return 0;
}

