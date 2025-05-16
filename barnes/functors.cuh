#pragma once

//segmented reduction
struct shift {
    __host__ __device__ Key operator()(Key& x) const {    
        x.key = x.key >> 2;
        x.scale = 2 * x.scale;
        return x;
    }
};
struct equal_key {
    __host__ __device__ bool operator()(const Key& k1, const Key& k2) {
        if (((k1.key >> 2) == (k2.key >> 2))) return true;
        return false;
    }
};
struct equal_key_points {
    __host__ __device__ bool operator()(const Key& k1, const Key& k2) {
        if (((k1.key) == (k2.key))) return true;
        return false;
    }
};
struct Plus
{
    template<typename Tuple>
    __host__ __device__
        Tuple operator()(const Tuple& lhs, const Tuple& rhs)
    {
        return thrust::make_tuple(
            thrust::get<0>(lhs) + thrust::get<0>(rhs),
            thrust::get<1>(lhs) + thrust::get<1>(rhs),
            thrust::get<2>(lhs) + thrust::get<2>(rhs), 
            thrust::get<3>(lhs) + thrust::get<3>(rhs)
        );
    }
};
struct Plus_init
{
    template<typename Tuple>
    __host__ __device__
        Tuple operator()(const Tuple& lhs, const Tuple& rhs)
    {
        return thrust::make_tuple(
            1,
            1, thrust::get<2>(lhs) + thrust::get<2>(rhs), 
            thrust::get<3>(lhs) + thrust::get<3>(rhs)
        );
    }
};


//Id calculation
struct Minus
{
    __host__ __device__
        uint32_t operator()(uint32_t lhs)
    {
        return lhs == 1 ? 1 : 0;
    }
};
struct rem {
    __host__ __device__
        bool operator()(const uint32_t lhs)
    {
        return (lhs) == 1 ? 1 : 0;

    }
};

struct pr {
    __device__ __host__ uint32_t operator ()(uint32_t ckey) {
        return ckey == 1 ? 0 : 1;
    }
};
struct pr_negated {
    __device__ __host__ uint32_t operator ()(uint32_t ckey) {
        return ckey == 1 ? 1 : 0;
    }
};
struct sw {
    template<typename Tuple>
    __host__ __device__
        uint32_t operator()(const Tuple& lhs, uint32_t id)
    {
        return id == 0 ? thrust::get<1>(lhs) + 1 : thrust::get<0>(lhs);
    }
};

// gravity
struct vel {
    __host__ __device__
        com operator ()(const com& rhs) {
        return { rhs.x + rhs.vx * 0.1f, rhs.y + rhs.vy * 0.1f, rhs.vx, 0, 0, rhs.vy, rhs.m };
    }
};
struct key_compute {
    __host__ __device__
        Key operator ()(const com& rhs) {
        Key ks;
        ks.key = 0;
        ks.scale = 0.00390625f * 0.5f;
        uint x = rhs.x > 0 ? (rhs.x < N_DIM ? floor(rhs.x) : N_DIM) : 0;
        uint y = rhs.y > 0 ? (rhs.y < N_DIM ? floor(rhs.y) : N_DIM) : 0;
        if (rhs.x < 0 || rhs.y < 0 || rhs.x > N_DIM || rhs.y > N_DIM) {
            return ks;
        }
        uint32_t key = 0;
       // key |= (uint32_t)1 << 31;
        for (int k = 0; k < 32; k++) {
            key |= k % 2 == 0 ? ((((uint16_t)1 << k / 2) & x) == 0 ? 0 : (uint32_t)1 << k) : 0;
            key |= (k + 1) % 2 == 0 ? ((((uint16_t)1 << k / 2) & y) == 0 ? 0 : (uint32_t)1 << k) : 0;
        }
        ks.key = key;
        ks.id = rhs.color;
        return ks;
    }
};

struct boundary {
    __host__ __device__
        bool operator ()(const com& rhs) {

        if (rhs.x < 0 || rhs.y < 0 || rhs.x > N_DIM || rhs.y > N_DIM) {
            return 1;
        }
        return 0;

    }
};
