#include "../stdafx.h"
#include "../include/device_pair.h"
#include "../include/general_pair_structs.h"
#include "../include/general_comparsion_structs.h"
#include "../include/general_arithmetic_structs.h"
#include "../include/device_pair_structs.h"
#include "../include/display_elements.h"


bool combine_values(T_DV<pair_t>& d_targetPairs, T_DV<uint32_t>& d_targetVal, T_DV<pair_t>& d_sourcePairs, T_DV<uint32_t>& d_sourceVal){

	T_DV<pair_t> d_mergedPairs(d_targetPairs.size() + d_sourcePairs.size());
	T_DV<uint32_t> d_mergedVals(d_targetPairs.size() + d_sourcePairs.size());
	thrust::merge_by_key(d_targetPairs.begin(), d_targetPairs.end(),
		d_sourcePairs.begin(), d_sourcePairs.end(),
		d_targetVal.begin(), d_sourceVal.begin(),
		d_mergedPairs.begin(), d_mergedVals.begin());

	thrust::pair<T_DV<pair_t>::iterator, T_DV<uint32_t>::iterator> newEnds = thrust::reduce_by_key(d_mergedPairs.begin(), d_mergedPairs.end(),
		d_mergedVals.begin(), d_mergedPairs.begin(), d_mergedVals.begin());
	d_mergedPairs.erase(newEnds.first, d_mergedPairs.end());
	d_mergedVals.erase(newEnds.second, d_mergedVals.end());

	T_DV<uint32_t> d_indices(d_targetPairs.size());
	thrust::lower_bound(d_mergedPairs.begin(), d_mergedPairs.end(), d_targetPairs.begin(), d_targetPairs.end(), d_indices.begin());
	thrust::copy(T_MPI(d_mergedVals.begin(), d_indices.begin()), T_MPI(d_mergedVals.begin(), d_indices.end()), d_targetVal.begin());
	return 1;
}

bool combine_pairs(T_DV<pair_t>& d_targetPairs, T_DV<uint32_t>& d_targetVal, T_DV<pair_t>& d_sourcePairs, T_DV<uint32_t>& d_sourceVal){

	T_DV<pair_t> d_mergedPairs(d_targetPairs.size() + d_sourcePairs.size());
	T_DV<uint32_t> d_mergedVals(d_targetPairs.size() + d_sourcePairs.size());
	thrust::merge_by_key(d_targetPairs.begin(), d_targetPairs.end(),
		d_sourcePairs.begin(), d_sourcePairs.end(), 
		d_targetVal.begin(), d_sourceVal.begin(), 
		d_mergedPairs.begin(), d_mergedVals.begin());

	thrust::pair<T_DV<pair_t>::iterator, T_DV<uint32_t>::iterator> newEnds = thrust::reduce_by_key(d_mergedPairs.begin(), d_mergedPairs.end(),
		d_mergedVals.begin(), d_mergedPairs.begin(), d_mergedVals.begin());
	d_mergedPairs.erase(newEnds.first, d_mergedPairs.end());
	d_mergedVals.erase(newEnds.second, d_mergedVals.end());

	d_targetPairs.swap(d_mergedPairs);
	d_targetVal.swap(d_mergedVals);
	return 1;
}

void pairsToNodes(std::vector<pair_t>& source, std::vector<uint32_t>& target){
	thrust::device_vector<uint32_t> d_target;
	pairsToNodes(thrust::device_vector<pair_t>(source.begin(), source.end()), d_target);
	thrust::host_vector<uint32_t> h_target(d_target.begin(), d_target.end());
	target.assign(h_target.begin(), h_target.end());
}

void pairsToNodes(thrust::device_vector<pair_t>& source, thrust::device_vector<uint32_t>& target){
	target.resize(source.size() * 2);
	
	thrust::transform(
		source.begin(), source.end(), 
		T_MPI(target.begin(), T_MTI(T_MZIMT(thrust::make_counting_iterator<uint32_t>(0), 
		thrust::make_constant_iterator<uint32_t>(2)), zip_mul<uint32_t>())),
		first_element());
	thrust::transform(
		source.begin(), source.end(),
		T_MPI(target.begin(), T_MTI(T_MTI(T_MZIMT(thrust::make_counting_iterator<uint32_t>(0),
		thrust::make_constant_iterator<uint32_t>(2)), zip_mul<uint32_t>()), set_increase<uint32_t>())),
		second_element());
}

void pairsToUniqueNodes(std::vector<pair_t>& source, std::vector<uint32_t>& target){
	thrust::device_vector<uint32_t> d_target;
	pairsToUniqueNodes(thrust::device_vector<pair_t>(source.begin(), source.end()), d_target);
	thrust::host_vector<uint32_t> h_target(d_target.begin(), d_target.end());
	target.assign(h_target.begin(), h_target.end());
}

void pairsToUniqueNodes(thrust::device_vector<pair_t>& source, thrust::device_vector<uint32_t>& target){
	target.resize(source.size() * 2);
	thrust::transform(
		source.begin(), source.end(),
		T_MPI(target.begin(), T_MTI(T_MZIMT(thrust::make_counting_iterator<uint32_t>(0),
		thrust::make_constant_iterator<uint32_t>(2)), zip_mul<uint32_t>())),
		first_element());
	thrust::transform(
		source.begin(), source.end(),
		T_MPI(target.begin(), T_MTI(T_MTI(T_MZIMT(thrust::make_counting_iterator<uint32_t>(0),
		thrust::make_constant_iterator<uint32_t>(2)), zip_mul<uint32_t>()), set_increase<uint32_t>())),
		second_element());
	thrust::sort(target.begin(), target.end());
	target.resize(thrust::unique(target.begin(), target.end()) - target.begin());
}

void mirror_pairs(T_DV<pair_t>& d_source, T_DV<pair_t>& d_target){
	d_target.assign(d_source.begin(), d_source.end());
	d_target.resize(d_target.size() * 2);
	thrust::transform(d_source.begin(), d_source.end(), d_target.begin() + d_source.size(), pair_create_inverse());
	thrust::sort(d_target.begin(), d_target.end()); 
}

void mirror_pairs_inplace(T_DV<pair_t>& d_source_target){
	uint32_t old_size = d_source_target.size();
	d_source_target.resize(old_size * 2);
	thrust::transform(d_source_target.begin(), d_source_target.begin() + old_size, d_source_target.begin() + old_size, pair_create_inverse());
	thrust::sort(d_source_target.begin(), d_source_target.end());
}