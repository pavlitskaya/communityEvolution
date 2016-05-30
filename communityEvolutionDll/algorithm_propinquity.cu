#include "stdafx.h"
#include "include/algorithm_propinquity.h"
#include "include/device_analytic.h"
#include "include/general_pair_structs.h"
#include "include/general_comparsion_structs.h"
#include "include/device_pair.h"
#include "include/data_info.h"
#include "include/display_elements.h"
#include "include/device_pair_construct.h"
#include "include/general_arithmetic_structs.h"
#include "include/host_storage_serilization.h"
#include "include/general_search.h"
#include "include/device_storage_serilization.h"

using namespace std;

#define CPULIMIT 2500000

struct d_bfs : public thrust::unary_function < uint32_t, uint32_t >
{
	pair_t* pairs;
	uint32_t* firsts, *nodes, size, nodes_size;
	bool *queue, *visited, *pre_visited;

	__host__ __device__
		d_bfs(pair_t* pairs, uint32_t size, uint32_t* firsts, uint32_t* nodes, uint32_t nodes_size, bool* visited, bool* pre_visited, bool* queue) :
		pairs(pairs), size(size), firsts(firsts), nodes(nodes), nodes_size(nodes_size), visited(visited), pre_visited(pre_visited), queue(queue){}

	__host__ __device__
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
	__host__ __device__
		get_indices(uint32_t* firsts, uint32_t* degree, uint32_t n) : firsts(firsts), degree(degree), n(n){}

	__host__ __device__
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

bool bfs(T_DV<pair_t>& d_pairs, T_DV<uint8_t>& propinquities, uint32_t minimum, snapshot_t& communities){
	communities.clear();
	if (propinquities.size() == d_pairs.size())
		d_pairs.erase(thrust::remove_if(d_pairs.begin(), d_pairs.end(), propinquities.begin(), is_smaller<uint8_t>(minimum)), d_pairs.end());
	if (d_pairs.empty())return 0;
	T_DV<uint32_t> d_degree;
	get_degree(d_pairs, d_degree);
	T_DV<pair_t> d_pairs_mirror(d_pairs.begin(), d_pairs.end());
	mirror_pairs_inplace(d_pairs_mirror);
    T_DV<uint32_t> number_of_different_elements(T_MTI(d_pairs_mirror.begin(), first_element()), T_MTI(d_pairs_mirror.end(), first_element()));
    uint32_t n = get_number_of_diff_elements(number_of_different_elements);
	T_CLEAR(d_pairs, pair_t);

	T_DV<uint32_t> d_firsts, d_nodes;
	get_firsts(d_degree, d_firsts);
	get_nodes(d_pairs_mirror, d_firsts, d_nodes);
	d_firsts.push_back(d_firsts.back() + d_degree.back()); // add last

	// init
	T_DV < bool > d_queue(n, 0);
	T_DV<bool> d_visited(n, 0);
	T_HV < bool > h_visited(n);
	T_HV<bool> total_visited(n, 0);
	T_DV<bool> d_pre_visited(n);
	thrust::transform_if(d_degree.begin(), d_degree.end(), d_pre_visited.begin(), set_value<uint32_t>(1), is_smaller<uint32_t>(1));
	thrust::copy(d_pre_visited.begin(), d_pre_visited.end(), total_visited.begin());

	while (total_visited.end() != thrust::find(total_visited.begin(), total_visited.end(), 0)){
		uint32_t s = thrust::find(total_visited.begin(), total_visited.end(), 0) - total_visited.begin();
		thrust::fill(d_visited.begin(), d_visited.end(), 0);

		// search from s
		d_queue[s] = 1;

		// fill queue (check and add neighbours)
		uint32_t q_val = 1;
		do{
			T_TRYCATCH(
				thrust::for_each(T_MCI<U32>(0), T_MCI<U32>(n),
				d_bfs(
				RAWD(d_pairs_mirror), d_pairs_mirror.size(),
				RAWD(d_firsts), RAWD(d_nodes), d_nodes.size(),
				RAWD(d_visited), RAWD(d_pre_visited), RAWD(d_queue)
				));
			);
			q_val = thrust::count_if(d_queue.begin(), d_queue.end(), thrust::identity<bool>());
		} while (q_val > 0);

		// set total
		thrust::copy(d_visited.begin(), d_visited.end(), h_visited.begin());
		thrust::transform(total_visited.begin(), total_visited.end(), h_visited.begin(), total_visited.begin(), thrust::logical_or<bool>());
		thrust::copy(total_visited.begin(), total_visited.end(), d_pre_visited.begin());

		// create and add com
		T_DV < uint32_t > d_com(d_visited.size());
			d_com.erase(thrust::copy_if(d_nodes.begin(), d_nodes.end(), d_visited.begin(), d_com.begin(), thrust::identity<bool>()), d_com.end());
		if (d_com.size() > 2){
			T_HV < uint32_t > h_com(d_com.begin(), d_com.end());
			communities.push_back(vector < uint32_t >(h_com.begin(), h_com.end()));
		}
	}
	return 1;
}

/* The idea of this function is to compress stored files to their limit and removing empty files
 */
bool compress_files(){
	uint32_t cpuLimit = CPULIMIT;

	T_DV<pair_t> d_pair(0), d_fillingPair(0); 
	T_DV<uint32_t> d_val(0), d_fillingVal(0);
	uint32_t offset, stCount = 0;
	uint32_t count = 0;
	for (uint32_t i = 0; i < storageCounter; ++i){
		cout << i << endl;
		uint32_t count = 0;
		// load data
		d_pair.clear();
		d_val.clear();
		if (!to_device_load(d_pair, "pvp", i, true))return 0;
		if (!to_device_load(d_val, "pvi", i, true))return 0;
		if (d_pair.empty())continue;

		cout << i << " " << ++count << endl;
		cout << "size: " << d_pair.size() << endl;
		if (d_fillingPair.empty()){
			d_fillingPair = d_pair;
			d_fillingVal = d_val;
			continue;
		}
		// combine data
		combine_pairs(d_fillingPair, d_fillingVal, d_pair, d_val);
		// check size
		while (d_fillingPair.size() > cpuLimit){
			from_device_store(d_fillingPair, "pvp", 0, cpuLimit, stCount);
			from_device_store(d_fillingVal, "pvi", 0, cpuLimit, stCount);
			++stCount;
			cout << i << " " << ++count << endl;
			// reduce
			d_fillingPair.erase(d_fillingPair.begin(), d_fillingPair.begin() + cpuLimit);
			d_fillingVal.erase(d_fillingVal.begin(), d_fillingVal.begin() + cpuLimit);
		}
	}
	// store the rest
	if (!from_device_store(d_fillingPair, "pvp", 0, d_fillingPair.size(), stCount))return 0;
	if (!from_device_store(d_fillingVal, "pvi", 0, d_fillingVal.size(), stCount)) return 0;
	++stCount;
	storageCounter = stCount;
	return 1;
}

bool cummulate_pairs(T_DV<pair_t>& d_pairs, uint32_t offset, T_DV<uint32_t>& d_cn){
	d_cn.resize(d_pairs.size(), 0);
	if (d_pairs.empty())return 1;
	T_DV<bool> d_found(d_pairs.size());

	for (int i = offset; i < storageCounter; ++i){

		// load and init
		T_DV<pair_t>d_pPair;
		T_DV<uint32_t>d_pVal;
		if (!to_device_load(d_pPair, "pvp", i, true))return 0;
		if (!to_device_load(d_pVal, "pvi", i, true))return 0;
		if (d_pPair.size() == 0 || d_pPair.size() != d_pVal.size()){
			if (!from_device_store(d_pPair, "pvp", 0, 0, i))return 0;
			if (!from_device_store(d_pVal, "pvi", 0, 0, i))return 0;
			continue;
		}
		combine_values(d_pairs, d_cn, d_pPair, d_pVal);
		
		T_DV<bool> d_found(d_pPair.size(), 0);
		//T_DV<bool> d_found(_max(d_pPair.size(), d_pairs.size()));
		//thrust::binary_search(d_pPair.begin(), d_pPair.end(), d_pairs.begin(), d_pairs.end(), d_found.begin());
		thrust::binary_search(d_pairs.begin(), d_pairs.end(), d_pPair.begin(), d_pPair.end(), d_found.begin());
		d_pPair.erase(thrust::remove_if(d_pPair.begin(), d_pPair.end(), d_found.begin(), thrust::identity<bool>()), d_pPair.end());
		d_pVal.erase(thrust::remove_if(d_pVal.begin(), d_pVal.end(), d_found.begin(), thrust::identity<bool>()), d_pVal.end());

		// store
		if (!from_device_store(d_pPair, "pvp", 0, d_pPair.size(), i))return 0;
		if (!from_device_store(d_pVal, "pvi", 0, d_pVal.size(), i))return 0;
	}
	return 1;
}

bool set_new_pairs(T_DV<pair_t>& d_pairs, uint32_t beta, T_DV<uint32_t>& d_propinquity){

	for (int i = 0; i < storageCounter; ++i){
		T_DV<pair_t>d_pPair;
		T_DV<uint32_t>d_pVal;
		if (!to_device_load(d_pPair, "pvp", i, true))return 0;
		if (!to_device_load(d_pVal, "pvi", i, true))return 0;
		if (d_pPair.size() == 0)continue;
		cummulate_pairs(d_pPair, i + 1, d_pVal);

		// 1. count relevant nodes
		uint32_t n_new_nodes = thrust::count_if(d_pVal.begin(), d_pVal.end(), is_greater<uint32_t>(beta - 1));
		uint32_t oldSize = d_propinquity.size();
		d_propinquity.resize(d_propinquity.size() + n_new_nodes);

		uint32_t old_size = d_pairs.size();
		d_pairs.resize(d_pairs.size() + n_new_nodes);

		// add relevant nodes
		thrust::copy_if(
			d_pPair.begin(),
			d_pPair.end(),
			d_pVal.begin(),
			d_pairs.begin() + old_size,
			is_greater<uint32_t>(beta - 1));
		thrust::copy_if(d_pVal.begin(), d_pVal.end(), d_propinquity.begin() + oldSize, is_greater<uint32_t>(beta - 1));

		thrust::sort_by_key(d_pairs.begin(), d_pairs.end(), d_propinquity.begin());
	}
	d_pairs.resize(thrust::unique(d_pairs.begin(), d_pairs.end()) - d_pairs.begin());
	return 1;
}

bool handle_increment(T_DV<pair_t>& all_pairs){
	T_DV<uint32_t>::iterator new_end_i;
	T_DV<pair_t>::iterator new_end_p;
	T_HV<pair_t>::iterator h_new_end_p;
	// sort and create map
	T_TRYCATCH(
		thrust::stable_sort(all_pairs.begin(), all_pairs.end()););
	T_DV<pair_t> d_unique_pairs;
	T_DV<uint32_t> d_unique_values;
	get_count(all_pairs, d_unique_pairs, d_unique_values);

	uint32_t offset = 0;
	do{
        uint32_t allocate = min((unsigned long long)CPULIMIT, (unsigned long long)(d_unique_pairs.size() - offset));
		from_device_store(d_unique_pairs, "pvp", offset, allocate, storageCounter);
		from_device_store(d_unique_values, "pvi", offset, allocate, storageCounter);
		
		offset += allocate;
		++storageCounter;
	} while (offset != d_unique_pairs.size());
	
	return 1;
}

// needs mirror
T_DV<pair_t> get_specific_pairs(T_DV<pair_t> &d_pairs, T_DV<uint32_t> &d_firsts, T_DV<uint32_t> &d_degree, T_DV<uint32_t> &d_id){

	thrust::sort(d_id.begin(), d_id.end());
	T_DV<uint32_t> d_degree_red, d_firsts_red;
	d_firsts_red.assign(
		T_MPI(d_firsts.begin(), d_id.begin()),
		T_MPI(d_firsts.begin(), d_id.end()));
	d_degree_red.assign(
		T_MPI(d_degree.begin(), d_id.begin()),
		T_MPI(d_degree.begin(), d_id.end()));
	cout << "id: " << d_id.size() << endl;

	//T_DV<pair_t> d_pairs(h_pairs.begin(), h_pairs.end());

	T_DV<uint32_t> d_indices(thrust::reduce(d_degree_red.begin(), d_degree_red.end()), 0);
	T_TRYCATCH(
		for (uint32_t i = 0; i < d_pairs.size(); i += 50000){
		thrust::copy_if(T_MCI<uint32_t>(i), T_MCI<uint32_t>(min(i + 50000, (unsigned int)d_pairs.size())), d_indices.begin(), get_indices(RAWD(d_firsts_red), RAWD(d_degree_red), d_firsts_red.size()));
		})

	T_CLEAR(d_firsts_red, uint32_t);
	T_CLEAR(d_degree_red, uint32_t);

	//T_DV<uint32_t> h_indices(d_indices.begin(), d_indices.end());
	T_DV<pair_t> d_pairsResult(T_MPI(d_pairs.begin(), d_indices.begin()), T_MPI(d_pairs.begin(), d_indices.end()));
	T_CLEAR(d_indices, uint32_t);
	return d_pairsResult;
}

// needs mirrored
bool couple_increment(T_DV<pair_t> &d_pairs, T_DV<uint32_t> &d_degree, T_DV<uint32_t> &d_firsts, uint32_t limit){

	if (d_pairs.size() == 0) return 1;
	// 3. split in small and big 
	// 3.1 calculate degree_limit
	T_DV<uint32_t> d_smallId(0);
	T_DV<uint32_t> d_idStorage(T_MCI<uint32_t>(0), T_MCI<uint32_t>(d_degree.size()));

	T_DV<uint32_t> d_degree_sorted(d_degree.begin(), d_degree.end());
	thrust::stable_sort_by_key(d_degree_sorted.begin(), d_degree_sorted.end(), d_idStorage.begin());
	T_DV<uint32_t> scancombinations = get_max_combinations_scanned(d_degree_sorted);
	T_CLEAR(d_degree_sorted, uint32_t);

	// space calculaion:
	uint32_t possiblePairs = limit; //  availableMemory;
	uint32_t possiblePairsBig = limit * 1000; //  availableMemory

	// calculate small ones until 90% done
	uint32_t limitId, doneId = 0, handled = 0, run = 0;

	// else not possible
	uint32_t limitPairs = possiblePairs;
	bool small = true;
	cout << "in the end: " << scancombinations.back() << " ids: " << d_idStorage.size() << endl;
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
			cout << "handling this time run(" << run << "): " << cur_size << " doing Id: " << limitId << "todo: " << scancombinations.back() - handled << endl;
			if (cur_size != 0){
				d_smallId.assign(d_idStorage.begin() + doneId, d_idStorage.begin() + limitId);

				// get pairs and work on it

				T_DV<pair_t> d_pairs2 = get_specific_pairs(d_pairs, d_firsts, d_degree, d_smallId);
				T_CLEAR(d_smallId, uint32_t);
				T_DV<pair_t>d_target(0);
				if (small){
					cout << "dpairs: " << d_pairs2.size() << endl;
					if (!generate_pairs(d_pairs2, d_target))return 0;
					if (!handle_increment(d_target))return 0;
				}
				else{
					bool done = false;
					uint32_t off = 0;
					while (!done){
						if (!generate_pairs_limit(d_pairs2, d_target, off, limit, done))return 0;
						if (!handle_increment(d_target))return 0;
					}
				}
				T_CLEAR(d_pairs2, pair_t);
			}
			doneId = limitId;
			handled = scancombinations[limitId - 1];
		} while (limitId / d_idStorage.size() < 1);
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
	
	h_values.clear();
	++storageCounter;

	T_DV<uint32_t> d_degree, d_firsts;
	T_DV<pair_t>d_pairs_mirror(h_pairs.begin(), h_pairs.end());
	mirror_pairs_inplace(d_pairs_mirror);
	//T_HV<pair_t> h_pairs_mirror(d_pairs_mirror.begin(), d_pairs_mirror.end());

    T_DV<uint32_t> degree_mirror(T_MTI(d_pairs_mirror.begin(), first_element()), T_MTI(d_pairs_mirror.end(), first_element()));
    get_degree_mirror(degree_mirror, d_degree);
	get_firsts(d_degree, d_firsts);
	//T_CLEAR(d_pairs_mirror, pair_t);

	// 2. get limit (device_info)
	pair_t p = get_device_memory();
	uint32_t availableMemory = p.first * 0.7;
	uint32_t n = d_degree.size();
	uint32_t m = d_pairs_mirror.size();

	uint32_t A = (availableMemory/8 - (4 * n + 4 * m)) / 2;
	uint32_t B = (availableMemory/8 - (4 * n + 2 * m)) / 5;
	uint32_t C = min(A, B);
	printf("avl: %d A: %d B: %d, C: %d \n", availableMemory, A, B, C);
	couple_increment(d_pairs_mirror, d_degree, d_firsts, C);
	
	T_DV<pair_t>d_intersection;
    T_DV<pair_t> pairs(h_pairs.begin(), h_pairs.end());
    T_DV<pair_t> pairs_mirror(d_pairs_mirror.begin(), d_pairs_mirror.end());
    get_intersection(pairs, pairs_mirror, d_intersection, d_degree);
	if (d_intersection.size() > 0){
		d_pairs_mirror.assign(d_intersection.begin(), d_intersection.end());
		T_CLEAR(d_intersection, pair_t);
		get_firsts(d_degree, d_firsts);

		couple_increment(d_pairs_mirror, d_degree, d_firsts, C);
	}
	T_CLEAR(d_intersection, pair_t);


	return 1;
}

bool update_graph(T_HV<pair_t>& h_pairs, Threshold &threshold, T_HV<uint32_t>& h_propinquity){
	// A: consider limits
	T_DV<pair_t> d_pairs;
	T_DV<uint32_t> d_degree, d_firsts;
	d_pairs.assign(h_pairs.begin(), h_pairs.end());

	// remove if lower than alpha, add if higher than beta
	// 1. find and remove existing ones, 
	T_DV<uint32_t> d_cn;
	cummulate_pairs(d_pairs, 0, d_cn);

	// 2. if val low alpha remove
	d_pairs.erase(thrust::remove_if(d_pairs.begin(), d_pairs.end(), d_cn.begin(), is_smaller<uint32_t>(threshold.alpha)), d_pairs.end());
	d_cn.erase(thrust::remove_if(d_cn.begin(), d_cn.end(), is_smaller<uint32_t>(threshold.alpha)), d_cn.end());
	// sumup all other pairs
	set_new_pairs(d_pairs, threshold.beta, d_cn);
	h_propinquity.assign(d_cn.begin(), d_cn.end());
	h_pairs.assign(d_pairs.begin(), d_pairs.end());

	return 1;
}

bool algorithm_propinquity(comevo::Source &source, comevo::Source &target, uint32_t from, uint32_t to, Threshold &threshold, uint32_t bfsMinimum, uint32_t maxIterations, uint32_t maxSnap){
	U32 propinquityLimit = maxIterations;
	U32 nSnaps = source.get_n().size(); // number of Snaps
	if (maxSnap != 0)nSnaps = maxSnap;
	
	vector<snapshot_t> snaps;
	for (U32 snapId = 0; snapId < nSnaps; ++snapId){
		cout << endl;
		cout << "snap: " << snapId << endl;
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
			cout << "from " << oldSize << " to " << h_pairs.size() << endl;

			if (run > 2 && oldSize == h_pairs.size())break;
			//display_vector<uint32_t>(h_propinquity, "h_propinquity");
		}
		communities.clear();
        if (!h_pairs.empty()) {
            T_DV<pair_t> pairs(h_pairs.begin(), h_pairs.end());
            T_DV<uint8_t> propinqueties(0);
            bfs(pairs, propinqueties, bfsMinimum, communities);
        }
		snaps.push_back(communities);
	}
	vector<pairs_t> vecPairs;
	if(!target.set_source(vecPairs, snaps, SNAPS))return 0;


	return 1;
}
