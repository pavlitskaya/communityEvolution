#include "stdafx.h"
#include "include/device_analytic.h"
#include "include/data_source.h"
#include "include/general_comparsion_structs.h"
#include "include/general_arithmetic_structs.h"
#include "include/display_elements.h"
#include "include/general_pair_structs.h"
#include "include/device_pair.h"
#include "include/device_analytic_structs.h"
#include "include/general_search.h"
#include "include/device_convert.h"


using namespace std;

uint32_t get_number_of_diff_elements(T_DV<uint32_t>& d_source){
	return get_number_of_diff_elements(d_source.begin(), d_source.end());
}

uint32_t get_number_of_diff_elements(T_DV<uint32_t>::iterator first, T_DV<uint32_t>::iterator last){
	if (last - first < 2)return (last - first);
	return thrust::count_if(
		T_MTI(T_MZIMT(first, first + 1), is_equal_to()),
		T_MTI(T_MZIMT(last - 1, last), is_equal_to()),
		thrust::logical_not<bool>()) + 1;
}

uint32_t get_number_of_diff_elements(T_DV<pair_t>& d_source){
	return get_number_of_diff_elements(d_source.begin(), d_source.end());
}

uint32_t get_number_of_diff_elements(T_DV<pair_t>::iterator d_source_first, T_DV<pair_t>::iterator d_source_last){
	if (d_source_last - d_source_first < 2)return (d_source_last - d_source_first);
	return thrust::count_if(
		T_MTI(T_MZIMT(d_source_first, d_source_first + 1), is_equal_to_pair()),
		T_MTI(T_MZIMT(d_source_last - 1, d_source_last), is_equal_to_pair()),
		thrust::logical_not<bool>()) + 1;
}

bool get_count(T_DV<pair_t>::iterator d_source_first, T_DV<pair_t>::iterator d_source_last, T_DV<pair_t>& d_unique_pairs, T_DV<uint32_t>& d_unique_count){
	uint32_t n = get_number_of_diff_elements(d_source_first, d_source_last);
	d_unique_pairs.assign(n, pair_t(0,0));
	d_unique_pairs.erase(thrust::unique_copy(d_source_first, d_source_last, d_unique_pairs.begin()), d_unique_pairs.end());
	d_unique_count.assign(n, 0);
	thrust::reduce_by_key(d_source_first, d_source_last, thrust::make_constant_iterator<uint32_t>(1), thrust::make_discard_iterator(), d_unique_count.begin());
	return 1;
}

bool get_count(T_DV<pair_t>& d_source, T_DV<pair_t>& d_unique_pairs, T_DV<uint32_t>& d_unique_count){
	return get_count(d_source.begin(), d_source.end(), d_unique_pairs, d_unique_count);
}

// needs mirrored
bool get_degree_mirror(T_DV<uint32_t>& d_source, T_DV<uint32_t>& d_degree){
	return get_degree_mirror(d_source.begin(), d_source.end(), d_degree);
}

bool get_degree_mirror(T_DV<pair_t>& d_source, T_DV<uint32_t>& d_degree){
    T_DV<uint32_t> source(T_MTI(d_source.begin(), first_element()), T_MTI(d_source.end(), first_element()));
    return get_degree_mirror(source, d_degree);
}

bool get_degree_mirror(T_DV<uint32_t>::iterator d_source_first, T_DV<uint32_t>::iterator d_source_last, T_DV<uint32_t>& d_degree){
	uint32_t n = get_number_of_diff_elements(d_source_first, d_source_last);
	d_degree.assign(n, 0);
	thrust::reduce_by_key(d_source_first, d_source_last, thrust::make_constant_iterator<uint32_t>(1), thrust::make_discard_iterator(), d_degree.begin());
	return 1;
}

// needs one way source
bool get_degree(T_DV<pair_t>& d_source, T_DV<uint32_t>& d_degree){
	T_DV<uint32_t> d_nodes;
	pairsToNodes(d_source, d_nodes);
	thrust::sort(d_nodes.begin(), d_nodes.end());
	get_degree_mirror(d_nodes, d_degree);
	return 1;
}

bool get_nodes(T_DV<pair_t>& d_pairs, T_DV<uint32_t>& d_firsts, T_DV<uint32_t>& d_nodes){
	d_nodes.resize(d_firsts.size());
	thrust::copy(T_MTI(T_MPI(d_pairs.begin(), d_firsts.begin()), first_element()), T_MTI(T_MPI(d_pairs.begin(), d_firsts.end()), first_element()), d_nodes.begin());
	return 1;
}

bool get_firsts(T_DV<uint32_t>& d_degree, T_DV<uint32_t>& d_firsts){
	d_firsts.resize(d_degree.size());
	thrust::exclusive_scan(d_degree.begin(), d_degree.end(), d_firsts.begin());
	return 1;
}

bool get_lasts(T_DV<uint32_t>& d_degree, T_DV<uint32_t>& d_lasts){
	d_lasts.resize(d_degree.size());
	thrust::inclusive_scan(d_degree.begin(), d_degree.end(), d_lasts.begin());
	return 1;
}

T_DV<uint32_t> get_max_combinations(T_DV<uint32_t>& d_degree){
	return T_DV<uint32_t>(
		T_MTI(T_MTI(T_MZIMT(d_degree.begin(), T_MTI(d_degree.begin(), set_decrease<uint32_t>())), zip_mul<uint32_t>()), set_multiply<uint32_t>((float)0.5)),
		T_MTI(T_MTI(T_MZIMT(d_degree.end(), T_MTI(d_degree.end(), set_decrease<uint32_t>())), zip_mul<uint32_t>()), set_multiply<uint32_t>((float)0.5)));
}

uint32_t get_max_combination(T_DV<uint32_t>& d_degree){
	return get_max_combination(d_degree.begin(), d_degree.end());
}

uint32_t get_max_combination(T_DV<uint32_t>::iterator d_degree_first, T_DV<uint32_t>::iterator d_degree_last){
	return thrust::reduce(
		T_MTI(T_MZIMT(d_degree_first, T_MTI(d_degree_first, set_decrease<uint32_t>())), zip_mul<uint32_t>()),
		T_MTI(T_MZIMT(d_degree_last, T_MTI(d_degree_last, set_decrease<uint32_t>())), zip_mul<uint32_t>()))*0.5;
}

T_DV<uint32_t> get_max_combinations_scanned(T_DV<uint32_t>& d_degree){
	T_DV<uint32_t> result(d_degree.size());
	thrust::inclusive_scan(T_MTI(T_MTI(T_MZIMT(d_degree.begin(), T_MTI(d_degree.begin(), set_decrease<uint32_t>())), zip_mul<uint32_t>()), set_multiply<uint32_t>((float)0.5)),
		T_MTI(T_MTI(T_MZIMT(d_degree.end(), T_MTI(d_degree.end(), set_decrease<uint32_t>())), zip_mul<uint32_t>()), set_multiply<uint32_t>((float)0.5)), result.begin());
	return result;
}

bool get_intersection(T_DV<pair_t>& d_pairs, T_DV<pair_t>& d_pairs_mirror, T_DV<pair_t>& d_target_mirror, T_DV<uint32_t>& d_target_degree){
	T_DV<uint32_t> d_target_firsts;
	
	T_DV<uint32_t> d_degree, d_firsts, d_nodes;
	get_degree_mirror(d_pairs_mirror, d_degree);
	get_firsts(d_degree, d_firsts);
	get_nodes(d_pairs_mirror, d_firsts, d_nodes);
	d_firsts.push_back(d_firsts.back() + d_degree.back()); // add last

	d_target_degree.assign(d_pairs.size(), 0);
	thrust::for_each(T_MCI<uint32_t>(0), T_MCI<uint32_t>(d_pairs.size()),
		countCommonNeighbours(RAWD(d_pairs), RAWD(d_pairs_mirror), RAWD(d_nodes), d_nodes.size(), RAWD(d_firsts), d_pairs_mirror.size(), RAWD(d_target_mirror), RAWD(d_target_firsts), RAWD(d_target_degree)));
	d_target_firsts.resize(d_target_degree.size());
	thrust::exclusive_scan(d_target_degree.begin(), d_target_degree.end(), d_target_firsts.begin());

	d_target_mirror.assign(thrust::reduce(d_target_degree.begin(), d_target_degree.end()), pair_t(0, 0));
	if (d_target_mirror.size() > 0){
		thrust::for_each(T_MCI<uint32_t>(0), T_MCI<uint32_t>(d_pairs.size()),
			setCommonNeighbours(RAWD(d_pairs), RAWD(d_pairs_mirror), RAWD(d_nodes), d_nodes.size(), RAWD(d_firsts), d_pairs_mirror.size(), RAWD(d_target_mirror), RAWD(d_target_firsts), RAWD(d_target_degree)));
	}
	d_target_degree.erase(thrust::remove(d_target_degree.begin(), d_target_degree.end(), 0), d_target_degree.end());

	return 1;
}

struct increase_community{
	uint32_t* snapVec, *comVec, size, *target_ii, *target_ij;

	__host__ __device__
		increase_community(uint32_t* snapVec, uint32_t* comVec, uint32_t size, uint32_t* target_ii, uint32_t* target_ij) :
		snapVec(snapVec), comVec(comVec), size(size), target_ii(target_ii), target_ij(target_ij) {}

	__device__
		void operator()(pair_t p){

		// task 1 find common communities
		bool found;
		uint32_t n_first_it = g_binary_search(snapVec, snapVec + size, p.first, found);
		while (n_first_it > 0 && snapVec[n_first_it] == p.first)--n_first_it;
		if (snapVec[n_first_it] != p.first)++n_first_it;
		
		uint32_t n_second_it = g_binary_search(snapVec, snapVec + size, p.second, found);
		while (n_second_it > 0 && snapVec[n_second_it] == p.second)--n_second_it;
		if (snapVec[n_second_it] != p.second)++n_second_it;

		uint32_t n_first_nd = n_first_it;
		while (n_first_nd < size){
			if (snapVec[n_first_nd] != p.first)
				break;
			atomicAdd((uint32_t*)(target_ij + comVec[n_first_nd]), (uint32_t)1);
			++n_first_nd;
		}

		uint32_t n_second_nd = n_second_it;
		while (n_second_nd < size){
			if (snapVec[n_second_nd] != p.second)
				break;
			atomicAdd((uint32_t*)(target_ij + comVec[n_second_nd]), (uint32_t)1);
			++n_second_nd;
		}

		// find common neighbour
		while (n_first_it < size && n_second_it < size){
			if (snapVec[n_first_it] != p.first || snapVec[n_second_it] != p.second)break;
			if (comVec[n_first_it] == comVec[n_second_it]){
				atomicAdd((uint32_t*)(target_ii + comVec[n_first_it]), (uint32_t)2);
				++n_first_it;
				++n_second_it;
			}
			else if (snapVec[n_first_it] < snapVec[n_second_it]){
				++n_first_it;
			}
			else{
				++n_second_it;
			}
		}

	}
};
/* Equation: 
 * ki * kj
 */
bool get_modularity(comevo::Source& sPairs, comevo::Source& sSnaps, uint32_t snapId, float &Q){

	vector<uint32_t> scom = sSnaps.get_scom(snapId);
	if (scom.empty())return 1;
	snapshot_t snap = sSnaps.get_snap(snapId);
	uint32_t com_max = *max_element(scom.begin(), scom.end());
	pairs_t pairs = sPairs.get_edges(snapId);
	T_DV<pair_t> d_pairs(pairs.begin(), pairs.end());
	int eTot = pairs.size();

	// go through all edges
	// store fraction that has both ends in one
	T_DV<uint32_t> eii(scom.size(), 0);
	T_DV<uint32_t> eij(scom.size(), 0);

	T_DV<uint32_t> d_snapVec;
	translate_snapshot_to_vector(snap, d_snapVec);
	T_DV<uint32_t> d_comVec;
	T_DV<uint32_t>d_comSizes(scom.begin(), scom.end());
	translate_scom_to_vector(d_comSizes, d_comVec);
	thrust::sort_by_key(d_snapVec.begin(), d_snapVec.end(), d_comVec.begin());

	thrust::for_each(d_pairs.begin(), d_pairs.end(), increase_community(RAWD(d_snapVec), RAWD(d_comVec), d_snapVec.size(), RAWD(eii), RAWD(eij)));

	Q = thrust::reduce(
		T_MTI(T_MZIMT(eii.begin(), T_MCONSI<uint32_t>(2*eTot)), zip_div<uint32_t>()),
		T_MTI(T_MZIMT(eii.end(), T_MCONSI<uint32_t>(2*eTot)), zip_div<uint32_t>()))
		- thrust::reduce(
		T_MTI(T_MTI(T_MZIMT(eij.begin(), T_MCONSI<uint32_t>(2 * eTot)), zip_div<uint32_t>()), set_square<float>()),
		T_MTI(T_MTI(T_MZIMT(eij.end(), T_MCONSI<uint32_t>(2 * eTot)), zip_div<uint32_t>()), set_square<float>()));
	return 1;
}
