#pragma once

struct pair_create_sort : public thrust::unary_function<thrust::tuple<uint32_t, uint32_t>, pair_t> {
	__host__ __device__
		pair_t operator()(const thrust::tuple<uint32_t, uint32_t> &t)
	{
		printf("");
		if (thrust::get<0>(t) < thrust::get<1>(t))
			return pair_t(thrust::get<0>(t), thrust::get<1>(t));
		if (thrust::get<0>(t) > thrust::get<1>(t))
			return pair_t(thrust::get<1>(t), thrust::get<0>(t));
		return pair_t(0, 0);
	}
};

struct is_loop_pair : public thrust::unary_function<pair_t, bool> {
	__host__ __device__
		bool operator()(const pair_t &t)
	{
		return thrust::get<1>(t) == thrust::get<0>(t);
	}
};

