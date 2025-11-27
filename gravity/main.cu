
#include <glad.h>
#include <glfw3.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <thrust/execution_policy.h>
#include <stdio.h>
#include <iostream>
#include <vector>
#include <algorithm>
#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/generate.h>
#include <thrust/sort.h>
#include <thrust/copy.h>
#include <thrust/random.h>
#include <thrust/remove.h>
#include <thrust/gather.h>
#include <thrust/iterator/zip_iterator.h>
#define uint unsigned int

//gpu:


#include "src/OpenGL/Shader.h"
#include "src/OpenGL/buffer.h"
#include "src/OpenGL/grid.hpp"
#include "src/settings.h"
#include <cmath>
#include "src/quad_tree/zOrder.cuh"
#include "src/physics/points.cuh"

//_________________________________________________________________________________________OpenGL_____________________________________________________________________________//

void framebuffer_size_callback(GLFWwindow* window, int width, int height);

GLFWwindow* createWindow() {
    glfwInit();
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 6);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    GLFWwindow* win = glfwCreateWindow(SCR_WIDTH, SCR_HEIGHT, "Orbits", NULL, NULL);
    win == NULL ? throw std::exception() : NULL;
    glfwMakeContextCurrent(win);
    !gladLoadGLLoader((GLADloadproc)glfwGetProcAddress) ? throw std::exception() : NULL;
    return win;
}
//_________________________________________________________________________________________Cuda_____________________________________________________________________________//
__managed__ float* ax, * bx, * cx, * dx, * scales, * px, * color;
#include "src/quad_tree/tree.cuh"
#include "timer.cuh"
#include "src/runtime/kernels.cuh"

int main()
{
    GLFWwindow* window = createWindow();
    glfwMakeContextCurrent(window);
    glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_HIDDEN);
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
    glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_HIDDEN);
    Shader vertex("../src/OpenGL/Shaders/vertex.glsl", "../src/OpenGL/Shaders/fragment.glsl");
    Shader vertex2("../src/OpenGL/Shaders/vertex1.glsl", "../src/OpenGL/Shaders/fragment.glsl");
    Cshader computes("../src/OpenGL/Shaders/compute.glsl");
    Grid gd = grid(160000, 1);
    Grid pt = grid(1000); //100;
    Buffer buff((void*)gd.vertices, (void*)gd.indices, gd.v_size, gd.i_size);
    Buffer buff2((void*)pt.vertices, (void*)pt.indices, pt.v_size, pt.i_size);

    //tree memaloc
    quad_tree tree(D_MAX);

    int n = 8388608; //number of particles

    int size;
    int p_count = n;
    points pts = generate_random_points(n, N_DIM);
    cudaMallocManaged(&ax, sizeof(float) * n);
    cudaMallocManaged(&bx, sizeof(float) * n);
    cudaMallocManaged(&color, sizeof(float) * n);
    cudaMallocManaged(&cx, sizeof(float) * 1000 * 1024);
    cudaMallocManaged(&dx, sizeof(float) * 1000 * 1024);
    cudaMallocManaged(&scales, sizeof(float) * 1000 * 1024);
    GLuint buf1, buf2, buf3, buf4, buf5, col;
    glGenBuffers(1, &buf1);
    glGenBuffers(1, &buf2);
    glGenBuffers(1, &buf3);
    glGenBuffers(1, &buf4);
    glGenBuffers(1, &buf5);
    glGenBuffers(1, &col);
    tree.pt = pts;
    const char* cmd =  "ffmpeg -r 60 -f rawvideo -pix_fmt rgba -s 1200x1200 -i - -threads 0 "
                       "-preset fast -y -pix_fmt yuv420p -crf 20 -vf vflip output1.mp4";
    unsigned char* image = (unsigned char*)malloc(sizeof(unsigned char) * SCR_WIDTH * SCR_HEIGHT * 4);
    // open pipe to ffmpeg's stdin in binary write mode
    FILE* ffmpeg = popen(cmd, "w");
    if (!ffmpeg) {
        perror("popen failed");
    }
    //render loop
    stateS = 20;
    while (!glfwWindowShouldClose(window)) {
        if (stateS > 2) {
            p_count = thrust::remove_if(tree.pt.data.begin(), tree.pt.data.begin() + p_count, boundary()) - tree.pt.data.begin();
            size = generate_bounding_boxes(tree, D_MAX, p_count);
            remove_nonleafs(tree, size);
            populate(tree, size);
            traverse_tree <<<n / 256, 256 >>> (thrust::raw_pointer_cast(&tree.ids[0]), thrust::raw_pointer_cast(&tree.clen[0]), thrust::raw_pointer_cast(&tree.nlen[0]), thrust::raw_pointer_cast(&tree.pt.data[0]), thrust::raw_pointer_cast(&tree.bdata[0]), thrust::raw_pointer_cast(&tree.keys[0]), size, p_count);
            cudaDeviceSynchronize();
            cpy_kernel <<<n / 256, 256 >>> (ax, bx, color, thrust::raw_pointer_cast(&tree.pt.data[0]), thrust::raw_pointer_cast(&tree.pt.keys[0]), p_count);
            cudaDeviceSynchronize();
            if (false) {
                glReadPixels(0, 0, SCR_WIDTH, SCR_HEIGHT, GL_RGBA, GL_UNSIGNED_BYTE, image);
                fwrite(image, SCR_WIDTH * SCR_HEIGHT * sizeof(int), 1, ffmpeg);
            }
        }
        processInput(window);
        glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);
        if (stateS > 100) {
            boxes <<<size / 100, 100 >>> (thrust::raw_pointer_cast(&tree.keys[0]), cx, dx, scales);
            cudaDeviceSynchronize();
            glUseProgram(vertex.ID);
            glBindBuffer(GL_SHADER_STORAGE_BUFFER, buf3);
            glBufferData(GL_SHADER_STORAGE_BUFFER, sizeof(float) * size, cx, GL_STATIC_DRAW);
            glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 3, buf3);
            glBindBuffer(GL_SHADER_STORAGE_BUFFER, buf4);
            glBufferData(GL_SHADER_STORAGE_BUFFER, sizeof(float) * size, dx, GL_STATIC_DRAW);
            glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 4, buf4);
            glBindBuffer(GL_SHADER_STORAGE_BUFFER, buf5);
            glBufferData(GL_SHADER_STORAGE_BUFFER, sizeof(float) * size, scales, GL_STATIC_DRAW);
            glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 5, buf5);
            glBindVertexArray(buff.VAO);
            glDrawElements(GL_LINES, 160000, GL_UNSIGNED_INT, (void*)0);
        }
        glUseProgram(vertex2.ID);
        glBindBuffer(GL_SHADER_STORAGE_BUFFER, buf1);
        glBufferData(GL_SHADER_STORAGE_BUFFER, sizeof(float) * (p_count) ,ax , GL_STATIC_DRAW);
        glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 1, buf1);
        glBindBuffer(GL_SHADER_STORAGE_BUFFER, buf2);
        glBufferData(GL_SHADER_STORAGE_BUFFER, sizeof(float) * (p_count), bx , GL_STATIC_DRAW);
        glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 2, buf2);
        glBindBuffer(GL_SHADER_STORAGE_BUFFER, col);
        glBufferData(GL_SHADER_STORAGE_BUFFER, sizeof(float) * (p_count), color, GL_STATIC_DRAW);
        glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 3, col);
        glBindVertexArray(buff2.VAO);
        glDrawArrays(GL_POINTS, 0, p_count);
        glfwSwapBuffers(window);
        glfwPollEvents();
    }
    pclose(ffmpeg);
    cudaFree(ax);
    cudaFree(bx);
    cudaFree(cx);
    cudaFree(dx);
    cudaFree(scales);
    free(image);
    return 0;
}

void framebuffer_size_callback(GLFWwindow* window, int width, int height)
{
    glViewport(0, 0, width, height);
}
