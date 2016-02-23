#pragma once

#ifdef HOSTPAIRCONSTRUCTDLL_EXPORTS
#define HOSTPAIRCONSTRUCTDLL_API __declspec(dllexport) 
#else
#define HOSTPAIRCONSTRUCTDLL_API __declspec(dllimport) 
#endif

namespace comevohost{

	HOSTPAIRCONSTRUCTDLL_API bool generate_pairs_deep(std::vector<uint32_t>& keys, std::vector<uint32_t>& values, std::vector<pair_t>& pairs);

	HOSTPAIRCONSTRUCTDLL_API bool generate_pairs_deep(T_HV<pair_t>& h_keys_value, T_HV<pair_t>& h_target);

	HOSTPAIRCONSTRUCTDLL_API bool generate_pairs_deep(T_HV<pair_t>::iterator h_keys_value_first, T_HV<pair_t>::iterator h_keys_value_last, T_HV<uint32_t> &h_firsts, T_HV<uint32_t> &h_degree, T_HV<pair_t>& h_target);

	/* takes mirrored
	* parameter: mirrored, sorted
	*/
	HOSTPAIRCONSTRUCTDLL_API bool generate_pairs(T_HV<pair_t>& h_keys_value, T_HV<pair_t>& h_pairs);

	/* changes
	* parameter: mirrored, sorted, offset
	*/
	HOSTPAIRCONSTRUCTDLL_API bool generate_pairs_limit(T_HV<pair_t>& h_keys_value, T_HV<pair_t>& h_pairs, uint32_t& offStart, uint32_t limit, bool& done);

	/* changes
	* parameter: mirrored, sorted, offset
	*/
	HOSTPAIRCONSTRUCTDLL_API bool generate_pairs_limit(T_HV<pair_t>::iterator h_keys_value_first, T_HV<pair_t>::iterator h_keys_value_last, T_HV<pair_t>& h_pairs, uint32_t& offStart, uint32_t limit, bool& done);

	bool generate_pairs(T_HV<pair_t>::iterator h_keys_value_first, T_HV<pair_t>::iterator h_keys_value_last, T_HV<pair_t>& h_pairs);

	HOSTPAIRCONSTRUCTDLL_API bool generate_pairs(std::vector<uint32_t>& keys, std::vector<uint32_t>& values, std::vector<pair_t>& pairs);
	HOSTPAIRCONSTRUCTDLL_API bool generate_pairs(T_HV<uint32_t>& h_keys, T_HV<uint32_t>& h_values, T_HV<pair_t>& h_pairs);
	bool generate_pairs(T_HV<uint32_t>::iterator h_keys_first, T_HV<uint32_t>::iterator h_keys_last, T_HV<uint32_t>::iterator h_values_first, T_HV<uint32_t>::iterator h_values_last, T_HV<pair_t>& h_pairs);

	HOSTPAIRCONSTRUCTDLL_API bool generate_unique_pairs(std::vector<uint32_t>& keys, std::vector<uint32_t>& values, std::vector<pair_t>& pairs);

	bool pair_create_constant(uint32_t constant, uint32_t start, uint32_t end, T_HV<uint32_t>& values, T_HV<pair_t>::iterator target);
	__host__ __device__ pair_t get_pair(const uint32_t& x, uint32_t& n);
	HOSTPAIRCONSTRUCTDLL_API bool get_pairs(const uint32_t& from, const uint32_t& to, uint32_t n, T_HV<uint32_t>& values, T_HV<pair_t>& target, uint32_t offset);
}