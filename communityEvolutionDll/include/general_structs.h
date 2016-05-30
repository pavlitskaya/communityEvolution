#pragma once

struct set_negate {
	__host__ __device__ uint32_t operator()(uint32_t &x) {
		return -x;
	}
};

template <typename T>
struct set_one {
	__host__ __device__ T operator()(T &x) {
		return 1;
	}
};

template <typename T>
struct set_zero {
	__host__ __device__ T operator()(T &x) {
		return 0;
	}
};
