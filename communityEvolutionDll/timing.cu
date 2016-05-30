#include "stdafx.h"
#include "include/timing.h"

std::map<uint32_t, tuple_event> times;
std::map<uint32_t, clock_t> times_cpu;

void Timing::create_time(uint32_t id){
	
	if (times.end() == times.find(id)){
		cudaEvent_t start, stop;
		times.insert(std::pair<uint32_t, tuple_event>(id, tuple_event(start, stop)));
	}
}

void Timing::start_time(uint32_t id){
	if (times.end() != times.find(id)){
		cudaEventCreate(&times[id].first);
		cudaEventCreate(&times[id].second);
		cudaEventRecord(times[id].first, 0);
	}
}

float Timing::stop_time(uint32_t id){
	if (times.end() != times.find(id)){
		cudaEventRecord(times[id].second, 0);
		cudaEventSynchronize(times[id].second);
		float timeAlgorithm;
		cudaEventElapsedTime(&timeAlgorithm, times[id].first, times[id].second);
		printf("\nTime for the kernel: %3.1f ms \n", timeAlgorithm);
		return timeAlgorithm;
	}
	return 0;
}

void Timing::start_time_cpu(uint32_t id){
	times_cpu.insert(std::pair<uint32_t, clock_t>(id, clock()));
}

float Timing::stop_time_cpu(uint32_t id){
	if (times_cpu.end() != times_cpu.find(id)){
		float timeAlgorithm = float(clock() - times_cpu[id]) / CLOCKS_PER_SEC;
		printf("\nTime for the CPU: %3.1f ms \n", timeAlgorithm);
		times_cpu.erase(id);
		return timeAlgorithm;
	}
	return 0;
}