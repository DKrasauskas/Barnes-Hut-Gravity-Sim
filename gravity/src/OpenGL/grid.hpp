#pragma once

#include <cstdint>
#include "buffer.h"

struct Grid {
    float* vertices;
    uint* indices;
    uint v_size, i_size;
    ~Grid() {
        free(vertices);
    }
};

Grid grid(int n);
Grid grid(int n, bool unit) ;