#pragma once

#ifdef ARCH_WINDOWS
#ifdef ALGORITHMCLIQUEDLL_EXPORTS
#define ALGORITHMCLIQUEDLL_API __declspec(dllexport)
#else
#define ALGORITHMCLIQUEDLL_API __declspec(dllimport) 
#endif
#else
#define ALGORITHMCLIQUEDLL_API __attribute__ ((visibility ("default")))
#endif

#include "data_source.h"
namespace comevodevice{

	ALGORITHMCLIQUEDLL_API bool algorithm_clique(comevo::Source &source, comevo::Source &target, uint32_t minimumClique);
}
