#pragma once

#ifdef ARCH_WINDOWS
#ifdef GENERALSEARCHDLL_EXPORTS
#define GENERALSEARCHDLL_API __declspec(dllexport) 
#else
#define GENERALSEARCHDLL_API __declspec(dllimport) 
#endif
#else
#define GENERALSEARCHDLL_API __attribute__ ((visibility ("default")))
#endif


GENERALSEARCHDLL_API __host__ __device__ uint32_t g_binary_search(pair_t* source, pair_t key, uint32_t pair_size, int32_t ind_min, int32_t ing_max, bool& found, bool b_swap);
GENERALSEARCHDLL_API __host__ __device__ uint32_t g_binary_search(pair_t* source, pair_t key, uint32_t pair_size, bool& found, bool b_swap);
GENERALSEARCHDLL_API __host__ __device__ bool g_binary_search(pair_t* source, pair_t key, uint32_t pair_size, bool b_swap);
GENERALSEARCHDLL_API __host__ __device__ bool g_binary_search(pair_t* source, pair_t key, uint32_t pair_size, uint32_t ind_min, uint32_t ing_max, bool b_swap);
GENERALSEARCHDLL_API __host__ __device__ uint32_t g_binary_search(uint32_t* begin, uint32_t* end, uint32_t key, bool& found);
GENERALSEARCHDLL_API __host__ __device__ bool g_binary_search(uint32_t* begin, uint32_t* end, uint32_t key);
GENERALSEARCHDLL_API __host__ __device__ uint32_t g_binary_search(uint32_t* begin, uint32_t* end, uint32_t key, uint32_t ind_min, uint32_t ing_max, bool& found);
