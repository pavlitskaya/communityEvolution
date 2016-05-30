#pragma once

#ifdef ARCH_WINDOWS
#ifdef DEVICEHELPDLL_EXPORTS
#define DEVICEHELPDLL_API __declspec(dllexport) 
#else
#define DEVICEHELPDLL_API __declspec(dllimport) 
#endif
#else
#define DEVICEHELPDLL_API __attribute__ ((visibility ("default")))
#endif

namespace comevo{
	template <typename T> bool back_inserter(T_HV<T>& h_vec, T value);
	bool fill_pair_vector(std::vector<uint32_t>& vecFirst, std::vector<uint32_t>& vecSecond, T_HV<pair_t>& h_vec);
	template <typename T> bool fill_vector(std::vector<T>& vec, T_HV<T>& h_vec);
	template <typename T> bool allocate_vector(T_HV<T>& h_vec, uint32_t size);
}
