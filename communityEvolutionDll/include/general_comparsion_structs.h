#pragma once

struct is_even
{
	__host__ __device__
		bool operator()(const uint32_t &x)
	{
		return (x % 2) == 0;
	}
};

struct is_odd
{
	__host__ __device__
		bool operator()(const uint32_t &x)
	{
		return (x % 2) == 1;
	}
};

struct is_equal_to_pair : public thrust::unary_function<thrust::tuple<pair_t, pair_t>, bool> {

	__host__ __device__
		bool operator()(const thrust::tuple<pair_t, pair_t> &t)
	{
		if ((thrust::get<0>(t).first == thrust::get<1>(t).first) &&
			(thrust::get<0>(t).second == thrust::get<1>(t).second)) return 1;
		return 0;
	}
};

struct is_equal_to : public thrust::unary_function<thrust::tuple<uint32_t, uint32_t>, bool> {

	__host__ __device__
		bool operator()(const thrust::tuple<uint32_t, uint32_t> &t)
	{
		if (thrust::get<0>(t) == thrust::get<1>(t)) return 1;
		return 0;
	}
};

struct equal_to_next : public thrust::unary_function<uint32_t, bool> {
	uint32_t n, off;
	const pair_t* key_values;
	__host__ __device__
		equal_to_next(const pair_t* key_values, uint32_t n, uint32_t off) : key_values(key_values), n(n), off(off){}

	__host__ __device__
		bool operator()(const uint32_t &x)
	{
		printf("");
		if (x + off >= n){
			printf("x: %lu xoff: %lu \n", x, x + off);
			return 0;
		}
		return key_values[x].first == key_values[x + off].first;
	}
};

template <typename T>
struct is_greater_zip : public thrust::unary_function<thrust::tuple<T, T>, bool> {

	__host__ __device__
		bool operator()(const thrust::tuple<T, T> &t)
	{
		if (thrust::get<0>(t) > thrust::get<1>(t)) return 1;
		return 0;
	}
};

template <typename T>
struct is_smaller_zip : public thrust::unary_function<thrust::tuple<T, T>, bool> {

	__host__ __device__
		bool operator()(const thrust::tuple<T, T> &t)
	{
		if (thrust::get<0>(t) < thrust::get<1>(t)) return 1;
		return 0;
	}
};

template <typename T>
struct is_greater_equal_zip : public thrust::unary_function<thrust::tuple<T, T>, bool> {

	__host__ __device__
		bool operator()(const thrust::tuple<T, T> &t)
	{
		if (thrust::get<0>(t) >= thrust::get<1>(t)) return 1;
		return 0;
	}
};

template <typename T>
struct is_smaller_equal_zip : public thrust::unary_function<thrust::tuple<T, T>, bool> {

	__host__ __device__
		bool operator()(const thrust::tuple<T, T> &t)
	{
		if (thrust::get<0>(t) <= thrust::get<1>(t)) return 1;
		return 0;
	}
};


template <typename T>
struct is_greater
{
	T val;
	__host__ __device__
		is_greater(T val) :val(val){}

	__host__ __device__
		bool operator()(const T &x)
	{
		return (x > val);
	}
};

// ( )
template <typename T>
struct is_between
{
	T l_bound, h_bound;
	__host__ __device__
		is_between(T l_bound, T h_bound) : l_bound(l_bound), h_bound(h_bound){}

	__host__ __device__
		bool operator()(const T &x)
	{
		return (x > l_bound) && (x < h_bound);
	}
};

template <typename T>
struct is_smaller
{
	T val;
	__host__ __device__
		is_smaller(T val) :val(val){}

	__host__ __device__
		bool operator()(const T &x)
	{
		return (x < val);
	}
};

template <typename T>
struct is_one
{
	__host__ __device__
		bool operator()(const T &x)
	{
		if (x == NULL){
			return 0;
			//printf("error");
		}
		return (x == (T)1);
	}
};

struct is_negative_triple
{
	__host__ __device__
		bool operator()(const tuple_triple &x)
	{
		if (thrust::get<0>(x) < 0 || thrust::get<1>(x) < 0 || thrust::get<2>(x) < 0)
			return 1;
		return 0;
	}
};

struct is_negative_pair
{
	__host__ __device__
		bool operator()(const pair_ti &x)
	{
		if (x.first < 0 || x.second < 0)
			return 1;
		return 0;
	}
};