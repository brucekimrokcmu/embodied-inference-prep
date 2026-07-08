cmake_minimum_required(VERSION 3.16)

project(embodied_inference_prep LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

enable_testing()

add_library(q0_example INTERFACE)
target_include_directories(q0_example INTERFACE
    ${CMAKE_CURRENT_SOURCE_DIR}/src/month0_core_cpp/include
)

add_subdirectory(tests)
