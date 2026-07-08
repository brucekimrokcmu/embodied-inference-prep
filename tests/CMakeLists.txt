add_executable(q0_example_test
    month0_tests/test_q0_example.cpp
)

target_link_libraries(q0_example_test PRIVATE q0_example)

add_test(NAME q0_example_test COMMAND q0_example_test)
