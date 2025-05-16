#pragma once
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

points generate_random_points(int n, uint NX) {
    grids set = generate_coordinates(NX, NX);
    points pt;
    thrust::host_vector<Key> keys;
    thrust::host_vector<com> data;
    thrust::host_vector<uint32_t> count;
    // n = (int)sqrt(n);
    int div = 4000;
    for (int i = 0; i < n / div; i++) {
        com a;
        for (int j = 0; j < div / 2; j++) {
            float r = (i + 10) * 0.4f;
            a.x = r * cos((float)j / div * 6.28 * 2 + (float)i / n * div * 6.28) + 120;
            a.y = r * sin((float)j / div * 6.28 * 2 + (float)i / n * div * 6.28) + 120;
            //a.len = 0.00390625f;
            a.vx = -7.0f * r * sin((float)j / div * 6.28 * 2 + (float)i / n * div * 6.28);// (rand() % 100 - 50) * 0.05f;
            a.vy = 7.0f * r * cos((float)j / div * 6.28 * 2 + (float)i / n * div * 6.28) + 300.0f;// (rand() % 100 - 50) * 0.05f;
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
            a.vy = -7.0f * r * cos((float)j / div * 6.28 * 2 + (float)i / n * div * 6.28)  -300.0f;// (rand() % 100 - 50) * 0.05f;
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
