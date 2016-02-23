#include "../stdafx.h"
#include "../include/host_algorithm_clique.h"
#include "../include/host_analytic.h"
#include "../include/general_comparsion_structs.h"

using namespace std;

namespace comevohost{

	bool generate_clique(T_HV<pair_t>& pairs, uint32_t minimumClique, T_HV<uint32_t>& cliques, T_HV<uint32_t>& cliquesFirst){

		T_HV<uint32_t> degree, firsts, nodes;
		get_degree(pairs, degree);
		get_firsts(degree, firsts);
		get_nodes(pairs, firsts, nodes);
		uint32_t n = nodes.size();
		T_HV<uint32_t> nodeId(T_MCI<uint32_t>(0), T_MCI<uint32_t>(nodes.size()));
		
		display_vector<uint32_t>(degree, "degree");
		display_vector<uint32_t>(nodeId, "nodeId");

		thrust::sort_by_key(degree.begin(), degree.end(), nodeId.begin(), thrust::greater<uint32_t>());

		display_vector<uint32_t>(degree, "degree");
		display_vector<uint32_t>(nodeId, "nodeId");

		//uint32_t id = thrust::find(T_MZIMT(T_MCI<uint32_t>(n), degree.begin()), T_MZIMT(T_MCI<uint32_t>(0), degree.end()), is_smaller_equal_zip<uint32_t>()) - T_MZIMT(T_MCI<uint32_t>(n), degree.begin());
		
		/*
get_degree(pairs, degree)
get_nodes(pairs, nodes)
sort_by_key(degree, descend, nodes)
ids()
id = find(T_MCI, T_MCI, degree.begin(), is_greater())
rel_nodes(T_MPI(nodes, ids(0)), T_MPI(nodes, ids(id)));
*/

		return 1;
	}

	bool generate_communities(T_HV<uint32_t>& nodes, T_HV<uint32_t>& cliques, T_HV<uint32_t>& cliquesFirst, T_HV<uint32_t>& communities, T_HV<uint32_t>& communitiesFirst){
		return 1;
	}

	bool algorithm_clique(comevo::Source &source, comevo::Source &target, uint32_t minimumClique){

		//if (!generate_clique())return 0;

		//if (!generate_communities())return 0;

		return 1;
	}
}