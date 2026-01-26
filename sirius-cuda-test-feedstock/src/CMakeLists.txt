cmake_minimum_required(VERSION 3.18)
project(sirius-cuda-test LANGUAGES CXX CUDA)

# Find CUDA
find_package(CUDAToolkit REQUIRED)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CUDA_STANDARD 17)
set(CMAKE_CUDA_STANDARD_REQUIRED ON)

# Build the test executable
add_executable(sirius-cuda-test cuda_test.cu)
target_link_libraries(sirius-cuda-test PRIVATE CUDA::cudart)

# Install
install(TARGETS sirius-cuda-test
    RUNTIME DESTINATION bin
)
