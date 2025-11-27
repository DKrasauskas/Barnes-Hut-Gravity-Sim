#pragma once
//copies data from cuda to opengl SSBO
#include "../quad_tree/zOrder.cuh"
#include "../physics/points.cuh"
#include "../settings.h"

__global__ void cpy_kernel(float* dev_x, float* dev_y, float* dev_z, com* cm, Key* keys, int n);

//computes quad tree bounding boxes for rendering
__global__ void boxes(Key* keys, float* cx, float* dx, float* scales);

//tree traversal Barnes-Hut
__global__ void traverse_tree(uint32_t* id, uint32_t* clen, uint32_t* nlen, com* planets, com* nodes, Key* keys, int n, int p);
