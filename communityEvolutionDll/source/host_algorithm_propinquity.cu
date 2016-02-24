#include "../stdafx.h"
#include "../include/host_algorithm_propinquity.h"
#include "../include/host_analytic.h"
#include "../include/general_pair_structs.h"
#include "../include/general_comparsion_structs.h"
#include "../include/host_pair.h"
#include "../include/data_info.h"
#include "../include/display_elements.h"
#include "../include/host_pair_construct.h"
#include "../include/general_arithmetic_structs.h"
#include "../include/host_storage_serilization.h"
#include "../include/general_search.h"
#include "../include/general_structs.h"
#include "../include/device_storage_serilization.h"

using namespace std;

namespace comevohost{

#define CPULIMIT 5000000
#define CPULIMIT2 50000000

	struct g_bfs : public thrust::unary_function < uint32_t, uint32_t >
	{
		pair_t* pairs;
		uint32_t* firsts, *nodes, size, nodes_size;
		bool *queue, *visited, *pre_visited;

		__host__ __host__
			g_bfs(pair_t* pairs, uint32_t size, uint32_t* firsts, uint32_t* nodes, uint32_t nodes_size, bool* visited, bool* pre_visited, bool* queue) :
			pairs(pairs), size(size), firsts(firsts), nodes(nodes), nodes_size(nodes_size), visited(visited), pre_visited(pre_visited), queue(queue){}

		__host__ __host__
			void operator()(const uint32_t &x)
		{
			bool found;
			uint32_t count = 0;
			if (!queue[x])return;
			visited[x] = 1;
			// add neighbours
			uint32_t it_first = firsts[x];
			while (it_first < firsts[x + 1]){
				uint32_t v = pairs[it_first].second;
				uint32_t nmb = g_binary_search(nodes, nodes + nodes_size, v, found);
				// check node, add it, if visited
				if (!visited[nmb] && !pre_visited[nmb]){
					queue[nmb] = 1;
				}
				++it_first;
			}
			queue[x] = 0;
			return;

		}
	};

	static uint32_t storageCounter = 0;
	struct get_indices : public thrust::unary_function < uint32_t, bool >
	{
		uint32_t* firsts, *degree, n;
		__host__ __host__
			get_indices(uint32_t* firsts, uint32_t* degree, uint32_t n) : firsts(firsts), degree(degree), n(n){}

		__host__ __host__
			bool operator()(const uint32_t &x){
			for (uint32_t i = 0; i < n; ++i){
				if (firsts[i] + degree[i] > x){
					if (x >= firsts[i])return 1;
					return 0;
				}
			}
			return 0;
		}
	};


	void setStorageCounter(uint32_t value){
		storageCounter = value;
	}

	uint32_t getStorageCounter(){
		return storageCounter;
	}

	bool bfs(T_HV<pair_t>& hs_pairs, T_HV<uint8_t>& propinquities, uint32_t minimum, snapshot_t& communities){
		communities.clear();
		if (propinquities.size() == hs_pairs.size())
			hs_pairs.erase(thrust::remove_if(hs_pairs.begin(), hs_pairs.end(), propinquities.begin(), is_smaller<uint8_t>(minimum)), hs_pairs.end());
		if (hs_pairs.empty())return 0;
		T_HV<uint32_t> hs_degree;
		get_degree(hs_pairs, hs_degree);
		T_HV<pair_t> hs_pairs_mirror(hs_pairs.begin(), hs_pairs.end());
		mirror_pairs_inplace(hs_pairs_mirror);
		uint32_t n = get_number_of_diff_elements(
			T_HV<uint32_t>(T_MTI(hs_pairs_mirror.begin(), first_element()), T_MTI(hs_pairs_mirror.end(), first_element())));
		TH_CLEAR(hs_pairs, pair_t);

		T_HV<uint32_t> hs_firsts, hs_nodes;
		get_firsts(hs_degree, hs_firsts);
		get_nodes(hs_pairs_mirror, hs_firsts, hs_nodes);
		hs_firsts.push_back(hs_firsts.back() + hs_degree.back()); // add last

		// init
		T_HV < bool > hs_queue(n, 0);
		T_HV<bool> hs_visited(n, 0);
		T_HV < bool > h_visited(n);
		T_HV<bool> total_visited(n, 0);
		T_HV<bool> hs_pre_visited(n);
		thrust::transform_if(hs_degree.begin(), hs_degree.end(), hs_pre_visited.begin(), set_value<uint32_t>(1), is_smaller<uint32_t>(1));
		thrust::copy(hs_pre_visited.begin(), hs_pre_visited.end(), total_visited.begin());

		while (total_visited.end() != thrust::find(total_visited.begin(), total_visited.end(), 0)){
			uint32_t s = thrust::find(total_visited.begin(), total_visited.end(), 0) - total_visited.begin();
			thrust::fill(hs_visited.begin(), hs_visited.end(), 0);

			// search from s
			hs_queue[s] = 1;

			// fill queue (check and add neighbours)
			uint32_t q_val = 1;
			do{
				T_TRYCATCH(
					thrust::for_each(thrust::host, T_MCI<U32>(0), T_MCI<U32>(n),
					g_bfs(
					RAWD(hs_pairs_mirror), hs_pairs_mirror.size(),
					RAWD(hs_firsts), RAWD(hs_nodes), hs_nodes.size(),
					RAWD(hs_visited), RAWD(hs_pre_visited), RAWD(hs_queue)
					));
				);
				q_val = thrust::count_if(thrust::host, hs_queue.begin(), hs_queue.end(), is_one<bool>());
			} while (q_val > 0);

			// set total
			thrust::copy(hs_visited.begin(), hs_visited.end(), h_visited.begin());
			thrust::transform(total_visited.begin(), total_visited.end(), h_visited.begin(), total_visited.begin(), thrust::logical_or<bool>());
			thrust::copy(total_visited.begin(), total_visited.end(), hs_pre_visited.begin());

			// create and add com
			T_HV < uint32_t > hs_com(hs_visited.size());
			hs_com.erase(thrust::copy_if(hs_nodes.begin(), hs_nodes.end(), hs_visited.begin(), hs_com.begin(), is_one<bool>()), hs_com.end());
			if (hs_com.size() > 2){
				T_HV < uint32_t > h_com(hs_com.begin(), hs_com.end());
				communities.push_back(vector < uint32_t >(h_com.begin(), h_com.end()));
			}
		}
		return 1;
	}

	/* The idea of this function is to compress stored files to their limit and removing empty files
	*/
	bool compress_files(){
		uint32_t cpuLimit = CPULIMIT;

		T_HV<pair_t> hs_pair(0), hs_fillingPair(0);
		T_HV<uint32_t> hs_val(0), hs_fillingVal(0);
		uint32_t offset, stCount = 0;
		uint32_t count = 0;
		for (uint32_t i = 0; i < storageCounter; ++i){
			cout << i << endl;
			uint32_t count = 0;
			// load data
			hs_pair.clear();
			hs_val.clear();
			if (!to_host_load(hs_pair, "pvp", i, true))return 0;
			if (!to_host_load(hs_val, "pvi", i, true))return 0;
			if (hs_pair.empty())continue;

			cout << i << " " << ++count << endl;
			cout << "size: " << hs_pair.size() << endl;
			if (hs_fillingPair.empty()){
				hs_fillingPair = hs_pair;
				hs_fillingVal = hs_val;
				continue;
			}
			// combine data
			combine_pairs(hs_fillingPair, hs_fillingVal, hs_pair, hs_val);
			// check size
			while (hs_fillingPair.size() > cpuLimit){
				from_host_store(hs_fillingPair, "pvp", 0, cpuLimit, stCount);
				from_host_store(hs_fillingVal, "pvi", 0, cpuLimit, stCount);
				++stCount;
				cout << i << " " << ++count << endl;
				// reduce
				hs_fillingPair.erase(hs_fillingPair.begin(), hs_fillingPair.begin() + cpuLimit);
				hs_fillingVal.erase(hs_fillingVal.begin(), hs_fillingVal.begin() + cpuLimit);
			}
		}
		// store the rest
		if (!from_host_store(hs_fillingPair, "pvp", 0, hs_fillingPair.size(), stCount))return 0;
		if (!from_host_store(hs_fillingVal, "pvi", 0, hs_fillingVal.size(), stCount)) return 0;
		++stCount;
		storageCounter = stCount;
		return 1;
	}
	uint32_t global_snap_id;
	bool cummulate_pairs(T_HV<pair_t>& hs_pairs, uint32_t offset, T_HV<uint32_t>& hs_cn){
		hs_cn.resize(hs_pairs.size(), 0);
		if (hs_pairs.empty())return 1;
		T_HV<bool> hs_found(hs_pairs.size());

		for (int i = offset; i < storageCounter; ++i){

			// load and init
			T_HV<pair_t>hs_pPair;
			T_HV<uint32_t>hs_pVal;
			if (!to_host_load(hs_pPair, "pvp", i, true))return 0;
			if (!to_host_load(hs_pVal, "pvi", i, true))return 0;
			if (hs_pPair.size() == 0 || hs_pPair.size() != hs_pVal.size()){
				if (!from_host_store(hs_pPair, "pvp", 0, 0, i))return 0;
				if (!from_host_store(hs_pVal, "pvi", 0, 0, i))return 0;
				continue;
			}
			combine_values(hs_pairs, hs_cn, hs_pPair, hs_pVal);

			T_HV<bool> hs_found(hs_pPair.size(), 0);
			thrust::binary_search(thrust::host, hs_pairs.begin(), hs_pairs.end(), hs_pPair.begin(), hs_pPair.end(), hs_found.begin());
		
			T_TRYCATCH(
				hs_pPair.erase(thrust::remove_if(hs_pPair.begin(), hs_pPair.end(), hs_found.begin(), is_one<bool>()), hs_pPair.end());
				hs_pVal.erase(thrust::remove_if(hs_pVal.begin(), hs_pVal.end(), hs_found.begin(), is_one<bool>()), hs_pVal.end());
				)

			// store
			if (!from_host_store(hs_pPair, "pvp", 0, hs_pPair.size(), i))return 0;
			if (!from_host_store(hs_pVal, "pvi", 0, hs_pVal.size(), i))return 0;
		}
		return 1;
	}

	bool set_new_pairs(T_HV<pair_t>& hs_pairs, uint32_t beta, T_HV<uint32_t>& hs_propinquity){

		for (int i = 0; i < storageCounter; ++i){
			T_HV<pair_t>hs_pPair;
			T_HV<uint32_t>hs_pVal;
			if (!to_host_load(hs_pPair, "pvp", i, true))return 0;
			if (!to_host_load(hs_pVal, "pvi", i, true))return 0;
			if (hs_pPair.size() == 0)continue;
			cummulate_pairs(hs_pPair, i + 1, hs_pVal);

			// 1. count relevant nodes
			uint32_t n_new_nodes = thrust::count_if(hs_pVal.begin(), hs_pVal.end(), is_greater<uint32_t>(beta - 1));
			uint32_t oldSize = hs_propinquity.size();
			hs_propinquity.resize(hs_propinquity.size() + n_new_nodes);

			uint32_t olhs_size = hs_pairs.size();
			hs_pairs.resize(hs_pairs.size() + n_new_nodes);

			// add relevant nodes
			thrust::copy_if(
				hs_pPair.begin(),
				hs_pPair.end(),
				hs_pVal.begin(),
				hs_pairs.begin() + olhs_size,
				is_greater<uint32_t>(beta - 1));
			thrust::copy_if(hs_pVal.begin(), hs_pVal.end(), hs_propinquity.begin() + oldSize, is_greater<uint32_t>(beta - 1));

			thrust::sort_by_key(hs_pairs.begin(), hs_pairs.end(), hs_propinquity.begin());
		}
		hs_pairs.resize(thrust::unique(hs_pairs.begin(), hs_pairs.end()) - hs_pairs.begin());
		return 1;
	}

	bool handle_increment(T_HV<pair_t>& all_pairs){
		T_HV<uint32_t>::iterator new_enhs_i;
		T_HV<pair_t>::iterator new_enhs_p;
		T_HV<pair_t>::iterator h_new_enhs_p;
		// sort and create map

		thrust::stable_sort(all_pairs.begin(), all_pairs.end());
		T_HV<pair_t> hs_unique_pairs;
		T_HV<uint32_t> hs_unique_values;
		get_count(all_pairs, hs_unique_pairs, hs_unique_values);

		uint32_t offset = 0;
		do{
			uint32_t allocate = min(CPULIMIT, hs_unique_pairs.size() - offset);
			from_host_store(hs_unique_pairs, "pvp", offset, allocate, storageCounter);
			from_host_store(hs_unique_values, "pvi", offset, allocate, storageCounter);

			offset += allocate;
			++storageCounter;
		} while (offset != hs_unique_pairs.size());

		return 1;
	}

	// needs mirror
	T_HV<pair_t> get_specific_pairs(T_HV<pair_t> &h_pairs, T_HV<uint32_t> &hs_firsts, T_HV<uint32_t> &hs_degree, T_HV<uint32_t> &hs_id){
		thrust::sort(hs_id.begin(), hs_id.end());
		T_HV<uint32_t> hs_degree_red, hs_firsts_red;
		hs_firsts_red.assign(
			T_MPI(hs_firsts.begin(), hs_id.begin()),
			T_MPI(hs_firsts.begin(), hs_id.end()));
		hs_degree_red.assign(
			T_MPI(hs_degree.begin(), hs_id.begin()),
			T_MPI(hs_degree.begin(), hs_id.end()));

		T_HV<uint32_t> hs_indices(thrust::reduce(hs_degree_red.begin(), hs_degree_red.end()), 0);
		thrust::copy_if(T_MCI<uint32_t>(0), T_MCI<uint32_t>(h_pairs.size()), hs_indices.begin(), get_indices(RAWD(hs_firsts_red), RAWD(hs_degree_red), hs_firsts_red.size()));
		TH_CLEAR(hs_firsts_red, uint32_t);
		TH_CLEAR(hs_degree_red, uint32_t);

		T_HV<uint32_t> h_indices(hs_indices.begin(), hs_indices.end());
		TH_CLEAR(hs_indices, uint32_t);
		T_HV<pair_t> hs_pairs(T_MPI(h_pairs.begin(), h_indices.begin()), T_MPI(h_pairs.begin(), h_indices.end()));
		return hs_pairs;
	}
	
	// needs mirrored
	bool couple_increment(T_HV<pair_t> &h_pairs, T_HV<uint32_t> &hs_degree, T_HV<uint32_t> &hs_firsts, uint32_t limit){

		if (h_pairs.size() == 0) return 1;
		// 3. split in small and big 
		// 3.1 calculate degree_limit
		T_HV<uint32_t> hs_smallId(0);
		T_HV<uint32_t> hs_idStorage(T_MCI<uint32_t>(0), T_MCI<uint32_t>(hs_degree.size()));

		T_HV<uint32_t> hs_degree_sorted(hs_degree.begin(), hs_degree.end());
		thrust::stable_sort_by_key(hs_degree_sorted.begin(), hs_degree_sorted.end(), hs_idStorage.begin());
		T_HV<uint32_t> scancombinations = get_max_combinations_scanned(hs_degree_sorted);
		TH_CLEAR(hs_degree_sorted, uint32_t);

		// space calculaion:
		uint32_t possiblePairs = limit; //  availableMemory;
		uint32_t possiblePairsBig = limit * 1000; //  availableMemory

		// calculate small ones until 90% done
		uint32_t limitId, doneId = 0, handled = 0, run = 0;

		// else not possible
		uint32_t limitPairs = possiblePairs;
		bool small = true;
		cout << "in the end: " << scancombinations.back() << " ids: " << hs_idStorage.size() << endl;
		if (scancombinations[0] < possiblePairsBig){
			do{
				limitId = thrust::upper_bound(scancombinations.begin(), scancombinations.end(), handled + limitPairs) - scancombinations.begin();

				if (limitId == doneId){
					return 1;
					if (doneId < scancombinations.size())
						cout << scancombinations[limitId] - handled << endl;
					cout << scancombinations.back() - handled << endl;
					scancombinations[limitId];

					limitPairs = possiblePairsBig;
					small = false;
					cout << "switch to big" << endl;
					continue;
				}
				++run;
				uint32_t cur_size = scancombinations[limitId - 1] - handled;
				cout << "handling this time run(" << run << "): " << cur_size << " doing: " << limitId << "todo: " << scancombinations.back() - handled << endl;
				if (cur_size != 0){
					hs_smallId.assign(hs_idStorage.begin() + doneId, hs_idStorage.begin() + limitId);

					// get pairs and work on it

					T_HV<pair_t> hs_pairs = get_specific_pairs(h_pairs, hs_firsts, hs_degree, hs_smallId);
					TH_CLEAR(hs_smallId, uint32_t);
					T_HV<pair_t>hs_target(0);
					if (small){
						if (!generate_pairs(hs_pairs, hs_target))return 0;
						if (!handle_increment(hs_target))return 0;
					}
					else{
						bool done = false;
						uint32_t off = 0;
						while (!done){
							if (!generate_pairs_limit(hs_pairs, hs_target, off, limit, done))return 0;
							//display_vector<uint32_t, uint32_t>(hs_target, "hs_target");
							if (!handle_increment(hs_target))return 0;
						}
					}
					TH_CLEAR(hs_pairs, pair_t);
				}
				doneId = limitId;
				handled = scancombinations[limitId - 1];
			} while (limitId / hs_idStorage.size() < 1);
		}
		else{
			cerr << "problem with size!" << endl;
		}

		return 1;
	}

	bool calculate_propinquity(T_HV<pair_t>& h_pairs){
		storageCounter = 0;
		T_HV<uint32_t> h_values(h_pairs.size(), 1);
		comevohost::from_host_store(h_pairs, "pvp", 0, h_pairs.size(), storageCounter);
		comevohost::from_host_store(h_values, "pvi", 0, h_values.size(), storageCounter);
		/*comevo::Serilization::store(T_HV<uint32_t>(
		T_MTI(h_pairs.begin(), first_element()),
		T_MTI(h_pairs.end(), first_element()))
		, "pvpf", storageCounter);
		comevo::Serilization::store(T_HV<uint32_t>(
		T_MTI(h_pairs.begin(), seconhs_element()),
		T_MTI(h_pairs.end(), seconhs_element()))
		, "pvps", storageCounter);
		comevo::Serilization::store(h_values, "pvi", storageCounter);*/
		h_values.clear();
		++storageCounter;

		T_HV<uint32_t> hs_degree, hs_firsts;
		T_HV<pair_t>hs_pairs_mirror(h_pairs.begin(), h_pairs.end());
		mirror_pairs_inplace(hs_pairs_mirror);
		T_HV<pair_t> h_pairs_mirror(hs_pairs_mirror.begin(), hs_pairs_mirror.end());

		get_degree_mirror(T_HV<uint32_t>(T_MTI(hs_pairs_mirror.begin(), first_element()), T_MTI(hs_pairs_mirror.end(), first_element())), hs_degree);
		get_firsts(hs_degree, hs_firsts);
		TH_CLEAR(hs_pairs_mirror, pair_t);

		// 2. get limit (device_info)
		//pair_t p = get_device_memory();
		uint32_t availableMemory = (CPULIMIT2)* 0.9;
		uint32_t n = hs_degree.size();
		uint32_t m = h_pairs_mirror.size();

		uint32_t A = (availableMemory / 8 - (4 * n + 4 * m)) / 2;
		uint32_t B = (availableMemory / 8 - (4 * n + 2 * m)) / 5;
		uint32_t C = min(A, B);
		printf("avl: %d A: %d B: %d, C: %d \n", availableMemory, A, B, C);
		couple_increment(h_pairs_mirror, hs_degree, hs_firsts, C);

		T_HV<pair_t>hs_intersection;
		get_intersection(T_HV<pair_t>(h_pairs.begin(), h_pairs.end()), T_HV<pair_t>(h_pairs_mirror.begin(), h_pairs_mirror.end()), hs_intersection, hs_degree);
		if (hs_intersection.size() > 0){
			h_pairs_mirror.assign(hs_intersection.begin(), hs_intersection.end());
			TH_CLEAR(hs_intersection, pair_t);
			get_firsts(hs_degree, hs_firsts);

			couple_increment(h_pairs_mirror, hs_degree, hs_firsts, C);
		}
		TH_CLEAR(hs_intersection, pair_t);


		return 1;
	}

	bool update_graph(T_HV<pair_t>& h_pairs, Threshold &threshold, T_HV<uint32_t>& h_propinquity){
		// A: consider limits
		T_HV<pair_t> hs_pairs;
		T_HV<uint32_t> hs_degree, hs_firsts;
		hs_pairs.assign(h_pairs.begin(), h_pairs.end());

		// remove if lower than alpha, add if higher than beta
		// 1. find and remove existing ones, 
		T_HV<uint32_t> hs_cn;
		cummulate_pairs(hs_pairs, 0, hs_cn);

		// 2. if val low alpha remove
		hs_pairs.erase(thrust::remove_if(hs_pairs.begin(), hs_pairs.end(), hs_cn.begin(), is_smaller<uint32_t>(threshold.alpha)), hs_pairs.end());
		hs_cn.erase(thrust::remove_if(hs_cn.begin(), hs_cn.end(), is_smaller<uint32_t>(threshold.alpha)), hs_cn.end());
		// sumup all other pairs
		set_new_pairs(hs_pairs, threshold.beta, hs_cn);
		h_propinquity.assign(hs_cn.begin(), hs_cn.end());
		h_pairs.assign(hs_pairs.begin(), hs_pairs.end());

		return 1;
	}

	bool algorithm_propinquity(comevo::Source &source, comevo::Source &target, uint32_t from, uint32_t to, Threshold &threshold, uint32_t bfsMinimum, uint32_t maxIterations, uint32_t maxSnap){
		U32 propinquityLimit = maxIterations;
		U32 nSnaps = source.get_n().size(); // number of Snaps
		if (maxSnap != 0)nSnaps = maxSnap;
		vector<snapshot_t> snaps;
		for (U32 snapId = 0; snapId != nSnaps; ++snapId){
			cout << endl;
			cout << "snap: " << snapId << endl;
			global_snap_id = snapId;
			storageCounter = 0;
			snapshot_t communities(0);
			// get edges
			// A: consider limits
			uint32_t nPairs = source.get_m(snapId);
			if (nPairs == 0){
				snaps.push_back(communities);
				continue;
			}

			// 1. get degree
			T_HV<pair_t> h_pairs;
			T_HV<uint32_t> h_propinquity(0);
			if (to != 0)h_pairs = source.get_edges(snapId, from, to);
			if (to == 0)h_pairs = source.get_edges(snapId);
			uint32_t oldSize;
			// calc prop
			for (U32 run = 0; run < propinquityLimit; ++run){
				cout << "iteration: " << run << endl;
				if (h_pairs.empty())break;
				//display_vector<uint32_t, uint32_t>(h_pairs, "h_pairs");

				if (!calculate_propinquity(h_pairs))return 0;
				//cout << "stc: " << storageCounter << endl;
				// compress
				//if(!compress_files())return 0;
				// update
				oldSize = h_pairs.size();
				if (!update_graph(h_pairs, threshold, h_propinquity))return 0;
				storageCounter = 0;

				if (run > 2 && oldSize == h_pairs.size())break;
				//display_vector<uint32_t>(h_propinquity, "h_propinquity");
			}
			communities.clear();
			if (!h_pairs.empty())
				bfs(T_HV<pair_t>(h_pairs.begin(), h_pairs.end()), T_HV<uint8_t>(0), bfsMinimum, communities);
			snaps.push_back(communities);
		}
		vector<pairs_t> vecPairs;
		if (!target.set_source(vecPairs, snaps, SNAPS))return 0;


		return 1;
	}

}