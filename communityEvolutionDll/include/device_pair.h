#pragma once

#ifdef ARCH_WINDOWS
#ifdef DEVICEPAIRDLL_EXPORTS
#define DEVICEPAIRDLL_API __declspec(dllexport) 
#else
#define DEVICEPAIRDLL_API __declspec(dllimport) 
#endif
#else
#define DEVICEPAIRDLL_API __attribute__ ((visibility ("default")))
#endif

#include "general_defines.h"
#include <thrust/device_vector.h>

DEVICEPAIRDLL_API bool combine_values(T_DV<pair_t>& d_targetPairs, T_DV<uint32_t>& d_targetVal, T_DV<pair_t>& d_sourcePairs, T_DV<uint32_t>& d_sourceVal);

DEVICEPAIRDLL_API bool combine_pairs(T_DV<pair_t>& d_fillingPair, T_DV<uint32_t>& d_fillingVal, T_DV<pair_t>& d_pair, T_DV<uint32_t>& d_val);

/* Converts vector of pairs into vector of nodes
 */
DEVICEPAIRDLL_API void pairsToNodes(std::vector<pair_t>& source, std::vector<uint32_t>& target);

DEVICEPAIRDLL_API void pairsToNodes(thrust::device_vector<pair_t>& source, thrust::device_vector<uint32_t>& target);

/* Converts vector of pairs into vector of sorted unique nodes
*/
DEVICEPAIRDLL_API void pairsToUniqueNodes(std::vector<pair_t>& source, std::vector<uint32_t>& target);

DEVICEPAIRDLL_API void pairsToUniqueNodes(thrust::device_vector<pair_t>& source, thrust::device_vector<uint32_t>& target);

DEVICEPAIRDLL_API void mirror_pairs(T_DV<pair_t>& d_source, T_DV<pair_t>& d_target);

DEVICEPAIRDLL_API void mirror_pairs_inplace(T_DV<pair_t>& d_source_target);
