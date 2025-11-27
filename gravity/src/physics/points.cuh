#pragma once
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/generate.h>
#include <thrust/sort.h>
#include <thrust/copy.h>
#include <thrust/random.h>
#include <thrust/remove.h>
#include <thrust/gather.h>
#include <thrust/iterator/zip_iterator.h>
#include "../OpenGL/grid.hpp"
#include "../quad_tree/zOrder.cuh"

struct bounding_box {
    float scale, x, y;
    uint id;
};

struct position {
    float x, y;
};

struct Key {
    uint32_t key;
    float scale;
    bool id = 0;
};

struct com {
    float x, y;
    float vx, vy;
    float ax, ay;
    float m;
    float color = 0;
    __host__ __device__
        com operator + (const com& rhs) const {
        float mx = m * x + rhs.m * rhs.x;
        float my = m * y + rhs.m * rhs.y;
        float ms = m + rhs.m;
        return { ms != 0 ? mx / ms : 0 , ms != 0 ? my / ms : 0,rhs.vx + vx, rhs.vy + vy, 0, 0, ms };
    }
};

struct points {
    thrust::device_vector<Key> keys;
    thrust::device_vector<com> data;
    thrust::device_vector<uint32_t> values;
};

position generate_box(uint32_t id);
points generate_random_points(int n, uint NX);