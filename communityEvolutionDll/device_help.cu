#include "stdafx.h"
#include "include/device_help.h"
#include "include/general_pair_structs.h"

namespace comevo{
	template <typename T> bool back_inserter(T_HV<T>& h_vec, T value){
		h_vec.push_back(value);
		return 1;
	}
	template bool back_inserter<uint32_t>(T_HV<uint32_t>&, uint32_t);
	template bool back_inserter<pair_t>(T_HV<pair_t>&, pair_t);

	bool fill_pair_vector(std::vector<uint32_t>& vecFirst, std::vector<uint32_t>& vecSecond, T_HV<pair_t>& h_vec){
		h_vec.resize(vecFirst.size());
		thrust::copy(T_MTI(T_MZIMT(vecFirst.begin(), vecSecond.begin()), pair_create()), T_MTI(T_MZIMT(vecFirst.end(), vecSecond.end()), pair_create())
			, h_vec.begin());
		return 1;
	}

	template <typename T> bool fill_vector(std::vector<T>& vec, T_HV<T>& h_vec){
		h_vec.resize(vec.size());
		thrust::copy(vec.begin(), vec.end(), h_vec.begin());
		return 1;
	}
	template bool fill_vector<uint32_t>(std::vector<uint32_t>& vec, T_HV<uint32_t>& h_vec);
	template bool fill_vector<pair_t>(std::vector<pair_t>& vec, T_HV<pair_t>& h_vec);

	template <typename T> bool allocate_vector(T_HV<T>& h_vec, uint32_t size){
		h_vec.resize(size);
		return 1;
	}
	template bool allocate_vector<uint32_t>(T_HV<uint32_t>& h_vec, uint32_t size);
	template bool allocate_vector<pair_t>(T_HV<pair_t>& h_vec, uint32_t size);
	

}