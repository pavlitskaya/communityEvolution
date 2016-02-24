#pragma once

#ifdef DEVICECONVERTDLL
#define DEVICECONVERTDLL_API __declspec(dllexport) 
#else
#define DEVICECONVERTDLL_API __declspec(dllimport) 
#endif

DEVICECONVERTDLL_API bool translate_snapshot_to_vector(snapshot_t& snap, T_DV<uint32_t>& d_snapVec);

DEVICECONVERTDLL_API bool translate_snapshot_to_matrix(T_DV<uint32_t>& d_preSnapVec, T_DV<uint32_t>& d_sizes, T_DV<uint32_t>& d_relevant, T_DV<bool>& d_preMatrix);

DEVICECONVERTDLL_API bool translate_scom_to_vector(T_DV<uint32_t>& d_comSizes, T_DV<uint32_t>& d_comVec);
