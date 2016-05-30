#pragma once

#ifdef ARCH_WINDOWS
#ifdef HOSTALGORITHMPROPINQUITYDLL_EXPORTS
#define HOSTALGORITHMPROPINQUITYDLL_API __declspec(dllexport) 
#else
#define HOSTALGORITHMPROPINQUITYDLL_API __declspec(dllimport) 
#endif
#else
#define HOSTALGORITHMPROPINQUITYDLL_API __attribute__ ((visibility ("default")))
#endif

#include "data_source.h"

namespace comevohost{

	struct Threshold{
		uint8_t alpha, beta;
		Threshold(uint8_t alpha, uint8_t beta) : alpha(alpha), beta(beta){}
	};

	HOSTALGORITHMPROPINQUITYDLL_API void setStorageCounter(uint32_t value);

	HOSTALGORITHMPROPINQUITYDLL_API uint32_t getStorageCounter();

	HOSTALGORITHMPROPINQUITYDLL_API bool compress_files();

	HOSTALGORITHMPROPINQUITYDLL_API T_HV<pair_t> get_specific_pairs(T_HV<pair_t> &h_pairs, T_HV<uint32_t> &h_firsts, T_HV<uint32_t> &h_degree, T_HV<uint32_t> &h_id);

	HOSTALGORITHMPROPINQUITYDLL_API bool couple_increment(T_HV<pair_t> &h_pairs, T_HV<uint32_t> &h_degree, T_HV<uint32_t> &h_firsts, uint32_t limit);

	HOSTALGORITHMPROPINQUITYDLL_API bool calculate_propinquity(T_HV<pair_t>& h_pairs);

	HOSTALGORITHMPROPINQUITYDLL_API bool update_propinquity(T_HV<pair_t>& h_pairs, Threshold &threshold, T_HV<uint32_t>& h_propinquity);

	HOSTALGORITHMPROPINQUITYDLL_API bool bfs(T_HV<pair_t>& h_pairs, T_HV<uint8_t>& propinquities, uint32_t minimum, snapshot_t& communities);

	HOSTALGORITHMPROPINQUITYDLL_API bool algorithm_propinquity(comevo::Source &source, comevo::Source &target, uint32_t from, uint32_t to, Threshold &threshold, uint32_t bfsMinimum, uint32_t maxIterations, uint32_t max_snap);

}
