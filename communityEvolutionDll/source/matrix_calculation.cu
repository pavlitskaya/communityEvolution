#include "../stdafx.h"
#include "../include/matrix_calculation.h"
#include  "../include/device_analytic.h"

using namespace std;

bool matrices_create(uint32_t rowSize, uint32_t amount, uint32_t value, vector<T_HV<uint32_t> >& matrices){
	uint32_t matrixSize = rowSize*rowSize;
	for (uint32_t i = 0; i < amount; ++i){
		T_HV<uint32_t> matrix(matrixSize, value);
		matrices.push_back(matrix);
	}
	return 1;
}

bool create_adjacency(pairs_t pairs, T_DV<uint32_t>& d_matrix){
	T_DV<pair_t> d_pairs(pairs.begin(), pairs.end());
	//pairs_to
	//max node
	//to relevant nodes
	//for each pair 


	return 1;
}