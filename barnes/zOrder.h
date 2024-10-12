#pragma once
struct grids {
    uint16_t X_MAX, Y_MAX;
    uint32_t* x, * y;
};


grids generate_coordinates(uint X_MAX, uint Y_MAX) {
    grids gd = { X_MAX, Y_MAX, (uint32_t*)calloc(X_MAX, sizeof(uint32_t)), (uint32_t*)calloc(Y_MAX, sizeof(uint32_t)) };
    for (uint16_t i = 0; i < X_MAX; i++) {
        for (int k = 0; k < 32; k++) {
            gd.x[i] |= k % 2 == 0 ? ((((uint16_t)1 << k / 2) & i) == 0 ? 0 : (uint32_t)1 << k) : 0;

        }
        gd.y[i] |= gd.x[i] << 1;
        gd.y[i] |= ((uint32_t)1 << 31);

    }
    return gd;
}