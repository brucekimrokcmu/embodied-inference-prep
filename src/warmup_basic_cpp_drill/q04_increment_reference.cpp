// Write a function Increment(int& value) and explain why it uses a reference.
void Increment(int& value) {
    value++;
}

// using a reference modifies the original variable. It avoids pass by value, 
// meaning it avoids copying the data