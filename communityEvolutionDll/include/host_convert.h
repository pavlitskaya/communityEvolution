#pragma once

#ifdef HOSTCONVERTDLL
#define HOSTCONVERTDLL_API __declspec(dllexport) 
#else
#define HOSTCONVERTDLL_API __declspec(dllimport) 
#endif

namespace comevohost{

	HOSTCONVERTDLL_API bool translate_snapshot_to_vector(snapshot_t& snap, T_HV<uint32_t>& d_snapVec);

	HOSTCONVERTDLL_API bool translate_snapshot_to_matrix(T_HV<uint32_t>& d_preSnapVec, T_HV<uint32_t>& d_sizes, T_HV<uint32_t>& d_relevant, T_HV<bool>& d_preMatrix);

	HOSTCONVERTDLL_API bool translate_scom_to_vector(T_HV<uint32_t>& d_comSizes, T_HV<uint32_t>& d_comVec);

}