//
// Created by dominykas on 11/27/25.
//
#pragma once
#include "tree.cuh"


// tree generation
int generate_bounding_boxes(quad_tree& tree, int depth, int p_count) {
    int key_begin = 0;
    int key_end = 0;
    std::cout << tree.clen.begin() - tree.clen.end() << "\n";
    thrust::fill(tree.clen.begin(), tree.clen.end(), (uint32_t)0);
    thrust::fill(tree.nlen.begin(), tree.nlen.end(), (uint32_t)0);
    thrust::fill(tree.tmap.begin(), tree.tmap.end(), (uint32_t)0);
    thrust::fill(tree.ids.begin(), tree.ids.end(), (uint32_t)0);
    thrust::fill(tree.bdata.begin(), tree.bdata.end(), com());
    thrust::transform(tree.pt.data.begin(), tree.pt.data.begin() + p_count, tree.pt.keys.begin(), key_compute());
    thrust::sort_by_key(
            tree.pt.keys.begin(),
            tree.pt.keys.begin() + p_count,
            tree.pt.data.begin(),
            srt()
    );
    ZipIteratorCOM4 values_read = thrust::make_zip_iterator(tree.pt.values.begin(), tree.pt.values.begin(), tree.pt.values.begin(), tree.pt.data.begin());
    ZipIteratorCOM4 values_write = thrust::make_zip_iterator(tree.nlen.begin(), tree.clen.begin(), tree.Nlen.begin(),  tree.bdata.begin());

    auto log = thrust::reduce_by_key(
            tree.pt.keys.begin(),
            tree.pt.keys.begin() + p_count,
            values_read,
            tree.keys.begin(),
            values_write,
            equal_key_points(),
            Plus_init()
    );
    key_end = log.first - tree.keys.begin();
    for (int i = depth; i > 0; i--) {
        values_read = thrust::make_zip_iterator(tree.nlen.begin() + key_begin, tree.pt.values.begin(), tree.Nlen.begin() + key_begin, tree.bdata.begin() + key_begin);
        values_write = thrust::make_zip_iterator(tree.nlen.begin() + key_end, tree.clen.begin() + key_end, tree.Nlen.begin() + key_end, tree.bdata.begin() + key_end);
        log = thrust::reduce_by_key(
                tree.keys.begin() + key_begin,
                tree.keys.begin() + key_end,
                values_read,
                tree.keys.begin() + key_end,
                values_write,
                equal_key(),
                Plus()
        );
        key_begin = key_end;
        key_end = log.first - tree.keys.begin();
        thrust::transform(
                tree.keys.begin() + key_begin,
                tree.keys.begin() + key_end,
                tree.keys.begin() + key_begin,
                shift()
        );
    }
    ZipIteratorCOM5 it = thrust::make_zip_iterator(tree.keys.begin(), tree.clen.begin(), tree.nlen.begin(), tree.Nlen.begin(), tree.bdata.begin());
    thrust::reverse(it, it + (log.first - tree.keys.begin()));

    return  (log.first - tree.keys.begin());
}



void remove_nonleafs(quad_tree& tree, int& size) {
    using namespace thrust;
    thrust::exclusive_scan(tree.clen.begin(), tree.clen.begin() + size, tree.ids.begin(), 0, thrust::plus<uint32_t>());
    scatter(tree.seq.begin(), tree.seq.begin() + size, tree.ids.begin(), tree.tmap.begin());
    inclusive_scan(tree.tmap.begin(), tree.tmap.begin() + size, tree.ids.begin() , thrust::maximum<uint32_t>());
    gather(tree.ids.begin() , tree.ids.begin() + size, tree.nlen.begin(), tree.tmap.begin() + 1);
    ZipIteratorCOM6 begin = thrust::make_zip_iterator(tree.keys.begin(), tree.clen.begin(), tree.nlen.begin(), tree.Nlen.begin(),  tree.ids.begin(), tree.bdata.begin());
    ZipIteratorCOM6 end = begin + size;
    size = remove_if(begin, end, tree.tmap.begin(), rem()) - begin;
    thrust::transform(tree.nlen.begin(), tree.nlen.begin() + size, tree.ids.begin(), Minus());
}

void populate(quad_tree& tree, int& size) {
    thrust::replace_if(tree.Nlen.begin(), tree.Nlen.begin() + size, tree.ids.begin(), pr(), 0);
    thrust::replace_if(tree.clen.begin(), tree.clen.begin() + size, tree.ids.begin(), pr_negated(), 0);
    thrust::exclusive_scan(tree.clen.begin(), tree.clen.begin() + size, tree.tmap.begin(), 0, thrust::plus<uint32_t>());
    //fpos
    thrust::transform(tree.clen.begin(), tree.clen.begin() + size, tree.Nlen.begin(), tree.clen.begin(), thrust::plus<uint32_t>());
    thrust::device_vector<uint32_t> mem = tree.tmap;
    thrust::exclusive_scan(tree.Nlen.begin(), tree.Nlen.begin() + size, mem.begin(), 0, thrust::plus<uint32_t>());

    ////// cpos npos
    ZipIterator it = make_zip_iterator(mem.begin(), tree.tmap.begin());
    thrust::transform(it, it + size, tree.ids.begin(), tree.nlen.begin(), sw());
}
