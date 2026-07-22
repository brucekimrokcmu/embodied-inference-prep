# Q10 Answer: DeepMind Case Study: Real-Time Coordinate Graph Dependency Tracker

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Answer

A runtime-oriented transform graph should be built once and queried cheaply. At initialization, map frame names to integer IDs, validate that the graph is a tree or DAG as expected, and store parent links, edge transforms, and depth/topological metadata in contiguous arrays.

For repeated queries, precompute common paths or use a bounded scratch buffer to climb from each node to a common ancestor. The hot path should operate on IDs and array indices, not strings or heap-allocated graph nodes. If topology is static, paths can be cached as fixed arrays of edge IDs.

The practical benefits are predictable allocation, cache-friendly traversal, and clear invalidation rules. If calibration changes an edge transform but not topology, update the transform value without rebuilding the whole graph. If topology changes, rebuild the precomputed metadata outside the control loop.

```cpp
#include <vector>
#include <string>

struct RigidTransformationNode {
    int parent_index; // Value -1 signifies the base root coordinate frame
    double matrix_data[16]; // Flat Row-Major 4x4 Transformation Matrix representation
};

class KinematicTopologyGraph {
public:
    void RegisterNode(int parent_idx, const double initial_matrix[16]) {
        RigidTransformationNode new_node;
        new_node.parent_index = parent_idx;
        for (int i = 0; i < 16; ++i) new_node.matrix_data[i] = initial_matrix[i];
        nodes_pool_.push_back(new_node);
    }

    // Evaluates coordinate changes sequentially along a pre-allocated flat array, bypassing tree pointer walks
    void ComputeGlobalTransforms(std::vector<double>& resolved_matrices) {
        resolved_matrices.resize(nodes_pool_.size() * 16);
        for (size_t i = 0; i < nodes_pool_.size(); ++i) {
            if (nodes_pool_[i].parent_index == -1) {
                // Root node copies internal transformation layout directly
                for (int k = 0; k < 16; ++k) resolved_matrices[i * 16 + k] = nodes_pool_[i].matrix_data[k];
            } else {
                MultiplyMatrices(
                    &resolved_matrices[nodes_pool_[i].parent_index * 16],
                    nodes_pool_[i].matrix_data,
                    &resolved_matrices[i * 16]
                );
            }
        }
    }

private:
    void MultiplyMatrices(const double* parent, const double* local, double* destination) {
        for (int r = 0; r < 4; ++r) {
            for (int c = 0; c < 4; ++c) {
                destination[r * 4 + c] = 0.0;
                for (int k = 0; k < 4; ++k) {
                    destination[r * 4 + c] += parent[r * 4 + k] * local[k * 4 + c];
                }
            }
        }
    }
    std::vector<RigidTransformationNode> nodes_pool_;
};

```
