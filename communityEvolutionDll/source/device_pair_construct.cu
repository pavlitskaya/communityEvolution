#include "../stdafx.h"
#include "../include/device_pair_construct.h"
#include "../include/device_analytic.h"
#include "../include/general_arithmetic_structs.h"
#include "../include/device_pair_structs.h"
#include "../include/general_comparsion_structs.h"
#include "../include/display_elements.h"
#include "../include/general_pair_structs.h"
#include "../include/device_pair.h"

using namespace std;

// takes mirrored
bool generate_pairs(std::vector<uint32_t>& keys, std::vector<uint32_t>& values, std::vector<pair_t>& pairs){
	T_DV<pair_t> d_target;
	generate_pairs(T_DV<uint32_t>(keys.begin(), keys.end()), T_DV<uint32_t>(values.begin(), values.end()), d_target);
	T_HV<pair_t> h_target(d_target.begin(), d_target.end());
	pairs.assign(h_target.begin(), h_target.end());
	return 1;
}

bool generate_unique_pairs(std::vector<uint32_t>& keys, std::vector<uint32_t>& values, std::vector<pair_t>& pairs){
	T_DV<pair_t> d_target;
	generate_pairs(T_DV<uint32_t>(keys.begin(), keys.end()), T_DV<uint32_t>(values.begin(), values.end()), d_target);
	thrust::sort(d_target.begin(), d_target.end());
	d_target.resize(thrust::unique(d_target.begin(), d_target.end()) - d_target.begin());
	T_HV<pair_t> h_target(d_target.begin(), d_target.end());
	pairs.assign(h_target.begin(), h_target.end());
	return 1;
}

bool generate_pairs_deep(std::vector<uint32_t>& keys, std::vector<uint32_t>& values, std::vector<pair_t>& pairs){
	T_DV<pair_t> d_target;
	generate_pairs_deep(T_DV<pair_t>(T_MTI(T_MZIMT(keys.begin(), values.begin()), pair_create()), T_MTI(T_MZIMT(keys.end(), values.end()), pair_create())), d_target);
	T_HV<pair_t> h_target(d_target.begin(), d_target.end());
	pairs.assign(h_target.begin(), h_target.end());
	return 1;
}


/* generates degree deep
* parameter: mirrored, sorted
*/
bool generate_pairs_deep(T_DV<pair_t>& d_keys_value, T_DV<pair_t>& d_target){
	T_DV<uint32_t> d_firsts, d_degree;
	if (!get_degree_mirror(T_DV<uint32_t>(T_MTI(d_keys_value.begin(), first_element()), T_MTI(d_keys_value.end(), first_element())), d_degree))return 0;
	if (!get_firsts(d_degree, d_firsts))return 0;
	return generate_pairs_deep(d_keys_value.begin(), d_keys_value.end(), d_firsts, d_degree, d_target);
}

/* generates degree deep
* parameter: mirrored, sorted
*/
bool generate_pairs_deep(T_DV<pair_t>::iterator d_keys_value_first, T_DV<pair_t>::iterator d_keys_value_last, T_DV<uint32_t> &d_firsts, T_DV<uint32_t> &d_degree, T_DV<pair_t>& d_target){
	// generate pairs init
	uint32_t max_size = get_max_combination(d_degree.begin(), d_degree.end());
	if (max_size < 1)return 1;

	// generate pairs main
	d_target.assign(max_size, pair_t(0, 0));
	
	uint32_t offset = 0;
	d_firsts.push_back(d_firsts.back() + d_degree.back()); // add last
	for (uint32_t i = 0; i < d_firsts.size() - 1; ++i){
		T_DV<uint32_t> values(
			T_MPI(T_MTI(d_keys_value_first, second_element()), T_MCI<uint32_t>(d_firsts[i])),
			T_MPI(T_MTI(d_keys_value_first, second_element()), T_MCI<uint32_t>(d_firsts[i + 1]))
			);
		uint32_t n_elements = d_degree[i] * (d_degree[i] - 1)*0.5;
		get_pairs(0, n_elements, d_degree[i], values, d_target, offset);
		offset += n_elements;

	}
	d_firsts.erase(d_firsts.end() - 1);

	return 1;
}

/* changes
* parameter: mirrored, sorted
*/
bool generate_pairs(T_DV<pair_t>& d_keys_value, T_DV<pair_t>& d_pairs){
	return generate_pairs(d_keys_value.begin(), d_keys_value.end(), d_pairs);
}

/* changes
* parameter: mirrored, sorted
*/
bool generate_pairs_limit(T_DV<pair_t>& d_keys_value, T_DV<pair_t>& d_pairs, uint32_t& offStart, uint32_t limit, bool& done){
	return generate_pairs_limit(d_keys_value.begin(), d_keys_value.end(), d_pairs, offStart, limit, done);
}

/* changes
* parameter: mirrored, sorted, offset
*/
bool generate_pairs_limit(T_DV<pair_t>::iterator d_keys_value_first, T_DV<pair_t>::iterator d_keys_value_last, T_DV<pair_t>& d_pairs, uint32_t& offStart, uint32_t limit, bool& done){
	d_pairs.clear();
	thrust::sort(d_keys_value_first, d_keys_value_last);
	d_keys_value_last = thrust::unique(d_keys_value_first, d_keys_value_last);
	uint32_t degree = d_keys_value_last - d_keys_value_first;
	uint32_t max_size = degree * (degree - 1) * 0.5;

	// generate pairs init
	if (max_size < 1){
		done = 1;
		return 1;
	}
	// size calculation
	T_DV<uint32_t>sizes(degree);
	thrust::sequence(sizes.begin(), sizes.end(), (int)degree, -1);
	thrust::exclusive_scan(sizes.begin(), sizes.end(), sizes.begin());
	// generate pairs main
	uint32_t off = offStart + 1;
	uint32_t intervals = degree;

	d_pairs.assign(limit, pair_t(0, 0));
	T_DV<pair_t>::iterator new_end = d_pairs.begin();
	//display_vector<uint32_t>(sizes, "sizes");
	while (off < intervals){
		if (sizes[off] - sizes[offStart] > limit){
			break;
		}
		new_end = thrust::copy_if(
			T_MTI(
			T_MZIMT(
			T_MTI(d_keys_value_first, second_element()),
			T_MTI(d_keys_value_first + off, second_element())),
			pair_create_sort()),
			T_MTI(
			T_MZIMT(
			T_MTI(d_keys_value_first + degree - off, second_element()),
			T_MTI(d_keys_value_first + degree, second_element())),
			pair_create_sort()),
			T_MCI<uint32_t>(0),
			new_end,
			equal_to_next(T_DEREF(d_keys_value_first, pair_t), degree, off));
		off += 1;
	}
	offStart = off - 1;
	if (off == intervals)
		done = true;
	d_pairs.erase(thrust::remove(d_pairs.begin(), d_pairs.end(), pair_t(0, 0)), d_pairs.end());
	d_pairs.erase(thrust::remove_if(d_pairs.begin(), d_pairs.end(), is_loop_pair()), d_pairs.end());
	return 1;
}

/* changes
* parameter: mirrored, sorted
*/
bool generate_pairs(T_DV<pair_t>::iterator d_keys_value_first, T_DV<pair_t>::iterator d_keys_value_last, T_DV<pair_t>& d_pairs){
	d_pairs.clear();
	thrust::sort(d_keys_value_first, d_keys_value_last);
	d_keys_value_last = thrust::unique(d_keys_value_first, d_keys_value_last);
	T_DV<uint32_t> d_degree;
	if (!get_degree_mirror(T_DV<uint32_t>(
		T_MTI(d_keys_value_first, first_element()),
		T_MTI(d_keys_value_last, first_element())), d_degree))return 0;
	// generate pairs init
	uint32_t max_size = get_max_combination(d_degree.begin(), d_degree.end());
	if (max_size < 1)return 1;
	// generate pairs main
	uint32_t size = d_keys_value_last - d_keys_value_first;
	uint32_t off = 1;
	uint32_t intervals = *thrust::max_element(d_degree.begin(), d_degree.end());
	T_CLEAR(d_degree, uint32_t);
	d_pairs.assign(max_size, pair_t(0, 0));
	T_DV<pair_t>::iterator new_end = d_pairs.begin();
	//printf("first: %lu \n", (pair_t(*(d_keys_value_first + size - 1))).first, (pair_t(*(d_keys_value_first + size - 1))).second);
	for (uint32_t i = 0; i < size; ++i){
		//printf("%lu:%lu, ", (pair_t(*(d_keys_value_first + i))).first, (pair_t(*(d_keys_value_first + i))).second);
	}
	//display_direct(T_DEREF(d_keys_value_first, pair_t), T_DEREF(d_keys_value_last, pair_t), "c");
	while (off < intervals){
		T_TRYCATCH(
			new_end = thrust::copy_if(thrust::device,
			T_MTI(
			T_MZIMT(
			T_MTI(d_keys_value_first, second_element()),
			T_MTI(d_keys_value_first + off, second_element())),
			pair_create_sort()),
			T_MTI(
			T_MZIMT(
			T_MTI(d_keys_value_first + size - off, second_element()),
			T_MTI(d_keys_value_first + size, second_element())),
			pair_create_sort()),
			T_MCI<uint32_t>(0),
			new_end,
			equal_to_next(T_DEREF(d_keys_value_first, pair_t), size, off));
			);
		off += 1;
	}
	d_pairs.erase(thrust::remove_if(d_pairs.begin(), d_pairs.end(), is_loop_pair()), d_pairs.end());

	return 1;
}

bool generate_pairs(T_DV<uint32_t>& d_keys, T_DV<uint32_t>& d_values, T_DV<pair_t>& d_pairs){
	return generate_pairs(d_keys.begin(), d_keys.end(), d_values.begin(), d_values.end(), d_pairs);
}

/* takes mirrored
 */
bool generate_pairs(T_DV<uint32_t>::iterator d_keys_first, T_DV<uint32_t>::iterator d_keys_last, T_DV<uint32_t>::iterator d_values_first, T_DV<uint32_t>::iterator d_values_last, T_DV<pair_t>& d_pairs){
	return generate_pairs(
		T_DV<pair_t>(
			T_MTI(T_MZIMT(d_keys_first, d_values_first),pair_create()),
			T_MTI(T_MZIMT(d_keys_last, d_values_last),pair_create())),
			d_pairs
		);
}

bool pair_create_constant(uint32_t constant, uint32_t start, uint32_t end, T_DV<uint32_t>& values, T_DV<pair_t>::iterator target){
	thrust::transform(
		T_MPI(values.begin(), T_MCI<uint32_t>(start)),
		T_MPI(values.begin(), T_MCI<uint32_t>(end)),
		target,
		pair_create_const(values[constant])
		);
	return 1;
}

__host__ __device__ pair_t get_pair(const uint32_t& x, uint32_t& n){
	uint32_t count = 0;
	uint32_t k = n - 1;
	uint32_t old = 0;
	for (uint32_t j = n - 1; j > 0; j += --k){
		if (x < j){
			break;
		}
		++count;
		old = j;
	}
	return pair_t((uint32_t)count, (uint32_t)x - old + 1 + count);
}

/*
Used to get pairs from from to to in tree n.
n - tree-size
values - relevant value
target - contains relevant pairs afterwards
offset - stores result in target beginning with offset

example: (0, 3, 4,_, 1) stores [_, (0,1),(0,2),(0,3),(1,2)]

*/
bool get_pairs(const uint32_t& from, const uint32_t& to, uint32_t n, T_DV<uint32_t>& values, T_DV<pair_t>& target, uint32_t offset){

	pair_t f = get_pair(from, n);
	pair_t t = get_pair(to, n);
	pair_t tpre = get_pair(to - 1, n);

	// current part
	pair_create_constant(f.first, f.second, n, values, target.begin() + offset);
	uint32_t c = n - f.second;

	// till t.first
	for (uint32_t i = f.first + 1; i < tpre.first; ++i){
		pair_create_constant(i, i + 1, n, values, target.begin() + c + offset);
		c += n - (i + 1);
	}

	if (to > 1)
		pair_create_constant(tpre.first, tpre.first + 1, tpre.second + 1, values, target.begin() + c + offset);

	return 1;
}