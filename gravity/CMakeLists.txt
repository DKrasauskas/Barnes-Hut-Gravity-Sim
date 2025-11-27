cmake_minimum_required(VERSION 3.30)
project(ELBM LANGUAGES C  CXX CUDA)

set(CMAKE_CUDA_STANDARD 20)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CUDA_ARCHITECTURES 80)
include_directories(
        ${CMAKE_SOURCE_DIR}/include/KHR
        ${CMAKE_SOURCE_DIR}/include/GLFW
        ${CMAKE_SOURCE_DIR}/include/glad
        C:/Program Files/NVIDIA GPU Computing Toolkit/CUDA/v12.5/include
)

find_package(OpenMP REQUIRED)

set(SOURCES
        main.cu
        ../lib/glad/src/glad.c
)

set_source_files_properties(
        main.cu
        PROPERTIES LANGUAGE CUDA
)

find_package(CUDAToolkit REQUIRED)
find_package(OpenMP REQUIRED)

link_directories(
        lib
        $(WindowsSDK_LibraryPath_x64)
)

add_executable(gravity
        main.cu
        ../lib/glad/src/glad.c
        src/OpenGL/src/buffer.cpp
        src/OpenGL/src/Shader.cu
        src/quad_tree/tree.cuh
        src/quad_tree/tree.cu
        src/physics/points.cu
        src/runtime/kernels.cu
        src/OpenGL/src/grid.cpp
        src/quad_tree/zOrder.cu
        "src/settings .c"

)


target_include_directories(gravity PRIVATE
        ${CUDAToolkit_INCLUDE_DIRS}
)

#target_include_directories(ELBM PRIVATE "/usr/include/nvidia-ml")
#target_link_directories(gravity PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/lib/glfw/build_shared/src")

#This line wont work on clusters
#set(NVLIB /usr/lib/libnvidia-ml.so)

set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} -w")

target_link_libraries(gravity PRIVATE
        glfw
        GL
        cuda
        OpenMP::OpenMP_CXX
        EGL
        ${NVLIB}
)

set_target_properties(gravity PROPERTIES
        CUDA_SEPARABLE_COMPILATION ON
)

target_compile_options(gravity PRIVATE
        $<$<COMPILE_LANGUAGE:CUDA>:--maxrregcount=255>
        $<$<COMPILE_LANGUAGE:CUDA>:-lineinfo>
        $<$<COMPILE_LANGUAGE:CUDA>:-Xcompiler=-fopenmp>
)