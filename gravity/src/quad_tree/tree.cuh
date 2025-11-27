//
// Created by dominykas on 11/27/25.
//

#ifndef ELBM_TREE_CUH
#define ELBM_TREE_CUH
#pragma once
#include "functors.cuh"
#include "zipIT.cuh"
#include <iostream>
#include <vector>
#include <algorithm>
#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/generate.h>
#include <thrust/sort.h>
#include <thrust/copy.h>
#include <thrust/random.h>
#include <thrust/remove.h>
#include <thrust/gather.h>
#include <thrust/iterator/zip_iterator.h>
#include "../physics/points.cuh"

struct quad_tree {
    points pt;
    thrust::device_vector<Key> keys;//
    thrust::device_vector<uint32_t> nlen;
    thrust::device_vector<uint32_t> Nlen;
    thrust::device_vector<uint32_t> clen;
    thrust::device_vector<uint32_t> ids;//
    thrust::device_vector<uint32_t> tmap;
    thrust::device_vector<uint32_t> seq;
    thrust::device_vector<com> bdata;

    quad_tree(int size) {
        int sz = (1 - pow(4, size + 1)) / (-3);
        keys = thrust::device_vector<Key>(sz);
        nlen = thrust::device_vector<uint32_t>(sz);
        clen = thrust::device_vector<uint32_t>(sz);
        ids = thrust::device_vector<uint32_t>(sz + 1);
        seq = thrust::device_vector<uint32_t>(sz);
        tmap = thrust::device_vector<uint32_t>(sz);
        bdata = thrust::device_vector<com>(sz);
        Nlen = thrust::device_vector<uint32_t>(sz);
        for (int i = 0; i < sz; i++) {
            seq[i] = i;
        }
    }
};

struct srt {
    __device__ __host__ bool operator()(Key a, Key b) {
        return a.key > b.key ? 0 : 1;
    }
};
// tree generation
int generate_bounding_boxes(quad_tree& tree, int depth, int p_count);
void remove_nonleafs(quad_tree& tree, int& size);
void populate(quad_tree& tree, int& size);

#endif //ELBM_TREE_CUH
