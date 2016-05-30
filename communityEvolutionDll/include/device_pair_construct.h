#pragma once

#ifdef ARCH_WINDOWS
#ifdef DEVICEPAIRCONSTRUCTDLL_EXPORTS
#define DEVICEPAIRCONSTRUCTDLL_API __declspec(dllexport) 
#else
#define DEVICEPAIRCONSTRUCTDLL_API __declspec(dllimport) 
#endif
#else
#define DEVICEPAIRCONSTRUCTDLL_API __attribute__ ((visibility ("default")))
#endif

DEVICEPAIRCONSTRUCTDLL_API bool generate_pairs_deep(std::vector<uint32_t>& keys, std::vector<uint32_t>& values, std::vector<pair_t>& pairs);

DEVICEPAIRCONSTRUCTDLL_API bool generate_pairs_deep(T_DV<pair_t>& d_keys_value, T_DV<pair_t>& d_target);

DEVICEPAIRCONSTRUCTDLL_API bool generate_pairs_deep(T_DV<pair_t>::iterator d_keys_value_first, T_DV<pair_t>::iterator d_keys_value_last, T_DV<uint32_t> &d_firsts, T_DV<uint32_t> &d_degree, T_DV<pair_t>& d_target);

/* takes mirrored
* parameter: mirrored, sorted
*/
DEVICEPAIRCONSTRUCTDLL_API bool generate_pairs(T_DV<pair_t>& d_keys_value, T_DV<pair_t>& d_pairs);

/* changes
* parameter: mirrored, sorted, offset
*/
DEVICEPAIRCONSTRUCTDLL_API bool generate_pairs_limit(T_DV<pair_t>& d_keys_value, T_DV<pair_t>& d_pairs, uint32_t& offStart, uint32_t limit, bool& done);

/* changes
* parameter: mirrored, sorted, offset
*/
DEVICEPAIRCONSTRUCTDLL_API bool generate_pairs_limit(T_DV<pair_t>::iterator d_keys_value_first, T_DV<pair_t>::iterator d_keys_value_last, T_DV<pair_t>& d_pairs, uint32_t& offStart, uint32_t limit, bool& done);

bool generate_pairs(T_DV<pair_t>::iterator d_keys_value_first, T_DV<pair_t>::iterator d_keys_value_last, T_DV<pair_t>& d_pairs);

DEVICEPAIRCONSTRUCTDLL_API bool generate_pairs(std::vector<uint32_t>& keys, std::vector<uint32_t>& values, std::vector<pair_t>& pairs);
DEVICEPAIRCONSTRUCTDLL_API bool generate_pairs(T_DV<uint32_t>& d_keys, T_DV<uint32_t>& d_values, T_DV<pair_t>& d_pairs);
bool generate_pairs(T_DV<uint32_t>::iterator d_keys_first, T_DV<uint32_t>::iterator d_keys_last, T_DV<uint32_t>::iterator d_values_first, T_DV<uint32_t>::iterator d_values_last, T_DV<pair_t>& d_pairs);

DEVICEPAIRCONSTRUCTDLL_API bool generate_unique_pairs(std::vector<uint32_t>& keys, std::vector<uint32_t>& values, std::vector<pair_t>& pairs);

bool pair_create_constant(uint32_t constant, uint32_t start, uint32_t end, T_DV<uint32_t>& values, T_DV<pair_t>::iterator target);
__host__ __device__ pair_t get_pair(const uint32_t& x, uint32_t& n);
DEVICEPAIRCONSTRUCTDLL_API bool get_pairs(const uint32_t& from, const uint32_t& to, uint32_t n, T_DV<uint32_t>& values, T_DV<pair_t>& target, uint32_t offset);
