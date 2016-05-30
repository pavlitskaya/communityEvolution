#include "stdafx.h"
#include "include/general_search.h"

__host__ __device__ uint32_t g_binary_search(pair_t* source, pair_t key, uint32_t pair_size, int32_t ind_min, int32_t ind_max, bool& found, bool b_swap){
	if (b_swap && key.second < key.first)thrust::swap(key.first, key.second);

	int32_t ind_mid = 0;
	found = false;

	while (ind_min <= ind_max){
		//printf("ind_min: %lu, ind_max: %lu, ind_mid: %lu \n", ind_min, ind_max, ind_mid);
		ind_mid = ind_min + (ind_max - ind_min)*0.5;
		if (source[ind_mid].first == key.first && source[ind_mid].second == key.second){
			found = true;
			return ind_mid;
		}
		else
			if (source[ind_mid].first > key.first ||
				(source[ind_mid].first == key.first &&
				source[ind_mid].second > key.second)){
			if (ind_mid - 1 < 0)return ind_mid = 0;
			ind_max = ind_mid - 1;
			}
			else
				ind_min = ind_mid + 1;
	}

	//if (!found && ind_mid == pair_size - 1)
		//return pair_size;
	return ind_mid;
}

__host__ __device__ uint32_t g_binary_search(pair_t* source, pair_t key, uint32_t pair_size, bool& found, bool b_swap){
	return g_binary_search(source, key, pair_size, 0, (int32_t)pair_size - 1, found, b_swap);
}

__host__ __device__ bool g_binary_search(pair_t* source, pair_t key, uint32_t pair_size, bool b_swap){
	return g_binary_search(source, key, pair_size, 0, pair_size - 1, b_swap);
}

__host__ __device__ bool g_binary_search(pair_t* source, pair_t key, uint32_t pair_size, uint32_t ind_min, uint32_t ind_max, bool b_swap){
	if (b_swap && key.second < key.first)thrust::swap(key.first, key.second);

	uint32_t ind_mid = 0;
	while (ind_min <= ind_max){
		ind_mid = ind_min + (ind_max - ind_min)*0.5;
		if (source[ind_mid].first == key.first && source[ind_mid].second == key.second){
			return true;
		}
		else
			if (source[ind_mid].first > key.first ||
				(source[ind_mid].first == key.first &&
				source[ind_mid].second > key.second))
				ind_max = ind_mid - 1;
			else
				ind_min = ind_mid + 1;
	}
	return false;
}

__host__ __device__ bool g_binary_search(uint32_t* begin, uint32_t* end, uint32_t key){
	bool found;
	g_binary_search(begin, end, key, 0, (end - 1) - begin, found);
	return found;
}

__host__ __device__ uint32_t g_binary_search(uint32_t* begin, uint32_t* end, uint32_t key, bool& found){
	return g_binary_search(begin, end, key, 0, (end - 1) - begin, found);
}

__host__ __device__ uint32_t g_binary_search(uint32_t* begin, uint32_t* end, uint32_t key, uint32_t ind_min, uint32_t ind_max, bool& found){
	found = false;
	uint32_t ind_mid = 0;
	uint32_t count = 0;
	while (ind_min <= ind_max){
		ind_mid = ind_min + (ind_max - ind_min)*0.5;
		if (*(begin + ind_mid) == key){
			found = true;
			return ind_mid;
		}
		else{
			if (*(begin + ind_mid) > key){
				if (ind_mid == 0)
					return 0;
				ind_max = ind_mid - 1;
			}
			else
				ind_min = ind_mid + 1;
		}
	}
	return ind_mid;
}
