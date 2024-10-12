#pragma once
//copies data from cuda to opengl SSBO
__global__ void cpy_kernel(float* dev_x, float* dev_y, float* dev_z, com* cm, Key* keys, int n) {
    uint idx = threadIdx.x + blockIdx.x * blockDim.x;
    if (idx >= n) return;
    cm[idx].vx += cm[idx].ax;
    cm[idx].vy += cm[idx].ay;
    cm[idx].x += cm[idx].vx * 0.001f;
    cm[idx].y += cm[idx].vy * 0.001f;
    dev_x[idx] = cm[idx].x;
    dev_y[idx] = cm[idx].y;
    dev_z[idx] = sqrt(cm[idx].ax * cm[idx].ax + cm[idx].ay * cm[idx].ay);

}

//computes quad tree bounding boxes for rendering
__global__ void boxes(Key* keys, float* cx, float* dx, float* scales) {
    uint idx = threadIdx.x + blockIdx.x * blockDim.x;
    float scale = keys[idx].scale;
    int x = 0;
    int y = 0;
    uint32_t key = keys[idx].key;
    for (int i = 0; i < 32; i += 2) {
        int bitX = (int)(key & ((uint32_t)1));
        key = key >> 1;
        int bitY = (int)(key & ((uint32_t)1));
        key = key >> 1;
        x |= bitX << i / 2;
        y |= bitY << i / 2;
    }
    scales[idx] = scale;
    cx[idx] = x * scale + scale * 0.5f;
    dx[idx] = y * scale + scale * 0.5f;
}

//tree traversal Barnes-Hut
__global__ void traverse_tree(uint32_t* id, uint32_t* clen, uint32_t* nlen, com* planets, com* nodes, Key* keys, int n, int p) {
    uint idx = threadIdx.x + blockIdx.x * blockDim.x;
    if (idx >= p) return; // to account for removed nodes
    float ax = 0.0f;
    float ay = 0.0f;
    int depth = 1;
    int stack[9] = { 0, 0, 0, 0, 0, 0, 0, 0 };//prolly better to sync shared mem instead of global
    int child_count[9] = { 0, 0, 0, 0, 0, 0, 0, 0 };
    child_count[0] = clen[0];
    int index = 1;
    int begin = 1;
    while (true) {
        //check if all children have been explored
        if (index - begin == child_count[depth - 1] /*root or fits criteria */) {
            index = stack[depth - 1] + 1; // go back to the previous node
            depth -= 1;
            if (depth == 0) break;
            begin = nlen[stack[depth - 1]];         
            continue;
        }

        float px = nodes[index].x - planets[idx].x;
        float py = nodes[index].y - planets[idx].y;
        float dis = px * px + py * py;
        float l = sqrt(dis) + 0.0001f;
        if (keys[index].scale * N_DIM / l < phi) {
            l = (l == 0) ? 0.2f : l;
            ax += nodes[index].m * G / (l * l + 0.2f) * px / l;
            ay += nodes[index].m * G / (l * l + 0.2f) * py / l;
            index++;
            continue;
        }

        //otherwise, evaluate whether to explore further (uncomment for improved accuracy but reduced performance as this computes the forces directly
        if (id[index] == 1) {
            //for (int j = nlen[index]; j < clen[index] + nlen[index]; j++) {
            //    if (j == idx || j >= p) break;
            //    float dx = planets[j].x - planets[idx].x; // defines r = <dx, dy>
            //    float dy = planets[j].y - planets[idx].y;
            //    l = sqrt(dx * dx + dy * dy); //r^2
            //    l = (l == 0) ? 0.2f : l;
            //    ax += G / (l * l + 0.2f) * dx / l;
            //    ay += G / (l * l + 0.2f) * dy / l;
            //}
            index++;
            continue;
        }
        //otherwise, push previous index to stack      
        stack[depth] = index; // 0
        child_count[depth] = clen[index]; // 3
        index = nlen[index];
        begin = index;
        depth += 1;
    }
    planets[idx].ax = ax * 0.001f; // update accelerations
    planets[idx].ay = ay * 0.001f;
}