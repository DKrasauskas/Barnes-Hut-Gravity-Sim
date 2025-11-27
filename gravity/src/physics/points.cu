//
// Created by dominykas on 11/27/25.
//
#include "points.cuh"

position generate_box(uint32_t id) {
    int x = 0;
    int y = 0;
    for (int i = 0; i < 32; i += 2) {
        int bitX = (int)(id & ((uint32_t)1));
        id = id >> 1;
        int bitY = (int)(id & ((uint32_t)1));
        id = id >> 1;
        x |= bitX << i / 2;
        y |= bitY << i / 2;
    }
    return { (float)x,(float)y };
}

points generate_random_points(int n, uint NX) {
    grids set = generate_coordinates(NX, NX);
    points pt;
    thrust::host_vector<Key> keys;
    thrust::host_vector<com> data;
    thrust::host_vector<uint32_t> count;
    // n = (int)sqrt(n);
    int div = 32000;
    float offstex = 150;
    float offstey = 150;
    for (int i = 0; i < n / div; i++) {
        com a;
        for (int j = 0; j < div; j++) {
            float r = (i + 10) * 0.4f;
            a.x = r * cos((float)j / div * 6.28 * 2 + (float)i / n * div * 6.28) + offstex;
            a.y = r * sin((float)j / div * 6.28 * 2 + (float)i / n * div * 6.28) + offstey;
            //a.len = 0.00390625f;
            a.vx = -7.0f * r * sin((float)j / div * 6.28 * 2 + (float)i / n * div * 6.28);// (rand() % 100 - 50) * 0.05f;
            a.vy = 7.0f * r * cos((float)j / div * 6.28 * 2 + (float)i / n * div * 6.28) + 150.0f;// (rand() % 100 - 50) * 0.05f;
            a.m = 1;
            Key k;
            k.key = 0;
            a.color = 0.0f;
            data.push_back(a);
            keys.push_back(k);
            count.push_back(1);
        }
        for (int j = 0; j < div - div / 2; j++) {
            float r = (i + 10) * 0.4f;
            a.x = r * cos((float)j / div * 6.28 * 2 + (float)i / n * div * 6.28) + 80 + 256;
            a.y = r * sin((float)j / div * 6.28 * 2 + (float)i / n * div * 6.28) + 80 + 256;
            //a.len = 0.00390625f;
            a.vx = 7.0f * r * sin((float)j / div * 6.28 * 2 + (float)i / n * div * 6.28);// (rand() % 100 - 50) * 0.05f;
            a.vy = -7.0f * r * cos((float)j / div * 6.28 * 2 + (float)i / n * div * 6.28)  -150.0f;// (rand() % 100 - 50) * 0.05f;
            a.m = 1;
            Key k;
            k.key = 0;
            a.color = 1.0f;
            data.push_back(a);
            keys.push_back(k);
            count.push_back(1);
        }

    }
    pt.data = data;
    pt.keys = keys;
    pt.values = count;
    return { pt.keys, pt.data,  pt.values };
}