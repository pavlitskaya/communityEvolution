#pragma once

template <typename T>
struct set_value : public thrust::unary_function < T, T > {
	T v;
	__host__ __device__ set_value(T v) : v(v) {}

	__host__ __device__ T operator()(const T &x) {
		return v;
	}
};

template <typename T>
struct set_increase : public thrust::unary_function < T, T > {
	__host__ __device__ T operator()(const T &x) {
		return x + 1;
	}
};

template <typename T>
struct set_decrease : public thrust::unary_function < T, T > {
	__host__ __device__ T operator()(const T &x) {
		return x - 1;
	}
};

template <typename T>
struct set_multiply : public thrust::unary_function < float, T > {
	float m;
	__host__ __device__ set_multiply(float m) : m(m) {}

	__host__ __device__ T operator()(const T &x) {
		return m*x;
	}
};

template <typename T>
struct set_square : public thrust::unary_function < T, float > {
	__host__ __device__ float operator()(const T &x) {
		return x*x;
	}
};

template <typename T>
struct zip_mul : public thrust::unary_function<thrust::tuple<T, T>, T> {
	__host__ __device__
		T operator()(const thrust::tuple<T, T> &t)
	{
		return thrust::get<0>(t) *thrust::get<1>(t);
	}
};

template <typename T>
struct zip_div : public thrust::unary_function<thrust::tuple<T, T>, float> {
	__host__ __device__
		float operator()(const thrust::tuple<T, T> &t)
	{
		return (float)thrust::get<0>(t) / (float)thrust::get<1>(t);
	}
};

template <typename T>
struct zip_add : public thrust::unary_function<thrust::tuple<T, T>, pair_t> {
	__host__ __device__
		T operator()(const thrust::tuple<T, T> &t)
	{
		return thrust::get<0>(t) +thrust::get<1>(t);
	}
};

template <typename T>
struct zip_sub : public thrust::unary_function<thrust::tuple<T, T>, pair_t> {
	__host__ __device__
		T operator()(const thrust::tuple<T, T> &t)
	{
		return thrust::get<0>(t) -thrust::get<1>(t);
	}
};

template <typename T>
struct set_atomic_increase : public thrust::unary_function < T, void > {
	__device__ void operator()(const T &x) {
		atomicAdd((uint32_t*)&x, (uint32_t)1);
	}
};

template <typename T>
struct set_atomic_decrease : public thrust::unary_function < T, void > {
	__device__ void operator()(const T &x) {
		atomicAdd((uint32_t*)&x, (uint32_t)-1);
	}
};