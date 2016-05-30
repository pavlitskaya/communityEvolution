#include "stdafx.h"
#include "include/host_pair_construct.h"
#include "include/host_analytic.h"
#include "include/general_arithmetic_structs.h"
#include "include/device_pair_structs.h"
#include "include/general_comparsion_structs.h"
#include "include/display_elements.h"
#include "include/general_pair_structs.h"
#include "include/host_pair.h"

using namespace std;

namespace comevohost{

	// takes mirrored
	bool generate_pairs(std::vector<uint32_t>& keys, std::vector<uint32_t>& values, std::vector<pair_t>& pairs){
		T_HV<pair_t> h_target;
        T_HV<uint32_t> h_keys(keys.begin(), keys.end());
        T_HV<uint32_t> h_values(values.begin(), values.end());
        generate_pairs(h_keys, h_values, h_target);
		pairs.assign(h_target.begin(), h_target.end());
		return 1;
	}

	bool generate_unique_pairs(std::vector<uint32_t>& keys, std::vector<uint32_t>& values, std::vector<pair_t>& pairs){
		T_HV<pair_t> h_target;
        T_HV<uint32_t> h_keys(keys.begin(), keys.end());
        T_HV<uint32_t> h_values(values.begin(), values.end());
        generate_pairs(h_keys, h_values, h_target);
		thrust::sort(h_target.begin(), h_target.end());
		h_target.resize(thrust::unique(h_target.begin(), h_target.end()) - h_target.begin());
		pairs.assign(h_target.begin(), h_target.end());
		return 1;
	}

	bool generate_pairs_deep(std::vector<uint32_t>& keys, std::vector<uint32_t>& values, std::vector<pair_t>& pairs){
		T_HV<pair_t> h_target;
        T_HV<pair_t> h_pair(T_MTI(T_MZIMT(keys.begin(), values.begin()), pair_create()), T_MTI(T_MZIMT(keys.end(), values.end()), pair_create()));
        generate_pairs_deep(h_pair, h_target);
		pairs.assign(h_target.begin(), h_target.end());
		return 1;
	}


	/* generates degree deep
	* parameter: mirrored, sorted
	*/
	bool generate_pairs_deep(T_HV<pair_t>& h_keys_value, T_HV<pair_t>& h_target){
		T_HV<uint32_t> h_firsts, h_degree;
        T_HV<uint32_t> h_keys(T_MTI(h_keys_value.begin(), first_element()), T_MTI(h_keys_value.end(), first_element()));
        if (!get_degree_mirror(h_keys, h_degree))return 0;
		if (!get_firsts(h_degree, h_firsts))return 0;
		return generate_pairs_deep(h_keys_value.begin(), h_keys_value.end(), h_firsts, h_degree, h_target);
	}

	/* generates degree deep
	* parameter: mirrored, sorted
	*/
	bool generate_pairs_deep(T_HV<pair_t>::iterator h_keys_value_first, T_HV<pair_t>::iterator h_keys_value_last, T_HV<uint32_t> &h_firsts, T_HV<uint32_t> &h_degree, T_HV<pair_t>& h_target){
		// generate pairs init
		uint32_t max_size = get_max_combination(h_degree.begin(), h_degree.end());
		if (max_size < 1)return 1;

		// generate pairs main
		h_target.assign(max_size, pair_t(0, 0));

		uint32_t offset = 0;
		h_firsts.push_back(h_firsts.back() + h_degree.back()); // add last
		for (uint32_t i = 0; i < h_firsts.size() - 1; ++i){
			T_HV<uint32_t> values(
				T_MPI(T_MTI(h_keys_value_first, second_element()), T_MCI<uint32_t>(h_firsts[i])),
				T_MPI(T_MTI(h_keys_value_first, second_element()), T_MCI<uint32_t>(h_firsts[i + 1]))
				);
			uint32_t n_elements = h_degree[i] * (h_degree[i] - 1)*0.5;
			get_pairs(0, n_elements, h_degree[i], values, h_target, offset);
			offset += n_elements;

		}
		h_firsts.erase(h_firsts.end() - 1);

		return 1;
	}

	/* changes
	* parameter: mirrored, sorted
	*/
	bool generate_pairs(T_HV<pair_t>& h_keys_value, T_HV<pair_t>& h_pairs){
		return generate_pairs(h_keys_value.begin(), h_keys_value.end(), h_pairs);
	}

	/* changes
	* parameter: mirrored, sorted
	*/
	bool generate_pairs_limit(T_HV<pair_t>& h_keys_value, T_HV<pair_t>& h_pairs, uint32_t& offStart, uint32_t limit, bool& done){
		return generate_pairs_limit(h_keys_value.begin(), h_keys_value.end(), h_pairs, offStart, limit, done);
	}

	/* changes
	* parameter: mirrored, sorted, offset
	*/
	bool generate_pairs_limit(T_HV<pair_t>::iterator h_keys_value_first, T_HV<pair_t>::iterator h_keys_value_last, T_HV<pair_t>& h_pairs, uint32_t& offStart, uint32_t limit, bool& done){
		h_pairs.clear();
		uint32_t degree = h_keys_value_last - h_keys_value_first;
		uint32_t max_size = degree * (degree - 1) * 0.5;

		// generate pairs init
		if (max_size < 1){
			done = 1;
			return 1;
		}
		// size calculation
		T_HV<uint32_t>sizes(degree);
		thrust::sequence(sizes.begin(), sizes.end(), (int)degree, -1);
		thrust::exclusive_scan(sizes.begin(), sizes.end(), sizes.begin());
		// generate pairs main
		uint32_t off = offStart + 1;
		uint32_t intervals = degree;

		h_pairs.assign(limit, pair_t(0, 0));
		T_HV<pair_t>::iterator new_end = h_pairs.begin();
		//display_vector<uint32_t>(sizes, "sizes");
		while (off < intervals){
			if (sizes[off] - sizes[offStart] > limit){
				break;
			}
			new_end = thrust::copy_if(
				T_MTI(
				T_MZIMT(
				T_MTI(h_keys_value_first, second_element()),
				T_MTI(h_keys_value_first + off, second_element())),
				pair_create_sort()),
				T_MTI(
				T_MZIMT(
				T_MTI(h_keys_value_first + degree - off, second_element()),
				T_MTI(h_keys_value_first + degree, second_element())),
				pair_create_sort()),
				T_MCI<uint32_t>(0),
				new_end,
				equal_to_next(T_DEREF(h_keys_value_first, pair_t), degree, off));
			off += 1;
		}
		offStart = off - 1;
		if (off == intervals)
			done = true;
		h_pairs.erase(thrust::remove(h_pairs.begin(), h_pairs.end(), pair_t(0, 0)), h_pairs.end());
		h_pairs.erase(thrust::remove_if(h_pairs.begin(), h_pairs.end(), is_loop_pair()), h_pairs.end());
		return 1;
	}

	/* changes
	* parameter: mirrored, sorted
	*/
	bool generate_pairs(T_HV<pair_t>::iterator h_keys_value_first, T_HV<pair_t>::iterator h_keys_value_last, T_HV<pair_t>& h_pairs){
		h_pairs.clear();
		T_HV<uint32_t> h_degree;
        T_HV<uint32_t> h_keys(T_MTI(h_keys_value_first, first_element()), T_MTI(h_keys_value_last, first_element()));
        if (!get_degree_mirror(h_keys, h_degree)) return 0;

		// generate pairs init
		uint32_t max_size = get_max_combination(h_degree.begin(), h_degree.end());
		if (max_size < 1)return 1;
		// generate pairs main

		uint32_t size = h_keys_value_last - h_keys_value_first;
		uint32_t off = 1;
		uint32_t intervals = *thrust::max_element(h_degree.begin(), h_degree.end());
		TH_CLEAR(h_degree, uint32_t);
		h_pairs.assign(max_size, pair_t(0, 0));
		T_HV<pair_t>::iterator new_end = h_pairs.begin();
		while (off < intervals){
			new_end = thrust::copy_if(
				T_MTI(
				T_MZIMT(
				T_MTI(h_keys_value_first, second_element()),
				T_MTI(h_keys_value_first + off, second_element())),
				pair_create_sort()),
				T_MTI(
				T_MZIMT(
				T_MTI(h_keys_value_first + size - off, second_element()),
				T_MTI(h_keys_value_first + size, second_element())),
				pair_create_sort()),
				T_MCI<uint32_t>(0),
				new_end,
				equal_to_next(T_DEREF(h_keys_value_first, pair_t), size, off));
			off += 1;
		}

		h_pairs.erase(thrust::remove_if(h_pairs.begin(), h_pairs.end(), is_loop_pair()), h_pairs.end());

		return 1;
	}

	bool generate_pairs(T_HV<uint32_t>& h_keys, T_HV<uint32_t>& h_values, T_HV<pair_t>& h_pairs){
		return generate_pairs(h_keys.begin(), h_keys.end(), h_values.begin(), h_values.end(), h_pairs);
	}

	/* takes mirrored
	*/
	bool generate_pairs(T_HV<uint32_t>::iterator h_keys_first, T_HV<uint32_t>::iterator h_keys_last, T_HV<uint32_t>::iterator h_values_first, T_HV<uint32_t>::iterator h_values_last, T_HV<pair_t>& h_pairs){
        T_HV<pair_t> h_keys(T_MTI(T_MZIMT(h_keys_first, h_values_first), pair_create()), T_MTI(T_MZIMT(h_keys_last, h_values_last), pair_create()));

        return generate_pairs(h_keys, h_pairs);
	}

	bool pair_create_constant(uint32_t constant, uint32_t start, uint32_t end, T_HV<uint32_t>& values, T_HV<pair_t>::iterator target){
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
	bool get_pairs(const uint32_t& from, const uint32_t& to, uint32_t n, T_HV<uint32_t>& values, T_HV<pair_t>& target, uint32_t offset){

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
}
