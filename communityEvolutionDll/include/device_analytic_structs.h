#pragma once

#include "general_search.h"

struct countCommonNeighbours{
	pair_t* pairs, *mirror_pairs, *target_mirror;
	uint32_t mirror_pairs_size, n;
	uint32_t *nodes, *firsts, *target_firsts, *target_degree;

	__host__ __device__
		countCommonNeighbours(pair_t* pairs, pair_t* mirror_pairs, uint32_t* nodes, uint32_t n, uint32_t* firsts, uint32_t mirror_pairs_size, pair_t* target_mirror, uint32_t* target_firsts, uint32_t* target_degree) :
		pairs(pairs), mirror_pairs(mirror_pairs), nodes(nodes), n(n), firsts(firsts), mirror_pairs_size(mirror_pairs_size), target_mirror(target_mirror), target_firsts(target_firsts), target_degree(target_degree) {}

	__host__ __device__
		void operator()(uint32_t i)
	{
		pair_t p = pairs[i];
		bool found = 0;
		uint32_t n_first = g_binary_search(nodes, nodes + n, p.first, found);
		uint32_t n_second = g_binary_search(nodes, nodes + n, p.second, found);
		uint32_t n_first_it = firsts[n_first];
		uint32_t n_second_it = firsts[n_second];
		uint32_t n_first_l = firsts[n_first + 1];
		uint32_t n_second_l = firsts[n_second +1];
		//printf("pair: %lu:%lu,\n first: %lu p: %lu:%lu, \nsecond: %lu p: %lu:%lu \n %lu %lu\n", p.first, p.second, n_first_it, mirror_pairs[n_first_it].first, mirror_pairs[n_first_it].second, n_second_it, mirror_pairs[n_second_it].first, mirror_pairs[n_second_it].second, n_first_l, n_second_l);

		// find common neighbour
		while (n_first_it < n_first_l && n_second_it < n_second_l){
			if (mirror_pairs[n_first_it].second == mirror_pairs[n_second_it].second){
				// found a common element.
				if (mirror_pairs[n_first_it].second != p.first && mirror_pairs[n_first_it].second != p.second){
					++target_degree[i];
				}
				++n_first_it;
				++n_second_it;
			}
			else if (mirror_pairs[n_first_it].second < mirror_pairs[n_second_it].second)
				++n_first_it;
			else
				++n_second_it;
		}
		if (target_degree[i] == 1)target_degree[i] = 0;

	}
};

struct setCommonNeighbours{
	pair_t* pairs, *mirror_pairs, *target_mirror;
	uint32_t mirror_pairs_size, n;
	uint32_t *nodes, *firsts, *target_firsts, *target_degree;

	__host__ __device__
		setCommonNeighbours(pair_t* pairs, pair_t* mirror_pairs, uint32_t* nodes, uint32_t n, uint32_t* firsts, uint32_t mirror_pairs_size, pair_t* target_mirror, uint32_t* target_firsts, uint32_t* target_degree) :
		pairs(pairs), mirror_pairs(mirror_pairs), nodes(nodes), n(n), firsts(firsts), mirror_pairs_size(mirror_pairs_size), target_mirror(target_mirror), target_firsts(target_firsts), target_degree(target_degree) {}

	__host__ __device__
		void operator()(uint32_t i)
	{
		pair_t p = pairs[i];
		uint32_t offset = target_firsts[i];
		bool found = 0;
		uint32_t n_first = g_binary_search(nodes, nodes + n, p.first, found);
		uint32_t n_second = g_binary_search(nodes, nodes + n, p.second, found);
		uint32_t n_first_it = firsts[n_first];
		uint32_t n_second_it = firsts[n_second];
		uint32_t n_first_l = firsts[n_first + 1];
		uint32_t n_second_l = firsts[n_second + 1];

		// find common neighbour
		if (target_degree[i] > 0){
			while (n_first_it < n_first_l && n_second_it < n_second_l){

				if (mirror_pairs[n_first_it].second == mirror_pairs[n_second_it].second){
					// found a common element.
					if (mirror_pairs[n_first_it].second != p.first && mirror_pairs[n_first_it].second != p.second){
						target_mirror[offset] = pair_t(i, mirror_pairs[n_first_it].second);
						++offset;
					}
					++n_first_it;
					++n_second_it;
				}
				else if (mirror_pairs[n_first_it].second < mirror_pairs[n_second_it].second)
					++n_first_it;
				else
					++n_second_it;
			}
		}

	}
};
