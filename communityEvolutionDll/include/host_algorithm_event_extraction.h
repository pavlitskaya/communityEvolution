#pragma once


#ifdef HOSTALGORITHMEVENTEXTRACTIONDLL_EXPORTS
#define HOSTALGORITHMEVENTEXTRACTIONDLL_API __declspec(dllexport) 
#else
#define HOSTALGORITHMEVENTEXTRACTIONDLL_API __declspec(dllimport) 
#endif

#include "data_source.h"

namespace comevohost{

	HOSTALGORITHMEVENTEXTRACTIONDLL_API bool algorithm_event_extraction(comevo::Source &source, float k, bool display, bool create_file);
}