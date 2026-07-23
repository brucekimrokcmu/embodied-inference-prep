cmake_minimum_required(VERSION 3.16)

project(embodied_inference_prep LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

enable_testing()

add_custom_target(workspace_smoke
    COMMAND ${CMAKE_COMMAND} -E echo "embodied_inference_prep configured"
)

add_test(
    NAME workspace_smoke
    COMMAND ${CMAKE_COMMAND} -E echo "embodied_inference_prep configured"
)
