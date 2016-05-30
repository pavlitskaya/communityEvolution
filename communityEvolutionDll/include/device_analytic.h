#pragma once

#ifdef ARCH_WINDOWS
#ifdef DEVICEANALYTICDLL_EXPORTS
#define DEVICEANALYTICDLL_API __declspec(dllexport) 
#else
#define DEVICEANALYTICDLL_API __declspec(dllimport) 
#endif
#else
#define DEVICEANALYTICDLL_API __attribute__ ((visibility ("default")))
#endif

#include "general_pair_structs.h"
#include "general_defines.h"
#include "data_source.h"
#include <thrust/device_vector.h>

DEVICEANALYTICDLL_API uint32_t get_number_of_diff_elements(T_DV<uint32_t>& d_source);
DEVICEANALYTICDLL_API uint32_t get_number_of_diff_elements(T_DV<uint32_t>::iterator d_source_first, T_DV<uint32_t>::iterator d_source_last);

DEVICEANALYTICDLL_API uint32_t get_number_of_diff_elements(T_DV<pair_t>& d_source);
DEVICEANALYTICDLL_API uint32_t get_number_of_diff_elements(T_DV<pair_t>::iterator d_source_first, T_DV<pair_t>::iterator d_source_last);

/* gets degree of equal elements (sort required)
*/
DEVICEANALYTICDLL_API bool get_degree_mirror(T_DV<pair_t>& d_source, T_DV<uint32_t>& d_degree);
DEVICEANALYTICDLL_API bool get_degree_mirror(T_DV<uint32_t>& d_source, T_DV<uint32_t>& d_degree);
DEVICEANALYTICDLL_API bool get_degree_mirror(T_DV<uint32_t>::iterator d_source_first, T_DV<uint32_t>::iterator d_source_last, T_DV<uint32_t>& d_degree);

DEVICEANALYTICDLL_API bool get_count(T_DV<pair_t>::iterator d_source_first, T_DV<pair_t>::iterator d_source_last, T_DV<pair_t>& d_unique_pairs, T_DV<uint32_t>& d_unique_count);
DEVICEANALYTICDLL_API bool get_count(T_DV<pair_t>& d_source, T_DV<pair_t>& d_unique_pairs, T_DV<uint32_t>& d_unique_count);

DEVICEANALYTICDLL_API bool get_degree(T_DV<pair_t>& d_source, T_DV<uint32_t>& d_degree);

/* gets degree of equal elements (sort required)
*/
DEVICEANALYTICDLL_API bool get_firsts(T_DV<uint32_t>& d_degree, T_DV<uint32_t>& d_firsts);

/* gets degree of equal elements (sort required)
*/
DEVICEANALYTICDLL_API bool get_lasts(T_DV<uint32_t>& d_degree, T_DV<uint32_t>& d_lasts);

DEVICEANALYTICDLL_API bool get_nodes(T_DV<pair_t>& d_pairs, T_DV<uint32_t>& d_firsts, T_DV<uint32_t>& d_nodes);

/* 0.5* x*(x-1)
*/
DEVICEANALYTICDLL_API T_DV<uint32_t> get_max_combinations(T_DV<uint32_t>& d_degree);

/* 0.5* SUM x*(x-1)
*/
DEVICEANALYTICDLL_API uint32_t get_max_combination(T_DV<uint32_t>& d_degree);

DEVICEANALYTICDLL_API uint32_t get_max_combination(T_DV<uint32_t>::iterator d_degree_first, T_DV<uint32_t>::iterator d_degree_last);

DEVICEANALYTICDLL_API T_DV<uint32_t> get_max_combinations_scanned(T_DV<uint32_t>& d_degree);
DEVICEANALYTICDLL_API bool get_intersection(T_DV<pair_t>& d_pairs, T_DV<pair_t>& d_pairs_mirror, T_DV<pair_t>& d_target_mirror, T_DV<uint32_t>& d_target_degree);

DEVICEANALYTICDLL_API bool get_modularity(comevo::Source& sPairs, comevo::Source& sSnaps, uint32_t snapId, float &Q);
