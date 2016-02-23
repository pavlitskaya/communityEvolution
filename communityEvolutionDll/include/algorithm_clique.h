#pragma once

#ifdef ALGORITHMCLIQUEDLL_EXPORTS
#define ALGORITHMCLIQUEDLL_API __declspec(dllexport) 
#else
#define ALGORITHMCLIQUEDLL_API __declspec(dllimport) 
#endif

#include "data_source.h"
namespace comevodevice{

	ALGORITHMCLIQUEDLL_API bool algorithm_clique(comevo::Source &source, comevo::Source &target, uint32_t minimumClique);
}