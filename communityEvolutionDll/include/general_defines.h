#pragma once

#define TESTING_MODE 0
#define MEASURE_TIME 1
#define DISPLAY_MEMORY 1

#define U32 uint32_t
typedef thrust::pair<uint32_t, uint32_t> pair_t;
typedef thrust::pair<int, int> pair_ti;
typedef std::vector<uint32_t> nodes_t;
typedef std::vector<pair_t> pairs_t;
typedef std::vector<uint32_t> community_t;
typedef std::vector<community_t> snapshot_t;
typedef std::vector<snapshot_t> snapshots_t;
typedef thrust::tuple<int, int, int> tuple_triple;
typedef thrust::tuple<pair_t*, uint32_t*, uint32_t> triple_p_u_s;

#define SPACE 1900000000
#define T_DEREFPTR(X, Y)	thrust::device_ptr<Y>(&*X)
#define T_DEREF(X, Y)	(thrust::device_ptr<Y>(&*X)).get()
#define RAW(X)	thrust::raw_pointer_cast(X)
#define RAWD(X)	thrust::raw_pointer_cast(X.data())
#define T_MZIMT(X, Y) thrust::make_zip_iterator(thrust::make_tuple(X,Y))
#define T_MPI(X, Y) thrust::make_permutation_iterator(X, Y)
#define T_MTI(X, Y) thrust::make_transform_iterator(X, Y)
#define T_HV thrust::host_vector
#define T_DV thrust::device_vector
#define T_MCI thrust::make_counting_iterator
#define T_MCONSI thrust::make_constant_iterator
#define TH_CLEAR(X, Y) X.clear(); thrust::host_vector<Y>().swap(X);
#define T_CLEAR(X, Y) X.clear(); thrust::device_vector<Y>().swap(X);
#define T_RETAG(X) thrust::retag<thrust::device_system_tag>(X);
#define T_TRYCATCH(X) try{X}catch (thrust::system_error &e){std::cerr << "Error accessing vector element: " << e.what() << std::endl;system("pause");exit(-1);}
#define ISOPEN(X, Y)		if(!(X.is_open())){ cerr << "problem opening file: '" << Y << "' " << endl; return 0; }

typedef thrust::device_vector<pair_t> VectorP;
typedef thrust::device_vector<uint32_t> VectorI;
typedef thrust::device_vector<bool> VectorB;
typedef VectorP::iterator VectorPIterator;
typedef VectorI::iterator VectorIIterator;
typedef VectorB::iterator VectorBIterator;
typedef thrust::permutation_iterator<VectorPIterator, VectorIIterator> PermutationIteratorPI;
typedef thrust::detail::normal_iterator<class thrust::device_ptr<unsigned int> > NormalIterator;

typedef thrust::pair<cudaEvent_t, cudaEvent_t> tuple_event;

enum FileType { ALLFILES, RAW, PAIRS, SNAPS, RESULTS, INFO, INTERN };
enum RawType { EDGES, CSV };

#define _min(a,b)            (((a) < (b)) ? (a) : (b))
#define _max(a,b)            (((a) > (b)) ? (a) : (b))

struct Source_Props{
	uint32_t nMax;
	std::vector<uint32_t> nSnap, mSnap;
	std::vector<std::vector<uint32_t> > scomSnap;
};