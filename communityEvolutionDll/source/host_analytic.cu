#include "../stdafx.h"
#include "../include/host_analytic.h"
#include "../include/data_source.h"
#include "../include/general_comparsion_structs.h"
#include "../include/general_arithmetic_structs.h"
#include "../include/display_elements.h"
#include "../include/general_pair_structs.h"
#include "../include/host_pair.h"
#include "../include/device_analytic_structs.h"
#include "../include/general_search.h"
#include "../include/host_convert.h"


using namespace std;

namespace comevohost{
	uint32_t get_number_of_diff_elements(T_HV<uint32_t>& h_source){
		return get_number_of_diff_elements(h_source.begin(), h_source.end());
	}

	uint32_t get_number_of_diff_elements(T_HV<uint32_t>::iterator first, T_HV<uint32_t>::iterator last){
		if (last - first < 2)return (last - first);
		return thrust::count_if(
			T_MTI(T_MZIMT(first, first + 1), is_equal_to()),
			T_MTI(T_MZIMT(last - 1, last), is_equal_to()),
			thrust::logical_not<bool>()) + 1;
	}

	uint32_t get_number_of_diff_elements(T_HV<pair_t>& h_source){
		return get_number_of_diff_elements(h_source.begin(), h_source.end());
	}

	uint32_t get_number_of_diff_elements(T_HV<pair_t>::iterator h_source_first, T_HV<pair_t>::iterator h_source_last){
		if (h_source_last - h_source_first < 2)return (h_source_last - h_source_first);
		return thrust::count_if(
			T_MTI(T_MZIMT(h_source_first, h_source_first + 1), is_equal_to_pair()),
			T_MTI(T_MZIMT(h_source_last - 1, h_source_last), is_equal_to_pair()),
			thrust::logical_not<bool>()) + 1;
	}

	bool get_count(T_HV<pair_t>::iterator h_source_first, T_HV<pair_t>::iterator h_source_last, T_HV<pair_t>& h_unique_pairs, T_HV<uint32_t>& h_unique_count){
		uint32_t n = get_number_of_diff_elements(h_source_first, h_source_last);
		h_unique_pairs.assign(n, pair_t(0, 0));
		h_unique_pairs.erase(thrust::unique_copy(h_source_first, h_source_last, h_unique_pairs.begin()), h_unique_pairs.end());
		h_unique_count.assign(n, 0);
		thrust::reduce_by_key(h_source_first, h_source_last, thrust::make_constant_iterator<uint32_t>(1), thrust::make_discard_iterator(), h_unique_count.begin());
		return 1;
	}

	bool get_count(T_HV<pair_t>& h_source, T_HV<pair_t>& h_unique_pairs, T_HV<uint32_t>& h_unique_count){
		return get_count(h_source.begin(), h_source.end(), h_unique_pairs, h_unique_count);
	}

	// needs mirrored
	bool get_degree_mirror(T_HV<uint32_t>& h_source, T_HV<uint32_t>& h_degree){
		return get_degree_mirror(h_source.begin(), h_source.end(), h_degree);
	}

	bool get_degree_mirror(T_HV<pair_t>& h_source, T_HV<uint32_t>& h_degree){
		return get_degree_mirror(T_HV<uint32_t>(T_MTI(h_source.begin(), first_element()), T_MTI(h_source.end(), first_element())), h_degree);
	}

	bool get_degree_mirror(T_HV<uint32_t>::iterator h_source_first, T_HV<uint32_t>::iterator h_source_last, T_HV<uint32_t>& h_degree){
		uint32_t n = get_number_of_diff_elements(h_source_first, h_source_last);
		h_degree.assign(n, 0);
		thrust::reduce_by_key(h_source_first, h_source_last, thrust::make_constant_iterator<uint32_t>(1), thrust::make_discard_iterator(), h_degree.begin());
		return 1;
	}

	// needs one way source
	bool get_degree(T_HV<pair_t>& h_source, T_HV<uint32_t>& h_degree){
		T_HV<uint32_t> h_nodes;
		pairsToNodes(h_source, h_nodes);
		thrust::sort(h_nodes.begin(), h_nodes.end());
		get_degree_mirror(h_nodes, h_degree);
		return 1;
	}

	bool get_nodes(T_HV<pair_t>& h_pairs, T_HV<uint32_t>& h_firsts, T_HV<uint32_t>& h_nodes){
		h_nodes.resize(h_firsts.size());
		thrust::copy(T_MTI(T_MPI(h_pairs.begin(), h_firsts.begin()), first_element()), T_MTI(T_MPI(h_pairs.begin(), h_firsts.end()), first_element()), h_nodes.begin());
		return 1;
	}

	bool get_firsts(T_HV<uint32_t>& h_degree, T_HV<uint32_t>& h_firsts){
		h_firsts.resize(h_degree.size());
		thrust::exclusive_scan(h_degree.begin(), h_degree.end(), h_firsts.begin());
		return 1;
	}

	bool get_lasts(T_HV<uint32_t>& h_degree, T_HV<uint32_t>& h_lasts){
		h_lasts.resize(h_degree.size());
		thrust::inclusive_scan(h_degree.begin(), h_degree.end(), h_lasts.begin());
		return 1;
	}

	T_HV<uint32_t> get_max_combinations(T_HV<uint32_t>& h_degree){
		return T_HV<uint32_t>(
			T_MTI(T_MTI(T_MZIMT(h_degree.begin(), T_MTI(h_degree.begin(), set_decrease<uint32_t>())), zip_mul<uint32_t>()), set_multiply<uint32_t>((float)0.5)),
			T_MTI(T_MTI(T_MZIMT(h_degree.end(), T_MTI(h_degree.end(), set_decrease<uint32_t>())), zip_mul<uint32_t>()), set_multiply<uint32_t>((float)0.5)));
	}

	uint32_t get_max_combination(T_HV<uint32_t>& h_degree){
		return get_max_combination(h_degree.begin(), h_degree.end());
	}

	uint32_t get_max_combination(T_HV<uint32_t>::iterator h_degree_first, T_HV<uint32_t>::iterator h_degree_last){
		return thrust::reduce(
			T_MTI(T_MZIMT(h_degree_first, T_MTI(h_degree_first, set_decrease<uint32_t>())), zip_mul<uint32_t>()),
			T_MTI(T_MZIMT(h_degree_last, T_MTI(h_degree_last, set_decrease<uint32_t>())), zip_mul<uint32_t>()))*0.5;
	}

	T_HV<uint32_t> get_max_combinations_scanned(T_HV<uint32_t>& h_degree){
		T_HV<uint32_t> result(h_degree.size());
		thrust::inclusive_scan(T_MTI(T_MTI(T_MZIMT(h_degree.begin(), T_MTI(h_degree.begin(), set_decrease<uint32_t>())), zip_mul<uint32_t>()), set_multiply<uint32_t>((float)0.5)),
			T_MTI(T_MTI(T_MZIMT(h_degree.end(), T_MTI(h_degree.end(), set_decrease<uint32_t>())), zip_mul<uint32_t>()), set_multiply<uint32_t>((float)0.5)), result.begin());
		return result;
	}

	bool get_intersection(T_HV<pair_t>& h_pairs, T_HV<pair_t>& h_pairs_mirror, T_HV<pair_t>& h_target_mirror, T_HV<uint32_t>& h_target_degree){
		T_HV<uint32_t> h_target_firsts;

		T_HV<uint32_t> h_degree, h_firsts, h_nodes;
		get_degree_mirror(h_pairs_mirror, h_degree);
		get_firsts(h_degree, h_firsts);
		get_nodes(h_pairs_mirror, h_firsts, h_nodes);
		h_firsts.push_back(h_firsts.back() + h_degree.back()); // add last

		h_target_degree.assign(h_pairs.size(), 0);
		thrust::for_each(thrust::host, T_MCI<uint32_t>(0), T_MCI<uint32_t>(h_pairs.size()),
			countCommonNeighbours(RAWD(h_pairs), RAWD(h_pairs_mirror), RAWD(h_nodes), h_nodes.size(), RAWD(h_firsts), h_pairs_mirror.size(), RAWD(h_target_mirror), RAWD(h_target_firsts), RAWD(h_target_degree)));
		h_target_firsts.resize(h_target_degree.size());
		thrust::exclusive_scan(h_target_degree.begin(), h_target_degree.end(), h_target_firsts.begin());

		h_target_mirror.assign(thrust::reduce(h_target_degree.begin(), h_target_degree.end()), pair_t(0, 0));
		if (h_target_mirror.size() > 0){
			thrust::for_each(thrust::host, T_MCI<uint32_t>(0), T_MCI<uint32_t>(h_pairs.size()),
				setCommonNeighbours(RAWD(h_pairs), RAWD(h_pairs_mirror), RAWD(h_nodes), h_nodes.size(), RAWD(h_firsts), h_pairs_mirror.size(), RAWD(h_target_mirror), RAWD(h_target_firsts), RAWD(h_target_degree)));
		}
		h_target_degree.erase(thrust::remove(h_target_degree.begin(), h_target_degree.end(), 0), h_target_degree.end());

		return 1;
	}

	struct increase_community{
		uint32_t* snapVec, *comVec, size, *target_ii, *target_ij;

		__host__ __device__
			increase_community(uint32_t* snapVec, uint32_t* comVec, uint32_t size, uint32_t* target_ii, uint32_t* target_ij) :
			snapVec(snapVec), comVec(comVec), size(size), target_ii(target_ii), target_ij(target_ij) {}

		__host__ __device__
			void operator()(pair_t p){

			// task 1 find common communities
			bool found;
			uint32_t n_first_it = g_binary_search(snapVec, snapVec + size, p.first, found);
			while (n_first_it > 0 && snapVec[n_first_it] == p.first)--n_first_it;
			if (snapVec[n_first_it] != p.first)++n_first_it;

			uint32_t n_seconh_it = g_binary_search(snapVec, snapVec + size, p.second, found);
			while (n_seconh_it > 0 && snapVec[n_seconh_it] == p.second)--n_seconh_it;
			if (snapVec[n_seconh_it] != p.second)++n_seconh_it;

			uint32_t n_first_nd = n_first_it;
			while (n_first_nd < size){
				if (snapVec[n_first_nd] != p.first)
					break;
				target_ij[comVec[n_first_nd]] += 1;
				//atomicAdd((uint32_t*)(target_ij + comVec[n_first_nd]), (uint32_t)1);
				++n_first_nd;
			}

			uint32_t n_seconh_nd = n_seconh_it;
			while (n_seconh_nd < size){
				if (snapVec[n_seconh_nd] != p.second)
					break;
				target_ij[comVec[n_seconh_nd]] += 1;
				//atomicAdd((uint32_t*)(target_ij + comVec[n_seconh_nd]), (uint32_t)1);
				++n_seconh_nd;
			}

			// find common neighbour
			while (n_first_it < size && n_seconh_it < size){
				if (snapVec[n_first_it] != p.first || snapVec[n_seconh_it] != p.second)break;
				if (comVec[n_first_it] == comVec[n_seconh_it]){
					target_ii[comVec[n_first_it]] += 1;
					//atomicAdd((uint32_t*)(target_ii + comVec[n_first_it]), (uint32_t)2);
					++n_first_it;
					++n_seconh_it;
				}
				else if (snapVec[n_first_it] < snapVec[n_seconh_it]){
					++n_first_it;
				}
				else{
					++n_seconh_it;
				}
			}

		}
	};
	/* Equation:
	* ki * kj
	*/
	void get_modularity(comevo::Source sPairs, comevo::Source sSnaps, uint32_t snapId, float &Q){

		vector<uint32_t> scom = sSnaps.get_scom(snapId);
		snapshot_t snap = sSnaps.get_snap(snapId);
		uint32_t com_max = *max_element(scom.begin(), scom.end());
		pairs_t pairs = sPairs.get_edges(snapId);
		T_HV<pair_t> h_pairs(pairs.begin(), pairs.end());
		int eTot = pairs.size();

		// go through all edges
		// store fraction that has both ends in one
		T_HV<uint32_t> eii(scom.size(), 0);
		T_HV<uint32_t> eij(scom.size(), 0);

		T_HV<uint32_t> h_snapVec;
		translate_snapshot_to_vector(snap, h_snapVec);
		T_HV<uint32_t> h_comVec;
		T_HV<uint32_t>h_comSizes(scom.begin(), scom.end());
		translate_scom_to_vector(h_comSizes, h_comVec);
		thrust::sort_by_key(h_snapVec.begin(), h_snapVec.end(), h_comVec.begin());

		thrust::for_each(thrust::host, h_pairs.begin(), h_pairs.end(), increase_community(RAWD(h_snapVec), RAWD(h_comVec), h_snapVec.size(), RAWD(eii), RAWD(eij)));

		Q = thrust::reduce(
			T_MTI(T_MZIMT(eii.begin(), T_MCONSI<uint32_t>(2 * eTot)), zip_div<uint32_t>()),
			T_MTI(T_MZIMT(eii.end(), T_MCONSI<uint32_t>(2 * eTot)), zip_div<uint32_t>()))
			- thrust::reduce(
			T_MTI(T_MTI(T_MZIMT(eij.begin(), T_MCONSI<uint32_t>(2 * eTot)), zip_div<uint32_t>()), set_square<float>()),
			T_MTI(T_MTI(T_MZIMT(eij.end(), T_MCONSI<uint32_t>(2 * eTot)), zip_div<uint32_t>()), set_square<float>()));
	}
}