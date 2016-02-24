#pragma once

#ifdef HOSTPAIRDLL_EXPORTS
#define HOSTPAIRDLL_API __declspec(dllexport) 
#else
#define HOSTPAIRDLL_API __declspec(dllimport) 
#endif

#include "general_defines.h"

namespace comevohost{

	HOSTPAIRDLL_API bool combine_values(T_HV<pair_t>& d_targetPairs, T_HV<uint32_t>& d_targetVal, T_HV<pair_t>& d_sourcePairs, T_HV<uint32_t>& d_sourceVal);

	HOSTPAIRDLL_API bool combine_pairs(T_HV<pair_t>& d_fillingPair, T_HV<uint32_t>& d_fillingVal, T_HV<pair_t>& d_pair, T_HV<uint32_t>& d_val);

	/* Converts vector of pairs into vector of nodes
	*/
	HOSTPAIRDLL_API void pairsToNodes(std::vector<pair_t>& source, std::vector<uint32_t>& target);

	HOSTPAIRDLL_API void pairsToNodes(T_HV<pair_t>& source, T_HV<uint32_t>& target);

	/* Converts vector of pairs into vector of sorted unique nodes
	*/
	HOSTPAIRDLL_API void pairsToUniqueNodes(std::vector<pair_t>& source, std::vector<uint32_t>& target);

	HOSTPAIRDLL_API void pairsToUniqueNodes(T_HV<pair_t>& source, T_HV<uint32_t>& target);

	HOSTPAIRDLL_API void mirror_pairs(T_HV<pair_t>& d_source, T_HV<pair_t>& d_target);

	HOSTPAIRDLL_API void mirror_pairs_inplace(T_HV<pair_t>& d_source_target);

}