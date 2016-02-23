#pragma once

#ifdef HOSTALGORITHMCLIQUEDLL_EXPORTS
#define HOSTALGORITHMCLIQUEDLL_API __declspec(dllexport) 
#else
#define HOSTALGORITHMCLIQUEDLL_API __declspec(dllimport) 
#endif

#include "data_source.h"
namespace comevohost{

	HOSTALGORITHMCLIQUEDLL_API bool generate_clique(T_HV<pair_t>& pairs, uint32_t minimumClique, T_HV<uint32_t>& cliques, T_HV<uint32_t>& cliquesFirst);

	HOSTALGORITHMCLIQUEDLL_API bool generate_communities(T_HV<uint32_t>& nodes, T_HV<uint32_t>& cliques, T_HV<uint32_t>& cliquesFirst, T_HV<uint32_t>& communities, T_HV<uint32_t>& communitiesFirst);

	HOSTALGORITHMCLIQUEDLL_API bool algorithm_clique(comevo::Source &source, comevo::Source &target, uint32_t minimumClique);
}