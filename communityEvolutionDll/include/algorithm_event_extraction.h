#pragma once


#ifdef ALGORITHMEVENTEXTRACTIONDLL_EXPORTS
#define ALGORITHMEVENTEXTRACTIONDLL_API __declspec(dllexport) 
#else
#define ALGORITHMEVENTEXTRACTIONDLL_API __declspec(dllimport) 
#endif

#include "data_source.h"

ALGORITHMEVENTEXTRACTIONDLL_API bool algorithm_event_extraction(comevo::Source &source, float k, bool display, bool create_file);