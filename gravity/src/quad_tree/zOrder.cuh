#pragma once
#include <stdint.h>

struct grids {
    uint16_t X_MAX, Y_MAX;
    uint32_t* x, * y;
};


grids generate_coordinates(uint16_t X_MAX, uint16_t Y_MAX);
