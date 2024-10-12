#pragma once
#pragma once

struct Grid {
    float* vertices;
    uint* indices;
    uint v_size, i_size;
    ~Grid() {
        free(vertices);
    }
};

Grid grid(int n) {
    float* vertices = (float*)malloc(sizeof(float) * (n) * (n) * 3);
    uint* indices = (uint*)malloc(sizeof(uint) * (n - 1) * (n - 1) * 8);
    if (vertices == NULL) throw;
    float dt = 1.0f / (n - 1);
    int index = 0;
    int ind = 0;
    int ind_index = 0;
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            vertices[index] = 0.0f + dt * j;
            vertices[index + 1] = 0.0f + dt * i;
            vertices[index + 2] = 0.0f;
            index += 3;
        }
    }
    for (int i = 0; i < n - 1; i++) {
        for (int j = 0; j < n - 1; j++) {
            indices[ind] = j + i * n;
            indices[ind + 1] = j + 1 + i * n;
            indices[ind + 2] = j + 1 + i * n;
            indices[ind + 3] = j + 1 + (i + 1) * n;
            indices[ind + 4] = j + 1 + (i + 1) * n;
            indices[ind + 5] = j + (i + 1) * n;
            indices[ind + 6] = j + (i + 1) * n;
            indices[ind + 7] = j  + i * n;
            ind += 8;
        }
    }
    return { vertices, indices,  (uint)((n) * (n) * 3 * sizeof(float)), (uint)((n - 1) * (n - 1) * 8 * sizeof(uint)) };
}
Grid grid(int n, bool unit) {
    float* vertices = (float*)malloc(sizeof(float) * 4 * 3 * n);
    uint* indices = (uint*)malloc(sizeof(uint) * n * 8);
    if (vertices == NULL) throw;
    float dt = 1.0f / (n - 1);
    int index = 0;
    int ind = 0;
    int ind_index = 0;
    for (int i = 0; i < n; i++) {
        vertices[index] = 0.0f;
        vertices[index + 1] = 0.0f;
        vertices[index + 2] = 0.0f;

        vertices[index + 3] = 0.0f;
        vertices[index + 4] = 1.f;
        vertices[index + 5] = 0.0f;

        vertices[index + 6] = 1.0f;
        vertices[index + 7] = 1.0f;
        vertices[index + 8] = 0.0f;

        vertices[index + 9] = 1.0f;
        vertices[index + 10] = -0.0f;
        vertices[index + 11] = 0.0f;
        index += 12;
    }
    int p = 0;
    for (int i = 0; i < n ; i++) {     
            indices[ind] = p;
            indices[ind + 1] = p +1;
            indices[ind + 2] = p + 1; 
            indices[ind + 3] = p + 2;
            indices[ind + 4] = p + 2;
            indices[ind + 5] = p + 3; 
            indices[ind + 6] = p + 3;
            indices[ind + 7] = p;
            ind += 8;
            p += 4;   
    }
    return { vertices, indices,  (uint)(4 * 3 * n * sizeof(float)), (uint)(n* 8 * sizeof(uint)) };
}