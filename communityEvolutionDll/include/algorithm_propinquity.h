#pragma once

#ifdef ARCH_WINDOWS
#ifdef ALGORITHMPROPINQUITYDLL_EXPORTS
#define ALGORITHMPROPINQUITYDLL_API __declspec(dllexport) 
#else
#define ALGORITHMPROPINQUITYDLL_API __declspec(dllimport) 
#endif
#else
#define ALGORITHMPROPINQUITYDLL_API __attribute__ ((visibility ("default")))
#endif

#include "data_source.h"

struct Threshold{
	uint8_t alpha, beta;
	Threshold(uint8_t alpha, uint8_t beta) : alpha(alpha), beta(beta){}
};

ALGORITHMPROPINQUITYDLL_API void setStorageCounter(uint32_t value);

ALGORITHMPROPINQUITYDLL_API uint32_t getStorageCounter();

ALGORITHMPROPINQUITYDLL_API bool compress_files();

ALGORITHMPROPINQUITYDLL_API T_DV<pair_t> get_specific_pairs(T_DV<pair_t> &d_pairs, T_DV<uint32_t> &d_firsts, T_DV<uint32_t> &d_degree, T_DV<uint32_t> &d_id);

ALGORITHMPROPINQUITYDLL_API bool couple_increment(T_DV<pair_t> &d_pairs, T_DV<uint32_t> &d_degree, T_DV<uint32_t> &d_firsts, uint32_t limit);

ALGORITHMPROPINQUITYDLL_API bool calculate_propinquity(T_HV<pair_t>& h_pairs);

ALGORITHMPROPINQUITYDLL_API bool update_propinquity(T_HV<pair_t>& h_pairs, Threshold &threshold, T_HV<uint32_t>& h_propinquity);

ALGORITHMPROPINQUITYDLL_API bool bfs(T_DV<pair_t>& d_pairs, T_DV<uint8_t>& propinquities, uint32_t minimum,  snapshot_t& communities);

ALGORITHMPROPINQUITYDLL_API bool algorithm_propinquity(comevo::Source &source, comevo::Source &target, uint32_t from, uint32_t to, Threshold &threshold, uint32_t bfsMinimum, uint32_t maxIterations, uint32_t max_snap);
