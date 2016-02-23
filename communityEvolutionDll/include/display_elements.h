#pragma once

#ifdef DISPLAYELEMENTSDLL_EXPORTS
#define DISPLAYELEMENTSDLL_API __declspec(dllexport) 
#else
#define DISPLAYELEMENTSDLL_API __declspec(dllimport) 
#endif

DISPLAYELEMENTSDLL_API void display_snapshot(snapshot_t& vec, char* name);
DISPLAYELEMENTSDLL_API void display_snapshots(std::vector<snapshot_t>& vec, char* name);

template <typename T1> void display_direct(uint32_t* first, uint32_t* last, char* name);

template <typename T1> void display_direct(uint32_t* first, uint32_t* last, char* name);
template <typename T1, typename T2> void display_direct(pair_t* first, pair_t* last, char* name);

template <typename T> void display_single(T const &single);
template <typename T> void display_single(T const &single, char* name);

template <typename T> void display_vector(std::vector<T> const &vec);
template <typename T> void display_vector(std::vector<T> const &vec, char* name);
template <typename T> void display_vector(std::vector<T> const &vec, uint32_t limit, char* name);
template <typename T> void display_vector(std::vector<T> const &vec, uint32_t limit, uint16_t entriesBeforeLineBreak, char* name);

template <typename T> void display_vector(T_DV<T> const &vec);
template <typename T> void display_vector(T_DV<T> const &vec, char* name);
template <typename T> void display_vector(T_DV<T> const &vec, uint32_t limit, char* name);
template <typename T> void display_vector(T_DV<T> const &vec, uint32_t limit, uint16_t entriesBeforeLineBreak, char* name);

template <typename T> void display_vector(T_HV<T> const &vec);
template <typename T> void display_vector(T_HV<T> const &vec, char* name);
template <typename T> void display_vector(T_HV<T> const &vec, uint32_t limit, char* name);
template <typename T> void display_vector(T_HV<T> const &vec, uint32_t limit, uint16_t entriesBeforeLineBreak, char* name);

template <typename T1, typename T2> void display_vector(std::vector<thrust::pair<T1,T2> > const &vec);
template <typename T1, typename T2> void display_vector(std::vector<thrust::pair<T1, T2> > const &vec, char* name);
template <typename T1, typename T2> void display_vector(std::vector<thrust::pair<T1, T2> > const &vec, uint32_t limit, char* name);
template <typename T1, typename T2> void display_vector(std::vector<thrust::pair<T1, T2> > const &vec, uint32_t limit, uint16_t entriesBeforeLineBreak, char* name);

template <typename T1, typename T2> void display_vector(T_DV<thrust::pair<T1, T2> > const &vec);
template <typename T1, typename T2> void display_vector(T_DV<thrust::pair<T1, T2> > const &vec, char* name);
template <typename T1, typename T2> void display_vector(T_DV<thrust::pair<T1, T2> > const &vec, uint32_t limit, char* name);
template <typename T1, typename T2> void display_vector(T_DV<thrust::pair<T1, T2> > const &vec, uint32_t limit, uint16_t entriesBeforeLineBreak, char* name);

template <typename T1, typename T2> void display_vector(T_HV<thrust::pair<T1, T2> > const &vec);
template <typename T1, typename T2> void display_vector(T_HV<thrust::pair<T1, T2> > const &vec, char* name);
template <typename T1, typename T2> void display_vector(T_HV<thrust::pair<T1, T2> > const &vec, uint32_t limit, char* name);
template <typename T1, typename T2> void display_vector(T_HV<thrust::pair<T1, T2> > const &vec, uint32_t limit, uint16_t entriesBeforeLineBreak, char* name);
