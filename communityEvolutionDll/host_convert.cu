#include "stdafx.h"
#include "include/host_convert.h"
#include "include/display_elements.h"
#include "include/general_pair.h"
#include "include/device_pair.h"
#include "include/general_structs.h"
#include "include/general_comparsion_structs.h"

using namespace std;

namespace comevohost{

	bool translate_snapshot_to_vector(snapshot_t& snap, T_HV<uint32_t>& h_snapVec){
		for (snapshot_t::iterator it = snap.begin(); it != snap.end(); ++it){
			h_snapVec.insert(h_snapVec.end(), (*it).begin(), (*it).end());
		}
		return 1;
	}

	//bool translate_snapshot_to_matrix(T_HV<uint32_t>& h_preSnapVec, T_HV<uint32_t>& h_sizes, T_HV<uint32_t>& h_relevant, T_HV<bool>& h_preMatrix){
	//	uint32_t offset = 0;
	//	T_HV<bool> h_found(0);
	//	T_HV<uint32_t> h_indices(0);
	//	h_found.resize(h_preSnapVec.size());
	//	uint32_t n = h_relevant.size();
	//	// target: snap in matrix

	//	h_preMatrix.assign(h_sizes.size() * n, 0);

	//	for (uint32_t i = 0; i < h_sizes.size(); ++i){
	//		for (uint32_t j = 0; j < h_sizes[i]; ++j){
	//			h_found[j] = thrust::binary_search(h_relevant.begin(), h_relevant.end(),
	//				h_preSnapVec[offset + j]);
	//		}
	//		h_indices.resize(thrust::count(h_found.begin(), h_found.end(), 1));
	//		T_HV<uint32_t> h_counter(n);
	//		thrust::sequence(h_counter.begin(), h_counter.end());
	//		thrust::copy_if(h_counter.begin(), h_counter.end(), h_found.begin(), h_indices.begin(), is_one<bool>());

	//		thrust::transform(T_MPI(h_preMatrix.begin() + i*n, h_indices.begin()),
	//			T_MPI(h_preMatrix.begin() + i*n, h_indices.end()),
	//			T_MPI(h_preMatrix.begin() + i*n, h_indices.begin()),
	//			set_one<bool>());
	//		offset += h_sizes[i];

	//	}

	//	return 1;
	//}

	bool translate_snapshot_to_matrix(T_HV<uint32_t>& h_preSnapVec, T_HV<uint32_t>& h_sizes, T_HV<uint32_t>& h_relevant, T_HV<bool>& h_preMatrix){
		uint32_t offset = 0;
		T_HV<bool> h_found(0);
		T_HV<uint32_t> h_indices(0);
		h_found.resize(h_relevant.size());
		uint32_t n = h_relevant.size();
		// target: snap in matrix

		// h_sizes.size() show how many communities are in the given matrix, so that every community will be compared with h_relevant
		h_preMatrix.assign(h_sizes.size() * n, 0);

		for (uint32_t i = 0; i < h_sizes.size(); ++i){
			thrust::binary_search(
				h_preSnapVec.begin() + offset,
				h_preSnapVec.begin() + offset + h_sizes[i],
				h_relevant.begin(),
				h_relevant.end(),
				h_found.begin());
			h_indices.resize(thrust::count(h_found.begin(), h_found.end(), 1));
			thrust::copy_if(T_MCI<uint32_t>(0), T_MCI<uint32_t>(n), h_found.begin(), h_indices.begin(), thrust::identity<bool>());

			/*for (uint32_t j = 0; j < h_sizes[i]; ++j){
			h_found[j] = thrust::binary_search(h_relevant.begin(), h_relevant.end(),
			h_preSnapVec[offset + j]);
			}
			h_indices.resize(thrust::count(h_found.begin(), h_found.end(), 1));
			T_HV<uint32_t> h_counter(n);
			thrust::sequence(h_counter.begin(), h_counter.end());
			thrust::copy_if(h_counter.begin(), h_counter.end(), h_found.begin(), h_indices.begin(), is_one<bool>());*/

			thrust::transform(T_MPI(h_preMatrix.begin() + i*n, h_indices.begin()),
				T_MPI(h_preMatrix.begin() + i*n, h_indices.end()),
				T_MPI(h_preMatrix.begin() + i*n, h_indices.begin()),
				set_one<bool>());
			offset += h_sizes[i];

		}

		return 1;
	}

	struct fill_com_vec{
		uint32_t *comSizes, *comVec, *comFirsts;

		__host__ __device__
			fill_com_vec(uint32_t* comSizes, uint32_t* comVec, uint32_t* comFirsts) :
			comSizes(comSizes), comVec(comVec), comFirsts(comFirsts) {}

		__host__ __device__
			void operator()(uint32_t i){
			uint32_t size = comSizes[i];
			for (uint32_t j = 0; j < comSizes[i]; ++j){
				comVec[comFirsts[i] + j] = i;
			}
		}
	};



	bool translate_scom_to_vector(T_HV<uint32_t>& h_comSizes, T_HV<uint32_t>& h_comVec){
		h_comVec.assign(thrust::reduce(h_comSizes.begin(), h_comSizes.end()), 0);
		T_HV<uint32_t>h_comFirsts(h_comSizes.size());
		thrust::exclusive_scan(h_comSizes.begin(), h_comSizes.end(), h_comFirsts.begin());
		T_HV<uint32_t> h_counter(h_comSizes.size());
		thrust::sequence(h_counter.begin(), h_counter.end());
		thrust::for_each(h_counter.begin(), h_counter.end(),
			fill_com_vec(RAWD(h_comSizes), RAWD(h_comVec), RAWD(h_comFirsts)));
		return 1;
	}
}