#pragma once

#ifdef ARCH_WINDOWS
#ifdef TIMINGDLL_EXPORTS
#define TIMINGDLL_API __declspec(dllexport) 
#else
#define TIMINGDLL_API __declspec(dllimport) 
#endif
#else
#define TIMINGDLL_API __attribute__ ((visibility ("default")))
#endif

class Timing
{
	//static std::map<uint32_t, tuple_event> times;
public:
	TIMINGDLL_API static void create_time(uint32_t id);
	TIMINGDLL_API static void start_time(uint32_t id);
	TIMINGDLL_API static float stop_time(uint32_t id);
	TIMINGDLL_API static void start_time_cpu(uint32_t id);
	TIMINGDLL_API static float stop_time_cpu(uint32_t id);
private: 
	Timing() {};

};
