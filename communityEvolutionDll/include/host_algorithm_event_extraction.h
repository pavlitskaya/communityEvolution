#pragma once

#ifdef ARCH_WINDOWS
#ifdef HOSTALGORITHMEVENTEXTRACTIONDLL_EXPORTS
#define HOSTALGORITHMEVENTEXTRACTIONDLL_API __declspec(dllexport) 
#else
#define HOSTALGORITHMEVENTEXTRACTIONDLL_API __declspec(dllimport) 
#endif
#else
#define HOSTALGORITHMEVENTEXTRACTIONDLL_API __attribute__ ((visibility ("default")))
#endif

#include "data_source.h"

namespace comevohost{

	HOSTALGORITHMEVENTEXTRACTIONDLL_API bool algorithm_event_extraction(comevo::Source &source, float k, bool display, bool create_file);
}
