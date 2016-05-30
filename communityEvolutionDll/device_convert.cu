#include "stdafx.h"
#include "include/device_convert.h"
#include "include/display_elements.h"
#include "include/general_pair.h"
#include "include/device_pair.h"
#include "include/general_structs.h"

using namespace std;

bool translate_snapshot_to_vector(snapshot_t& snap, T_DV<uint32_t>& d_snapVec){
	d_snapVec.clear();
	for (uint32_t i = 0; i < snap.size(); ++i){
		d_snapVec.insert(d_snapVec.end(), snap[i].begin(), snap[i].end());
	}
	return 1;
}

bool translate_snapshot_to_matrix(T_DV<uint32_t>& d_snapVec, T_DV<uint32_t>& d_sizes, T_DV<uint32_t>& d_relevant, T_DV<bool>& d_matrix){
	uint32_t offset = 0;
	T_DV<bool> d_found(0);
	T_DV<uint32_t> d_indices(0);
	uint32_t n = d_relevant.size();
	d_found.resize(n);
	// target: snap in matrix
	d_matrix.assign(d_sizes.size() * n, 0);
	
	for (uint32_t i = 0; i < d_sizes.size(); ++i){
		thrust::binary_search(
			d_snapVec.begin() + offset,
			d_snapVec.begin() + offset + d_sizes[i],
			d_relevant.begin(),
			d_relevant.end(),
			d_found.begin());
		d_indices.resize(thrust::count(d_found.begin(), d_found.end(), 1));
		thrust::copy_if(T_MCI<uint32_t>(0), T_MCI<uint32_t>(n), d_found.begin(), d_indices.begin(), thrust::identity<bool>());

		thrust::transform(T_MPI(d_matrix.begin() + i*n, d_indices.begin()),
			T_MPI(d_matrix.begin() + i*n, d_indices.end()),
			T_MPI(d_matrix.begin() + i*n, d_indices.begin()),
			set_one<bool>());
		offset += d_sizes[i];

	}
	return 1;
}


struct fill_com_vec{
	uint32_t *comSizes, *comVec, *comFirsts;

	__host__ __device__
		fill_com_vec(uint32_t* comSizes, uint32_t* comVec, uint32_t* comFirsts) :
		comSizes(comSizes), comVec(comVec), comFirsts(comFirsts) {}

	__device__
		void operator()(uint32_t i){
		uint32_t size = comSizes[i];
		for (uint32_t j = 0; j < comSizes[i]; ++j){
			comVec[comFirsts[i]+j] = i;
		}
	}
};



bool translate_scom_to_vector(T_DV<uint32_t>& d_comSizes, T_DV<uint32_t>& d_comVec){
	d_comVec.assign(thrust::reduce(d_comSizes.begin(), d_comSizes.end()), 0);
	T_DV<uint32_t>d_comFirsts(d_comSizes.size());
	thrust::exclusive_scan(d_comSizes.begin(), d_comSizes.end(), d_comFirsts.begin());
	thrust::for_each(T_MCI<uint32_t>(0), T_MCI<uint32_t>(d_comSizes.size()),
		fill_com_vec(RAWD(d_comSizes), RAWD(d_comVec), RAWD(d_comFirsts)));
	return 1;
}