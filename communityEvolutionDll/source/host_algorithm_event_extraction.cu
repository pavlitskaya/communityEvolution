#include "../stdafx.h"
#include "../include/host_algorithm_event_extraction.h"
#include "../include/host_convert.h"
#include "../include/general_arithmetic_structs.h"
#include "../include/general_comparsion_structs.h"
#include "../include/general_pair_structs.h"
#include "../include/general_structs.h"

using namespace std;

namespace comevohost{
#define _OR 1
#define _AND 2

	void displayTripleVector(T_HV<tuple_triple>& vec, char* name, bool split){
		std::cout << name << ": " << endl;
		for (T_HV<tuple_triple>::iterator it = vec.begin(); it != vec.end(); ++it){
			tuple_triple trip = *it;
			if (split)
				cout << thrust::get<0>(trip) << " uint32_to " << thrust::get<1>(trip) << " + " << thrust::get<2>(trip) << " # ";
			else
				cout << thrust::get<0>(trip) << " + " << thrust::get<1>(trip) << " uint32_to " << thrust::get<2>(trip) << " # ";
		}
		std::cout << "\n";
		std::cout << "\n";
	}

	void displayPairVector(T_HV<pair_ti>& vec, char* name, char* str){
		std::cout << name << ": " << endl;
		for (T_HV<pair_ti>::iterator it = vec.begin(); it != vec.end(); ++it){
			pair_ti p = *it;
			std::cout << p.first << " " << str << " " << p.second << " # ";
		}
		std::cout << "\n";
		std::cout << "\n";
	}

	template <typename T>
	struct linear_index_to_row_index : public thrust::unary_function < T, T >
	{
		T C; // number of columns

		__host__ __device__
			linear_index_to_row_index(T C) : C(C) {}

		__host__ __device__
			T operator()(T i)
		{
			return i / C;
		}
	};
	struct _sum_row_b
	{
		bool* source;
		uint32_t n_cols, n_rows;
		uint32_t* target;

		__host__ __device__
			_sum_row_b(bool* source, uint32_t n_cols, uint32_t* target, uint32_t n_rows) :
			source(source), n_cols(n_cols), target(target), n_rows(n_rows) {}

		__host__ __device__
			void operator()(uint32_t i)
		{
			// mapped
			uint32_t x = (uint32_t)(i / n_rows);
			if (source[i] == 1)
				++target[x];
			//atomicAdd(target + x, 1);
		}
	};

	struct h_mergesplit{
		uint32_t *_or_ii_sum, *_anh_ij_sum, *_or_iij_sum, *_j_sum;
		float* _i_f_sum;
		float kappa;
		tuple_triple* target;
		uint32_t i_cols, j_cols;
		bool split;
		__host__ __device__
			h_mergesplit(uint32_t i_cols, uint32_t j_cols, float kappa, tuple_triple* target,
			uint32_t *_or_ii_sum, uint32_t *_anh_ij_sum, uint32_t *_or_iij_sum, float *_i_f_sum, uint32_t *_j_sum, bool split) :
			i_cols(i_cols), j_cols(j_cols), kappa(kappa), target(target),
			_or_ii_sum(_or_ii_sum), _anh_ij_sum(_anh_ij_sum), _or_iij_sum(_or_iij_sum), _i_f_sum(_i_f_sum), _j_sum(_j_sum), split(split) {}

		__host__ __device__
			void operator()(uint32_t i1_ind){
			// pouint32_t it:
			uint32_t tgt = i1_ind*i_cols;
			uint32_t tgt_last = i_cols*i_cols;
			uint32_t m = i_cols;
			uint32_t c2_m = j_cols;
			for (int i2_ind = i1_ind + 1; i2_ind < i_cols; ++i2_ind){
				for (int j = 0; j < j_cols; ++j){
					uint32_t tmp_ii = uint32_t((0.5*m*(m - 1) - 0.5*(m - i1_ind)*(m - i1_ind - 1) + (i2_ind - 1) - i1_ind));
					uint32_t tmp_ij = i1_ind*c2_m + j;
					uint32_t tmp_i2j = i2_ind*c2_m + j;
					if (_or_iij_sum[tmp_ii*c2_m + j] >= kappa * max((uint32_t)_or_ii_sum[tmp_ii], (uint32_t)_j_sum[j])){
						if (_anh_ij_sum[tmp_ij] >= _i_f_sum[i1_ind]){
							if (_anh_ij_sum[tmp_i2j] >= _i_f_sum[i2_ind]){
								while (thrust::get<0>(target[tgt]) >= 0 && tgt < tgt_last){
									++tgt;
								}
								if (tgt < tgt_last){
									if (split)
										target[tgt] = tuple_triple(j, (int)i1_ind, i2_ind);
									else
										target[tgt] = tuple_triple((int)i1_ind, i2_ind, j);
								}
							}
						}
					}
				}
			}
		}
	};

	struct h_continue{
		bool* _or_ij, *_anh_ij;
		uint32_t j_cols, n;
		pair_ti* target;
		__host__ __device__
			h_continue(uint32_t n, uint32_t j_cols, bool* _anh_ij, bool* _or_ij, pair_ti* target) : n(n), _or_ij(_or_ij), _anh_ij(_anh_ij), j_cols(j_cols), target(target) {}

		__host__ __device__
			void operator()(uint32_t i_ind){
			// pouint32_t it:
			uint32_t tgt = i_ind*j_cols;
			bool add;
			for (uint32_t j = 0; j < j_cols; ++j){
				add = true;
				for (uint32_t v = 0; v < n; ++v){
					if (_or_ij[(i_ind*j_cols + j)*n + v] != _anh_ij[(i_ind*j_cols + j)*n + v]){
						add = false;
					}
				}
				if (add){
					while (target[tgt].first >= 0){
						++tgt;
					}
					target[tgt] = pair_ti(i_ind, j);
				}
			}
		}
	};

	struct h_join{
		pair_ti * target;
		float* _i_f_sum;
		uint32_t* _anh_ij_sum;
		bool *h_preMatrix, *h_curMatrix;
		uint32_t nRelevant, i_cols, j_cols;
		__host__ __device__
			h_join(uint32_t nRelevant, uint32_t i_cols, uint32_t j_cols, uint32_t* _anh_ij_sum, bool* h_preMatrix, bool* h_curMatrix, float* _i_f_sum, pair_ti* target) :
			nRelevant(nRelevant), i_cols(i_cols), j_cols(j_cols), _anh_ij_sum(_anh_ij_sum), h_preMatrix(h_preMatrix), h_curMatrix(h_curMatrix), _i_f_sum(_i_f_sum), target(target) {}

		__host__ __device__
			void operator()(uint32_t j){
			uint32_t tgt = j;
			for (uint32_t v = 0; v < nRelevant; ++v){
				if (h_curMatrix[j*nRelevant + v] == 1){
					for (uint32_t i = 0; i < i_cols; ++i){
						if (_anh_ij_sum[i*j_cols + j] > _i_f_sum[i]){
							if (h_preMatrix[i*nRelevant + v] == 0){
								while (target[tgt].first >= 0){
									++tgt;
								}
								target[tgt] = (pair_ti(v, j));
							}
						}
					}
				}
			}
		}
	};

	struct h_leve{
		pair_ti * target;
		float* _i_f_sum;
		uint32_t* _anh_ij_sum;
		bool *h_preMatrix, *h_curMatrix;
		uint32_t nRelevant, i_cols, j_cols;
		__host__ __device__
			h_leve(uint32_t nRelevant, uint32_t i_cols, uint32_t j_cols, uint32_t* _anh_ij_sum, bool* h_preMatrix, bool* h_curMatrix, float* _i_f_sum, pair_ti* target) :
			nRelevant(nRelevant), i_cols(i_cols), j_cols(j_cols), _anh_ij_sum(_anh_ij_sum), h_preMatrix(h_preMatrix), h_curMatrix(h_curMatrix), _i_f_sum(_i_f_sum), target(target) {}

		__host__ __device__
			void operator()(uint32_t i){
			uint32_t tgt = i;
			for (uint32_t v = 0; v < nRelevant; ++v){
				if (h_preMatrix[i*nRelevant + v] == 1){
					for (uint32_t j = 0; j < j_cols; ++j){
						if (_anh_ij_sum[i*j_cols + j] > _i_f_sum[i]){
							if (h_curMatrix[j*nRelevant + v] == 0){
								while (target[tgt].first >= 0){
									++tgt;
								}
								target[tgt] = (pair_ti(v, i));
							}
						}
					}
				}
			}
		}
	};

	struct h_dissolve{
		uint32_t* source;
		bool* target;
		uint32_t s1_size, s2_size;
		__host__ __device__
			h_dissolve(uint32_t s1_size, uint32_t s2_size, uint32_t* source, bool* target) : source(source), s1_size(s1_size), target(target), s2_size(s2_size) {}

		__host__ __device__
			void operator()(uint32_t s1_ind){
			// pouint32_t it:

			target[s1_ind] = 0;
		}
	};

	struct h_transpose{
		bool* source, *target;
		uint32_t row_size, col_size;
		__host__ __device__
			h_transpose(uint32_t row_size, uint32_t col_size, bool* source, bool* target) : source(source), row_size(row_size), target(target), col_size(col_size) {}

		__host__ __device__
			void operator()(uint32_t val){
			// y, x
			pair_t res = pair_t((uint32_t)val / row_size, val % row_size);

			// y*m + x
			*(target + res.second*col_size + res.first) = *(source + val);
		}
	};


	T_HV<uint32_t> sum_row(T_HV<uint32_t>& source, uint32_t m, uint32_t n){
		T_HV<uint32_t> result(m);
		T_HV<uint32_t> row_indices(m);

		thrust::reduce_by_key
			(thrust::make_transform_iterator(thrust::counting_iterator<uint32_t>(0), linear_index_to_row_index<uint32_t>(m)),
			thrust::make_transform_iterator(thrust::counting_iterator<uint32_t>(0), linear_index_to_row_index<uint32_t>(m)) + (n*m),
			source.begin(),
			row_indices.begin(),
			result.begin());
		return result;
	}

	bool transpose(uint32_t row_size, uint32_t col_size, vector<bool>& source, vector<bool>& target){
		bool source_val = source.front();
		bool target_val = target.front();
		thrust::for_each(thrust::host, T_MCI<uint32_t>(0), T_MCI<uint32_t>(0) + row_size * col_size, h_transpose(
			row_size, col_size, &source_val, &target_val));

		return 1;
	}

	struct set_diag_max : public thrust::unary_function < uint32_t, uint32_t >
	{
		uint32_t C;
		uint32_t val;

		__host__ __device__
			set_diag_max(uint32_t C, uint32_t val) : C(C), val(val) {}

		__host__ __device__
			uint32_t operator()(uint32_t x) const
		{
			//printf("C: %d, val: %d, ind: %d, res: %d", C, val, x, x % (C + 1));
			return (x % (C + 1) == 0) ? val : 0;
		}
	};

	bool transpose(uint32_t row_size, uint32_t col_size, T_HV<bool>& source, T_HV<bool>& target){
		thrust::for_each(thrust::host, T_MCI<uint32_t>(0), T_MCI<uint32_t>(0) + row_size * col_size, h_transpose(
			row_size, col_size, RAWD(source), RAWD(target)));

		return 1;
	}

	bool max_diagonal(T_HV<uint32_t>& source, uint32_t row_size){
		thrust::transform(T_MCI<uint32_t>(0), T_MCI<uint32_t>(row_size*row_size), source.begin(), set_diag_max(row_size, 1000));
		return 1;
	}

	bool sum_row(vector<bool>& source, uint32_t n, vector<uint32_t>& result){

		uint32_t m = source.size() / n;
		result.resize(m);
		vector<uint32_t> row_indices(m);
		try
		{
			thrust::reduce_by_key
				(thrust::make_transform_iterator(thrust::counting_iterator<uint32_t>(0), linear_index_to_row_index<uint32_t>(n)),
				thrust::make_transform_iterator(thrust::counting_iterator<uint32_t>(0), linear_index_to_row_index<uint32_t>(n)) + (n*m),
				source.begin(),
				row_indices.begin(),
				result.begin());
		}
		catch (thrust::system_error &e)
		{
			// output an error message and exit
			printf("parameters are: n=%d", n);
			std::cerr << "Error accessing vector element: " << e.what() << std::endl;
			system("pause");
			exit(-1);
		}
		return 1;
	}

	/*
	bool sum_row(T_HV<bool>& source, uint32_t n, T_HV<uint32_t>& result){
	uint32_t m = source.size() / n;
	result.resize(m);
	T_HV<uint32_t> row_indices(m);
	uint32_t n_done = 0, n_todo = 0, n_rest = 0, cur_start = 0, cur_end = 0;
	set_start_parameter(n_done, n_todo, n_rest, cur_start, cur_end, n, 1);
	while (n_todo != 0){
	try
	{
	thrust::reduce_by_key
	(thrust::make_transform_iterator(thrust::counting_iterator<uint32_t>(cur_start), linear_index_to_row_index<uint32_t>(cur_end)),
	thrust::make_transform_iterator(thrust::counting_iterator<uint32_t>(cur_start), linear_index_to_row_index<uint32_t>(cur_end)) + (n_todo*m),
	source.begin() + cur_start,
	row_indices.begin() + cur_start,
	result.begin() + cur_start);
	}
	catch (thrust::system_error &e)
	{
	// output an error message and exit
	printf("parameters are: n=%d \n", n);
	std::cerr << "Error accessing vector element: " << e.what() << std::endl;
	system("pause");
	exit(-1);
	}
	change_parameter(n_done, n_todo, n_rest, cur_start, cur_end, n, 1);
	}

	return 1;
	}
	*/

	bool sum_row(T_HV<bool>& source, uint32_t n, T_HV<uint32_t>& result){

		uint32_t m = source.size() / n;
		result.resize(m);
		T_HV<uint32_t> row_indices(m);

		thrust::for_each(thrust::host, T_MCI<uint32_t>(0), T_MCI<uint32_t>(m*n), _sum_row_b(
			RAWD(source), m, RAWD(result), n));

		return 1;
	}

	/*
	bool sum_row(thrust::host_vector<bool>& source, uint32_t n, thrust::host_vector<uint32_t>& result){

		uint32_t m = source.size() / n;
		result.resize(m);
		thrust::host_vector<uint32_t> row_indices(m);

		thrust::reduce_by_key
			(thrust::make_transform_iterator(thrust::counting_iterator<uint32_t>(0), linear_index_to_row_index<uint32_t>(n)),
			thrust::make_transform_iterator(thrust::counting_iterator<uint32_t>(0), linear_index_to_row_index<uint32_t>(n)) + (n*m),
			source.begin(),
			row_indices.begin(),
			result.begin());
		return 1;
	}
	*/

	struct h_ii {
		uint32_t n, m, s1_ind, op;
		bool *source, *target;

		__host__ __device__
			h_ii(uint32_t n, bool *source, uint32_t m, uint32_t s1_ind, bool *target, uint32_t op) : n(n), source(source), m(m), s1_ind(s1_ind), target(target), op(op) {}

		__host__ __device__
			void operator()(uint32_t s2_ind){

			bool* s1_ptr = source + s1_ind*n;
			bool* s2_ptr = source + s2_ind*n;
			uint32_t tmp = uint32_t((0.5*m*(m - 1) - 0.5*(m - s1_ind)*(m - s1_ind - 1) + (s2_ind - 1) - s1_ind));
			bool* t_ptr = target + tmp * n;

			for (uint32_t i = 0; i < n; ++i){
				if (op == 1)*t_ptr = *s1_ptr || *s2_ptr;
				if (op == 2)*t_ptr = *s1_ptr && *s2_ptr;
				++t_ptr;
				++s1_ptr;
				++s2_ptr;
			}
		}
	};

	struct h_ij {
		uint32_t n, s1_m, s2_m, s1_ind, op;
		bool *s1_source, *s2_source, *target;

		__host__ __device__
			h_ij(uint32_t n, bool *s1_source, uint32_t s1_m, uint32_t s1_ind, bool *s2_source, uint32_t s2_m, bool *target, uint32_t op) :
			n(n), s1_source(s1_source), s1_m(s1_m), s1_ind(s1_ind), s2_source(s2_source), s2_m(s2_m), target(target), op(op) {}

		__host__ __device__
			void operator()(uint32_t s2_ind){

			bool* s1_ptr = s1_source + s1_ind*n;
			bool* s2_ptr = s2_source + s2_ind*n;
			uint32_t tmp = s1_ind*s2_m + s2_ind;
			bool* t_ptr = target + tmp * n;

			for (uint32_t i = 0; i < n; ++i){
				if (op == 1)*t_ptr = *s1_ptr || *s2_ptr;
				if (op == 2)*t_ptr = *s1_ptr && *s2_ptr;
				++t_ptr;
				++s1_ptr;
				++s2_ptr;
			}

		}
	};

	bool ii(uint32_t n, T_HV<bool>& h_preMatrix, uint32_t k_preCom, T_HV<bool>& _ii, uint32_t op){
		uint32_t _ii_size = 0.5*(k_preCom - 1)*k_preCom * n;
		_ii.resize(_ii_size, 0);

		// for each row
		for (uint32_t ind = 0; ind < k_preCom - 1; ++ind){

			thrust::for_each(thrust::host, T_MCI<uint32_t>(0) + ind + 1, T_MCI<uint32_t>(0) + k_preCom,
				h_ii(n, RAWD(h_preMatrix), k_preCom, ind, RAWD(_ii), op));
		}

		return 1;
	}

	bool ij(uint32_t n, T_HV<bool>& h_preMatrix, uint32_t k_preCom, T_HV<bool>& h_curMatrix, uint32_t k_curCom, T_HV<bool>& _ij, uint32_t op){
		uint32_t _ij_size = k_preCom*k_curCom * n;
		_ij.resize(_ij_size, 0);

		// for each row
		for (uint32_t ind = 0; ind < k_preCom; ++ind){

			thrust::for_each(thrust::host, T_MCI<uint32_t>(0), T_MCI<uint32_t>(0) + k_curCom,
				h_ij(n, RAWD(h_preMatrix), k_preCom, ind,
				RAWD(h_curMatrix), k_curCom,
				RAWD(_ij), op));
		}

		return 1;
	}
	/*
	*/

	/* Asurs Event Extraction
	*/
	bool algorithm_event_extraction(comevo::Source &source, float k, bool display, bool create_file){
		// number of snaps and communities
		vector<community_t> communitySizes = source.get_scom();
		display_snapshots(source.get_snaps(), "snaps");

		snapshot_t preSnap;
		snapshot_t curSnap;
		uint32_t preId = 0, curId, nRelevant;
		T_HV<uint32_t> preSizes, curSizes;
		T_HV<uint32_t> h_preSizes, h_curSizes;
		T_HV<uint32_t> h_preSnapVec, h_curSnapVec;
		T_HV<uint32_t> h_preSnapVecSort, h_curSnapVecSort;
		T_HV<uint32_t> h_preSnapVecUnique, h_curSnapVecUnique;
		T_HV<bool> h_preMatrix, h_curMatrix;
		uint32_t k_preCom, k_curCom;
		if (communitySizes.size() < 2)
			return 1;

		preSnap = source.get_snap(preId);
		preSizes = communitySizes[preId];
		h_preSizes.assign(preSizes.begin(), preSizes.end());
		comevohost::translate_snapshot_to_vector(preSnap, h_preSnapVec);
		h_preSnapVecUnique.assign(h_curSnapVec.begin(), h_curSnapVec.end());
		thrust::sort(h_preSnapVecUnique.begin(), h_preSnapVecUnique.end());
		h_preSnapVecUnique.erase(thrust::unique(h_preSnapVecUnique.begin(), h_preSnapVecUnique.end()), h_preSnapVecUnique.end());
		k_preCom = h_preSizes.size();

		// for each two Snapshots
		for (uint32_t snapId = 1; snapId < communitySizes.size(); ++snapId){
			cout << "current snaps: " << preId << " and " << snapId << endl;

			// extract snaps, prepare values
			preId = snapId - 1;
			curId = snapId;
			curSnap = source.get_snap(curId);
			/*display_snapshot(preSnap, "ps");
			display_snapshot(curSnap, "cs");*/
			curSizes = communitySizes[curId];
			h_curSizes.assign(curSizes.begin(), curSizes.end());

			k_curCom = h_curSizes.size();
			// translate Snapshot into Vector
			comevohost::translate_snapshot_to_vector(curSnap, h_curSnapVec);
			h_curSnapVecUnique.assign(h_curSnapVec.begin(), h_curSnapVec.end());
			thrust::sort(h_curSnapVecUnique.begin(), h_curSnapVecUnique.end());
			h_curSnapVecUnique.erase(thrust::unique(h_curSnapVecUnique.begin(), h_curSnapVecUnique.end()), h_curSnapVecUnique.end());

			// get relevant nodes
			T_HV<uint32_t> h_relevant(h_preSnapVecUnique.size() + h_curSnapVecUnique.size());
			h_relevant.erase(thrust::set_union(h_preSnapVecUnique.begin(), h_preSnapVecUnique.end(), h_curSnapVecUnique.begin(), h_curSnapVecUnique.end(), h_relevant.begin()), h_relevant.end());
			nRelevant = h_relevant.size();

			if (nRelevant > 0 && h_preSnapVec.size() > 0 && h_curSnapVec.size() > 0
				&& preSnap.size() > 0 && curSnap.size() > 0){

				// create Matrices of two Snapshots
				comevohost::translate_snapshot_to_matrix(h_preSnapVec, h_preSizes, h_relevant, h_preMatrix);
				comevohost::translate_snapshot_to_matrix(h_curSnapVec, h_curSizes, h_relevant, h_curMatrix);
				/*display_vector(h_preMatrix, "hpreM");
				display_vector(h_curMatrix, "hcurM");*/
				//display_vector<bool>(h_preMatrix, 0, nRelevant, "h_preMatrix");
				//display_vector<bool>(h_curMatrix, 0, nRelevant, "h_curMatrix");

				T_HV<uint32_t> _i_occurences;
				T_HV<uint32_t> _j_occurences;
				/*
				T_HV<bool> h_preMatrix_t(h_preMatrix.size(), 0);
				transpose(nRelevant, k_preCom, h_preMatrix, h_preMatrix_t);
				sum_row(h_preMatrix_t, k_preCom, _i_occurences);

				T_HV<bool> h_curMatrix_t(h_curMatrix.size(), 0);
				transpose(nRelevant, k_curCom, h_curMatrix, h_curMatrix_t);
				sum_row(h_curMatrix_t, k_curCom, _j_occurences);
				*/
				// start calculation: 
				// create iterator
				// A, A*: or_ii
				uint32_t _or_ii_n = 0.5*(k_preCom - 1)*k_preCom;
				T_HV<bool> _or_ii(_or_ii_n * nRelevant);
				ii(nRelevant, h_preMatrix, k_preCom, _or_ii, _OR);
				T_HV<uint32_t> _or_ii_sum;
				sum_row(_or_ii, nRelevant, _or_ii_sum);



				// or_jj
				uint32_t _or_jj_n = 0.5*(k_curCom - 1)*k_curCom;
				T_HV<bool> _or_jj(_or_jj_n * nRelevant);
				ii(nRelevant, h_curMatrix, k_curCom, _or_jj, _OR);
				T_HV<uint32_t> _or_jj_sum;
				sum_row(_or_jj, nRelevant, _or_jj_sum);

				// E
				T_HV<uint32_t> _i_sum;
				sum_row(h_preMatrix, nRelevant, _i_sum);
				T_HV<float> _i_f_sum(_i_sum.size());
				thrust::transform(_i_sum.begin(), _i_sum.end(), _i_f_sum.begin(), set_multiply<float>(0.5));

				// F
				T_HV<uint32_t> _j_sum;
				sum_row(h_curMatrix, nRelevant, _j_sum);
				T_HV<float> _j_f_sum(_j_sum.size());
				thrust::transform(_j_sum.begin(), _j_sum.end(), _j_f_sum.begin(), set_multiply<float>(0.5));

				// AF
				T_HV<bool> _anh_iij;
				ij(nRelevant, _or_ii, _or_ii_n, h_curMatrix, k_curCom, _anh_iij, _AND);
				T_HV<uint32_t> _or_iij_sum;
				sum_row(_anh_iij, nRelevant, _or_iij_sum);

				T_HV<bool> _anh_jji;
				ij(nRelevant, _or_jj, _or_jj_n, h_preMatrix, k_preCom, _anh_jji, _AND);
				T_HV<uint32_t> _or_jji_sum;
				sum_row(_anh_jji, nRelevant, _or_jji_sum);

				// B: or_ij
				T_HV<bool> _or_ij;
				ij(nRelevant, h_preMatrix, k_preCom, h_curMatrix, k_curCom, _or_ij, _OR);

				T_HV<bool> _or_ji;
				ij(nRelevant, h_curMatrix, k_curCom, h_preMatrix, k_preCom, _or_ji, _OR);

				// D, D*: anh_ij
				T_HV<bool> _anh_ij;
				ij(nRelevant, h_preMatrix, k_preCom, h_curMatrix, k_curCom, _anh_ij, _AND);
				T_HV<uint32_t> _anh_ij_sum;
				sum_row(_anh_ij, nRelevant, _anh_ij_sum);

				T_HV<bool> _anh_ji;
				ij(nRelevant, h_curMatrix, k_curCom, h_preMatrix, k_preCom, _anh_ji, _AND);
				T_HV<uint32_t> _anh_ji_sum;
				sum_row(_anh_ji, nRelevant, _anh_ji_sum);

				// G
				if (k_preCom > 0){
					T_HV<bool> h_preMatrix_t(h_preMatrix.size(), 0);
					transpose(nRelevant, k_preCom, h_preMatrix, h_preMatrix_t);
					//T_HV<uint32_t> _i_occurences;
					sum_row(h_preMatrix_t, k_preCom, _i_occurences);
				}

				// H
				if (k_curCom > 0){
					T_HV<bool> h_curMatrix_t(h_curMatrix.size(), 0);
					transpose(nRelevant, k_curCom, h_curMatrix, h_curMatrix_t);
					//T_HV<uint32_t> _j_occurences;
					sum_row(h_curMatrix_t, k_curCom, _j_occurences);
				}
				//*/

				// do the real work
				//displayVector(h_preMatrix, "h_preMatrix", nRelevant);
				//displayVector(h_curMatrix, "h_curMatrix", nRelevant);
				T_HV<bool> _dissolve;
				T_HV<bool> _form;
				T_HV<tuple_triple> _merge;
				T_HV<tuple_triple> _split;
				T_HV<pair_ti> _continue;
				T_HV<bool> _appear;
				T_HV<bool> _disappear;
				T_HV<pair_ti> _join;
				T_HV<pair_ti> _leve;
				// dissolve
				if (k_preCom > 0 && k_curCom > 0){
					_dissolve.assign(k_preCom, 0);

					for (uint32_t i = 0; i < k_preCom; ++i){
						T_HV<uint32_t>::iterator it = thrust::max_element(_anh_ij_sum.begin() + i * k_curCom, _anh_ij_sum.begin() + i * k_curCom + k_curCom);
						if (*it < 1)
							_dissolve[i] = 1;
					}

					if (display)display_vector<bool>(_dissolve, "dissolve");
				}

				// form
				if (k_preCom > 0 && k_curCom > 0){
					_form.assign(k_curCom, 0);

					for (uint32_t i = 0; i < k_curCom; ++i){
						T_HV<uint32_t>::iterator it = thrust::max_element(_anh_ji_sum.begin() + i * k_preCom, _anh_ji_sum.begin() + i * k_preCom + k_preCom);
						if (*it < 1)
							_form[i] = 1;
					}

					if (display)display_vector<bool>(_form, "_form");
				}

				// merge
				if (k_preCom > 1 && k_curCom > 0){
					float kappa = 0.5;
					_merge.assign(k_preCom*k_preCom, -1);
					thrust::for_each(thrust::host, T_MCI<uint32_t>(0), T_MCI<uint32_t>(k_preCom - 1), h_mergesplit(
						k_preCom, k_curCom, kappa, RAWD(_merge), RAWD(_or_ii_sum), RAWD(_anh_ij_sum),
						RAWD(_or_iij_sum), RAWD(_i_f_sum), RAWD(_j_sum), false
						));

					T_HV<tuple_triple>::iterator tend = thrust::remove_if(_merge.begin(), _merge.end(), is_negative_triple());
					_merge.resize(tend - _merge.begin());
					//displayTripleVector(_merge, "_merge", false);
				}


				// split
				if (k_preCom > 0 && k_curCom > 1){
					float kappa = 0.5;
					_split.assign(k_curCom*k_curCom, -1);

					thrust::for_each(thrust::host, T_MCI<uint32_t>(0), T_MCI<uint32_t>(k_curCom - 1), h_mergesplit(
						k_curCom, k_preCom, kappa, RAWD(_split), RAWD(_or_jj_sum), RAWD(_anh_ji_sum),
						RAWD(_or_jji_sum), RAWD(_j_f_sum), RAWD(_i_sum), true
						));

					T_HV<tuple_triple>::iterator tend = thrust::remove_if(_split.begin(), _split.end(), is_negative_triple());
					_split.resize(tend - _split.begin());
					if (display)displayTripleVector(_split, "_split", true);
				}

				// continue
				if (k_preCom > 0 && k_curCom > 0){
					_continue.assign(k_preCom*k_curCom, pair_ti(-1, -1));

					thrust::for_each(thrust::host, T_MCI<uint32_t>(0), T_MCI<uint32_t>(k_preCom), h_continue(
						nRelevant, k_curCom, RAWD(_anh_ij), RAWD(_or_ij), RAWD(_continue)
						));

					T_HV<pair_ti>::iterator tend = thrust::remove_if(_continue.begin(), _continue.end(), is_negative_pair());
					_continue.resize(tend - _continue.begin());

					if (display)display_vector<int, int>(_continue, "_continue");
				}

				// appear
				if (k_preCom > 0){
					_appear.assign(nRelevant, 0);
					for (uint32_t i = 0; i < nRelevant; ++i){
						if (_i_occurences[i] == 0)
							if (_j_occurences[i] == 1)
								_appear[i] = 1;
					}
					if (display)display_vector<bool>(_appear, "_appear");
				}

				// disappear
				if (k_curCom > 0){
					_disappear.assign(nRelevant, 0);
					for (uint32_t i = 0; i < nRelevant; ++i){
						if (_i_occurences[i] == 1)
							if (_j_occurences[i] == 0)
								_disappear[i] = 1;
					}
					if (display)display_vector<bool>(_disappear, "_disappear");
				}

				display_single<uint32_t>(k_curCom, "k_curCom");
				display_single<uint32_t>(nRelevant, "nRelevant");
				display_single<uint32_t>(k_preCom, "k_preCom");
				cout << "_anh_ij_sum" << endl; 
				display_vector<uint32_t>(_anh_ij_sum);
				cout << "h_preMatrix" << endl;
				display_vector<bool>(h_preMatrix);
				cout << "h_curMatrix" << endl;
				display_vector<bool>(h_curMatrix);
				cout << "_i_f_sum" << endl;
				display_vector<float>(_i_f_sum);

				// join
				if (k_curCom > 0){
					_join.assign(k_curCom*nRelevant, pair_ti(-1, -1));

					thrust::for_each(thrust::host, T_MCI<uint32_t>(0), T_MCI<uint32_t>(k_curCom), h_join(
						nRelevant, k_preCom, k_curCom, RAWD(_anh_ij_sum), RAWD(h_preMatrix),
						RAWD(h_curMatrix), RAWD(_i_f_sum), RAWD(_join)
						));

					T_HV<pair_ti>::iterator tend = thrust::remove_if(_join.begin(), _join.end(), is_negative_pair());
					_join.resize(tend - _join.begin());

					if (display)displayPairVector(_join, "_join", "to");
				}
				displayPairVector(_join, "_join", "to");

				T_HV<bool> h_joinVector(nRelevant, 0);
				cout << "h_joinVector" << endl;
				display_vector<bool>(h_joinVector);
				thrust::transform(T_MPI(h_joinVector.begin(), T_MTI(_join.begin(), first_element())),
					T_MPI(h_joinVector.begin(), T_MTI(_join.end(), first_element())),
					T_MPI(h_joinVector.begin(), T_MTI(_join.begin(), first_element())),
					set_one<bool>());
				cout << "h_joinVector" << endl;
				display_vector<bool>(h_joinVector);

				// leave
				if (k_preCom > 0){
					_leve.assign(k_preCom*nRelevant, pair_ti(-1, -1));

					thrust::for_each(thrust::host, T_MCI<uint32_t>(0), T_MCI<uint32_t>(k_preCom), h_leve(
						nRelevant, k_preCom, k_curCom, RAWD(_anh_ij_sum), RAWD(h_preMatrix),
						RAWD(h_curMatrix), RAWD(_i_f_sum), RAWD(_leve)
						));

					T_HV<pair_ti>::iterator tend = thrust::remove_if(_leve.begin(), _leve.end(), is_negative_pair());
					_leve.resize(tend - _leve.begin());

					if (display)displayPairVector(_leve, "_leve", "from");
				}

				if (create_file){
					time_t t = time(0);
					stringstream ss;
					ss << "events_";
					ss << t;
					string filename = ss.str();
					comevo::save_to_file(filename,
						std::vector<bool>(_dissolve.begin(), _dissolve.end()),
						std::vector<bool>(_form.begin(), _form.end()),
						std::vector<tuple_triple>(_merge.begin(), _merge.end()),
						std::vector<tuple_triple>(_split.begin(), _split.end()),
						std::vector<pair_ti>(_continue.begin(), _continue.end()),
						thrust::count(_appear.begin(), _appear.end(), 1),
						thrust::count(_disappear.begin(), _disappear.end(), 1),
						std::vector<pair_ti>(_join.begin(), _join.end()),
						std::vector<pair_ti>(_leve.begin(), _leve.end()));
				}

				printf("sizes: \n dissolve: %lu, form: %lu, merge: %lu, split: %lu, continue: %lu \n appear: %lu, disappear: %lu, join: %lu, leave: %lu \n\n",
					thrust::count(_dissolve.begin(), _dissolve.end(), 1),
					thrust::count(_form.begin(), _form.end(), 1),
					_merge.size(),
					_split.size(),
					_continue.size(),
					thrust::count(_appear.begin(), _appear.end(), 1),
					thrust::count(_disappear.begin(), _disappear.end(), 1),
					_join.size(),
					_leve.size()
					);


			}

			preSnap = curSnap;
			preSizes = curSizes;
			h_preSizes = h_curSizes;
			h_preSnapVec = h_curSnapVec;
			h_preSnapVecSort = h_curSnapVecSort;
			h_preSnapVecUnique = h_curSnapVecUnique;
			h_preMatrix = h_curMatrix;
			k_preCom = k_curCom;
			preId = curId;

		}


		return 1;
	}
}
//*/