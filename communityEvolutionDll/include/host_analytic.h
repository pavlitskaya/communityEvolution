#pragma once

#ifdef ARCH_WINDOWS
#ifdef HOSTANALYTICDLL_EXPORTS
#define HOSTANALYTICDLL_API __declspec(dllexport) 
#else
#define HOSTANALYTICDLL_API __declspec(dllimport) 
#endif
#else
#define HOSTANALYTICDLL_API __attribute__ ((visibility ("default")))
#endif

#include "general_pair_structs.h"
#include "general_defines.h"
#include "data_source.h"
#include <thrust/device_vector.h>

namespace comevohost{

	HOSTANALYTICDLL_API uint32_t get_number_of_diff_elements(T_HV<uint32_t>& h_source);
	HOSTANALYTICDLL_API uint32_t get_number_of_diff_elements(T_HV<uint32_t>::iterator h_source_first, T_HV<uint32_t>::iterator h_source_last);

	HOSTANALYTICDLL_API uint32_t get_number_of_diff_elements(T_HV<pair_t>& h_source);
	HOSTANALYTICDLL_API uint32_t get_number_of_diff_elements(T_HV<pair_t>::iterator h_source_first, T_HV<pair_t>::iterator h_source_last);

	/* gets degree of equal elements (sort required)
	*/
	HOSTANALYTICDLL_API bool get_degree_mirror(T_HV<pair_t>& h_source, T_HV<uint32_t>& h_degree);
	HOSTANALYTICDLL_API bool get_degree_mirror(T_HV<uint32_t>& h_source, T_HV<uint32_t>& h_degree);
	HOSTANALYTICDLL_API bool get_degree_mirror(T_HV<uint32_t>::iterator h_source_first, T_HV<uint32_t>::iterator h_source_last, T_HV<uint32_t>& h_degree);

	HOSTANALYTICDLL_API bool get_count(T_HV<pair_t>::iterator h_source_first, T_HV<pair_t>::iterator h_source_last, T_HV<pair_t>& h_unique_pairs, T_HV<uint32_t>& h_unique_count);
	HOSTANALYTICDLL_API bool get_count(T_HV<pair_t>& h_source, T_HV<pair_t>& h_unique_pairs, T_HV<uint32_t>& h_unique_count);

	HOSTANALYTICDLL_API bool get_degree(T_HV<pair_t>& h_source, T_HV<uint32_t>& h_degree);

	/* gets degree of equal elements (sort required)
	*/
	HOSTANALYTICDLL_API bool get_firsts(T_HV<uint32_t>& h_degree, T_HV<uint32_t>& h_firsts);

	/* gets degree of equal elements (sort required)
	*/
	HOSTANALYTICDLL_API bool get_lasts(T_HV<uint32_t>& h_degree, T_HV<uint32_t>& h_lasts);

	HOSTANALYTICDLL_API bool get_nodes(T_HV<pair_t>& h_pairs, T_HV<uint32_t>& h_firsts, T_HV<uint32_t>& h_nodes);

	/* 0.5* x*(x-1)
	*/
	HOSTANALYTICDLL_API T_HV<uint32_t> get_max_combinations(T_HV<uint32_t>& h_degree);

	/* 0.5* SUM x*(x-1)
	*/
	HOSTANALYTICDLL_API uint32_t get_max_combination(T_HV<uint32_t>& h_degree);

	HOSTANALYTICDLL_API uint32_t get_max_combination(T_HV<uint32_t>::iterator h_degree_first, T_HV<uint32_t>::iterator h_degree_last);

	HOSTANALYTICDLL_API T_HV<uint32_t> get_max_combinations_scanned(T_HV<uint32_t>& h_degree);
	HOSTANALYTICDLL_API bool get_intersection(T_HV<pair_t>& h_pairs, T_HV<pair_t>& h_pairs_mirror, T_HV<pair_t>& h_target_mirror, T_HV<uint32_t>& h_target_degree);

	HOSTANALYTICDLL_API void get_modularity(comevo::Source sPairs, comevo::Source sSnaps, uint32_t snapId, float &Q);

}
