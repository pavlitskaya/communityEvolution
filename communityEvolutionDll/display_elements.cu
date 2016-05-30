#include "stdafx.h"
#include "include/display_elements.h"

using namespace std;

/*template <typename T> void display_direct(T* first, T* last, char* name){
	std::cout << name << ": " << endl;
	for (T* it = first; it != last; ++it){
		cout << *it << " ";
	}
	std::cout << "\n";
	std::cout << "\n";
}*/

template <typename T1, typename T2> void display_direct(pair_t* first, pair_t* last, char* name){
	std::cout << name << ": " << endl;
	for (pair_t* it = first; it != last; ++it){
		cout << (*it).first << ":" << (*it).second << " # ";
	}
	std::cout << "\n";
	std::cout << "\n";
}

template <typename T> void display_single(T const &single){ display_single<T>(single, ""); }
template <typename T> void display_single(T const &single, char* name){
	std::cout << name << ": " << endl;
	cout << single << endl;
	cout << "\n";
}

template <typename T> void display_vector(vector<T> const &vec){ display_vector<T>(vec, ""); }
template <typename T> void display_vector(vector<T> const &vec, char* name){ display_vector<T>(vec, vec.size(), name); }
template <typename T> void display_vector(vector<T> const &vec, uint32_t limit, char* name){ display_vector<T>(vec, limit, 0, name); }
template <typename T> void display_vector(vector<T> const &vec, uint32_t limit, uint16_t entriesBeforeLineBreak, char* name){
	std::cout << name << ": " << endl;
	if (!vec.empty()){
		uint32_t count = 0;
		for (typename vector<T>::const_iterator it = vec.begin(); it != vec.end(); ++it){
			std::cout << *it << " ";
			++count;
			if (limit > 0 && count == limit) break;
			if (entriesBeforeLineBreak > 0 && count % entriesBeforeLineBreak == 0) std::cout << "\n";
		}
	}
	std::cout << "\n\n";
}

template <typename T> void display_vector(T_DV<T> const &vec){ display_vector<T>(vec, ""); }
template <typename T> void display_vector(T_DV<T> const &vec, char* name){ display_vector<T>(vec, vec.size(), name); }
template <typename T> void display_vector(T_DV<T> const &vec, uint32_t limit, char* name){ display_vector<T>(vec, limit, 0, name); }
template <typename T> void display_vector(T_DV<T> const &vec, uint32_t limit, uint16_t entriesBeforeLineBreak, char* name){
	T_HV<T> h_vec(vec.begin(), vec.end());
	display_vector<T>(h_vec, limit, entriesBeforeLineBreak, name);
}

template <typename T> void display_vector(T_HV<T> const &vec){ display_vector<T>(vec, ""); }
template <typename T> void display_vector(T_HV<T> const &vec, char* name){ display_vector<T>(vec, vec.size(), name); }
template <typename T> void display_vector(T_HV<T> const &vec, uint32_t limit, char* name){ display_vector<T>(vec, limit, 0, name); }
template <typename T> void display_vector(T_HV<T> const &vec, uint32_t limit, uint16_t entriesBeforeLineBreak, char* name){
	std::cout << name << ": " << endl;
	if (!vec.empty()){
		uint32_t count = 0;
		for (typename T_HV<T>::const_iterator it = vec.begin(); it != vec.end(); ++it){
			std::cout << *it << " ";
			++count;
			if (limit > 0 && count == limit) break;
			if (entriesBeforeLineBreak > 0 && count % entriesBeforeLineBreak == 0) std::cout << "\n";
		}
	}
	std::cout << "\n\n";
}

// thrust::pairs
template <typename T1, typename T2> void display_vector(vector<thrust::pair<T1, T2> > const &vec){ display_vector<T1,T2>(vec, ""); }
template <typename T1, typename T2> void display_vector(vector<thrust::pair<T1, T2> > const &vec, char* name){ display_vector<T1, T2>(vec, vec.size(), name); }
template <typename T1, typename T2> void display_vector(vector<thrust::pair<T1, T2> > const &vec, uint32_t limit, char* name){ display_vector<T1, T2>(vec, limit, 0, name); }
template <typename T1, typename T2> void display_vector(vector<thrust::pair<T1,T2> > const &vec, uint32_t limit, uint16_t entriesBeforeLineBreak, char* name){
	std::cout << name << ": " << endl;
	if (!vec.empty()){
		uint32_t count = 0;
		for (typename vector<thrust::pair<T1, T2> >::const_iterator it = vec.begin(); it != vec.end(); ++it){
			thrust::pair<T1, T2> p = *it;
			cout << p.first << ":" << p.second << " # ";
			++count;
			if (limit > 0 && count == limit) break;
			if (entriesBeforeLineBreak > 0 && count % entriesBeforeLineBreak == 0) std::cout << "\n";
		}
	}
	std::cout << "\n\n";
}

template <typename T1, typename T2> void display_vector(T_DV<thrust::pair<T1, T2> > const &vec){ display_vector<T1, T2>(vec, ""); }
template <typename T1, typename T2> void display_vector(T_DV<thrust::pair<T1, T2> > const &vec, char* name){ display_vector<T1, T2>(vec, vec.size(), name); }
template <typename T1, typename T2> void display_vector(T_DV<thrust::pair<T1, T2> > const &vec, uint32_t limit, char* name){ display_vector<T1, T2>(vec, limit, 0, name); }
template <typename T1, typename T2> void display_vector(T_DV<thrust::pair<T1, T2> > const &vec, uint32_t limit, uint16_t entriesBeforeLineBreak, char* name){
	T_HV<thrust::pair<T1, T2 > > h_vec(vec.begin(), vec.end());
	display_vector<T1, T2>(h_vec, limit, entriesBeforeLineBreak, name);
}

template <typename T1, typename T2> void display_vector(T_HV<thrust::pair<T1, T2> > const &vec){ display_vector<T1, T2>(vec, ""); }
template <typename T1, typename T2> void display_vector(T_HV<thrust::pair<T1, T2> > const &vec, char* name){ display_vector<T1, T2>(vec, vec.size(), name); }
template <typename T1, typename T2> void display_vector(T_HV<thrust::pair<T1, T2> > const &vec, uint32_t limit, char* name){ display_vector<T1, T2>(vec, limit, 0, name); }

template <typename T1, typename T2> void display_vector(T_HV<thrust::pair<T1, T2> > const &vec, uint32_t limit, uint16_t entriesBeforeLineBreak, char* name){
	std::cout << name << ": " << endl;
	if (!vec.empty()){
		uint32_t count = 0;
		for (typename T_HV<thrust::pair<T1, T2> >::const_iterator it = vec.begin(); it != vec.end(); ++it){
			thrust::pair<T1, T2> p = *it;
			cout << p.first << ":" << p.second << " # ";
			++count;
			if (limit > 0 && count == limit) break;
			if (entriesBeforeLineBreak > 0 && count % entriesBeforeLineBreak == 0) std::cout << "\n";
		}
	}
	std::cout << "\n\n";
}
