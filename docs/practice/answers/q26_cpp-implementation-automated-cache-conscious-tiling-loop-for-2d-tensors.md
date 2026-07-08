# Q26 Answer: C++ Implementation: Automated Cache-Conscious Tiling Loop for 2D Tensors

**Section:** Month 2: Edge Framework Resource Utilization, Stability, & Power

## Answer

```cpp
#include <vector>
#include <cstddef>

void ComputeCacheConsciousMatrixAdd(const float* A, const float* B, float* C, size_t rows, size_t cols) {
    // Configure tile sizes so sub-matrices fit entirely within standard 32KB L2 cache lines
    constexpr size_t TileRows = 64;
    constexpr size_t TileCols = 64;

    for (size_t r_tile = 0; r_tile < rows; r_tile += TileRows) {
        for (size_t c_tile = 0; c_tile < cols; c_tile += TileCols) {
            // Internal execution loops process elements using cache-friendly directions
            for (size_t r = r_tile; r < std::min(r_tile + TileRows, rows); ++r) {
                for (size_t c = c_tile; c < std::min(c_tile + TileCols, cols); ++c) {
                    size_t idx = r * cols + c;
                    C[idx] = A[idx] + B[idx]; // Modern compilers vectorize this inner loop automatically
                }
            }
        }
    }
}

```
