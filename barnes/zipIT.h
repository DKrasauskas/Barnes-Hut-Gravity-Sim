#pragma once
typedef thrust::tuple<thrust::device_vector<uint32_t>::iterator, thrust::device_vector<uint32_t>::iterator> IteratorTuple;
typedef thrust::zip_iterator<IteratorTuple> ZipIterator;

typedef thrust::tuple<
    thrust::device_vector<uint32_t>::iterator,
    thrust::device_vector<uint32_t>::iterator,
    thrust::device_vector<uint32_t>::iterator,
    thrust::device_vector<uint32_t>::iterator,
> IteratorTuple4;
typedef thrust::zip_iterator<IteratorTuple4> ZipIterator4;

typedef thrust::tuple<
    thrust::device_vector<uint32_t>::iterator,
    thrust::device_vector<uint32_t>::iterator,
    thrust::device_vector<uint32_t>::iterator,
> IteratorTuple3;
typedef thrust::zip_iterator<IteratorTuple3> ZipIterator3;
typedef thrust::tuple<
    thrust::device_vector<uint32_t>::iterator,
    thrust::device_vector<uint32_t>::iterator,
    thrust::device_vector<com>::iterator,
> IteratorTupleCOM3;
typedef thrust::zip_iterator<IteratorTupleCOM3> ZipIteratorCOM3;

typedef thrust::tuple<
    thrust::device_vector<uint32_t>::iterator,
    thrust::device_vector<uint32_t>::iterator,
    thrust::device_vector<uint32_t>::iterator,
    thrust::device_vector<com>::iterator,
> IteratorTupleCOM4;
typedef thrust::zip_iterator<IteratorTupleCOM4> ZipIteratorCOM4;

typedef thrust::tuple<
    thrust::device_vector<Key>::iterator,
    thrust::device_vector<uint32_t>::iterator,
    thrust::device_vector<uint32_t>::iterator,
    thrust::device_vector<uint32_t>::iterator,
    thrust::device_vector<com>::iterator,
> IteratorTupleCOM5;
typedef thrust::zip_iterator<IteratorTupleCOM5> ZipIteratorCOM5;

typedef thrust::tuple<
    thrust::device_vector<Key>::iterator,
    thrust::device_vector<uint32_t>::iterator,
    thrust::device_vector<uint32_t>::iterator,
    thrust::device_vector<uint32_t>::iterator,
    thrust::device_vector<uint32_t>::iterator,
    thrust::device_vector<com>::iterator,
> IteratorTupleCOM6;
typedef thrust::zip_iterator<IteratorTupleCOM6> ZipIteratorCOM6;