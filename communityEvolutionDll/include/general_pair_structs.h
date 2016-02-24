#pragma once

/* Returns first item of a pair
 */
struct first_element : public thrust::unary_function<pair_t, uint32_t> {
	__host__  __device__
		uint32_t operator()(const pair_t &p)
	{
		return p.first;
	}
};

/* Returns second item of a pair
*/
struct second_element : public thrust::unary_function<pair_t, uint32_t> {
	__host__  __device__
		uint32_t operator()(const pair_t &p)
	{
		return p.second;
	}
};

struct pair_create : public thrust::unary_function<thrust::tuple<uint32_t, uint32_t>, pair_t> {
	__host__ __device__
		pair_t operator()(const thrust::tuple<uint32_t, uint32_t> &t)
	{
		return pair_t(thrust::get<0>(t), thrust::get<1>(t));
	}
};

struct pair_create_inverse : public thrust::unary_function<pair_t, pair_t> {
	__host__ __device__
		pair_t operator()(const pair_t &t)
	{
		return pair_t(thrust::get<1>(t), thrust::get<0>(t));
	}
};

struct pair_create_const : public thrust::unary_function<uint32_t, pair_t> {
	uint32_t c;
	__host__ __device__ pair_create_const(uint32_t c) : c(c) {}
	__host__ __device__
		pair_t operator()(const uint32_t &val)
	{
		return pair_t(c, val);
	}
};

typedef thrust::transform_iterator<first_element, thrust::detail::normal_iterator<thrust::device_ptr<thrust::pair<unsigned int, unsigned int> > > > TransformIteratorFE;