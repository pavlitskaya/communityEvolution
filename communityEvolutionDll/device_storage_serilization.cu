#include "stdafx.h"
#include "include/device_storage_serilization.h"
#include "include/host_storage_serilization.h"
#include "include/general_pair_structs.h"
#include "include/display_elements.h"

using namespace std;

static uint32_t allocationCount = 0;

bool serialize(T_DV<pair_t>& d_pair, string type, uint32_t offset, uint32_t allocate, uint32_t id){
	pair_t* h_pair = (pair_t*)malloc(sizeof(pair_t)*allocate);
	thrust::copy(d_pair.begin() + offset, d_pair.begin() + offset + allocate, h_pair);
	comevo::Serilization::store(h_pair, allocate, type, id);
	free(h_pair);
	return 1;
}

bool from_device_store(T_DV<uint32_t>& d_val, std::string type, uint32_t offset, uint32_t allocate, uint32_t id){
	T_HV<uint32_t> h_val(d_val.begin() + offset, d_val.begin() + offset + allocate);
	//vector<uint32_t> val(h_val.begin(), h_val.end());
	if (!comevo::Serilization::store(h_val, type, id)) return 0;
	return 1;
}

bool to_device_load(T_DV<uint32_t>& d_val, std::string type, uint32_t id, bool clean){
	T_HV<uint32_t> h_val(0);
	if (!comevo::Serilization::load(h_val, type, id, clean))return 0;
	d_val.assign(h_val.begin(), h_val.end());
	return 1;
}

bool from_device_store(T_DV<pair_t>& d_vec, std::string type, uint32_t offset, uint32_t allocate, uint32_t id){
	T_HV<uint32_t> h_vecFirst(
		T_MTI(d_vec.begin() + offset, first_element()), 
		T_MTI(d_vec.begin() + offset + allocate, first_element()));
	T_HV<uint32_t> h_vecSecond(
		T_MTI(d_vec.begin() + offset, second_element()), 
		T_MTI(d_vec.begin() + offset + allocate, second_element()));
	/*vector<uint32_t> vecFirst(h_vecFirst.begin(), h_vecFirst.end());
	vector<uint32_t> vecSecond(h_vecSecond.begin(), h_vecSecond.end());
	
	if (!comevo::Serilization::store(vecFirst, type + "f", id))return 0;
	if (!comevo::Serilization::store(vecSecond, type + "s", id))return 0;*/
	if (!comevo::Serilization::store(h_vecFirst, type + "f", id))return 0;
	if (!comevo::Serilization::store(h_vecSecond, type + "s", id))return 0;
	return 1;
}

bool to_device_load(T_DV<pair_t>& d_vec, std::string type, uint32_t id, bool clean){
	T_HV<uint32_t> h_vecFirst(0);
	T_HV<uint32_t> h_vecSecond(0);
	if (!comevo::Serilization::load(h_vecFirst, type + "f", id, clean))return 0;
	if (!comevo::Serilization::load(h_vecSecond, type + "s", id, clean))return 0;
	if (h_vecFirst.size() != h_vecSecond.size()){
		cout << "allocation issue count: " << ++allocationCount << endl;
		h_vecFirst.resize(min(h_vecFirst.size(), h_vecSecond.size()));
		h_vecSecond.resize(min(h_vecFirst.size(), h_vecSecond.size()));
	}
	
	d_vec.assign(
		T_MTI(T_MZIMT(h_vecFirst.begin(), h_vecSecond.begin()), pair_create()),
		T_MTI(T_MZIMT(h_vecFirst.end(), h_vecSecond.end()), pair_create()));
	return 1;
}

namespace comevohost{

	bool from_host_store(T_HV<uint32_t>& d_val, std::string type, uint32_t offset, uint32_t allocate, uint32_t id){
		vector<uint32_t> val(d_val.size());
		thrust::copy(d_val.begin() + offset, d_val.begin() + offset + allocate, val.begin());
		if (!comevo::Serilization::store(val, type, id)) return 0;
		return 1;
	}

	bool to_host_load(T_HV<uint32_t>& d_val, std::string type, uint32_t id, bool clean){
		vector<uint32_t> h_val(0);
		if (!comevo::Serilization::load(h_val, type, id, clean))return 0;
		d_val.assign(h_val.begin(), h_val.end());
		return 1;
	}

	bool from_host_store(T_HV<pair_t>& d_vec, std::string type, uint32_t offset, uint32_t allocate, uint32_t id){
		vector<uint32_t> vecFirst(d_vec.size());
		vector<uint32_t> vecSecond(d_vec.size());
		thrust::copy(T_MTI(d_vec.begin() + offset, first_element()), T_MTI(d_vec.begin() + offset + allocate, first_element()), vecFirst.begin());
		thrust::copy(T_MTI(d_vec.begin() + offset, second_element()), T_MTI(d_vec.begin() + offset + allocate, second_element()), vecSecond.begin());
		if (!comevo::Serilization::store(vecFirst, type + "f", id))return 0;
		if (!comevo::Serilization::store(vecSecond, type + "s", id))return 0;
		return 1;
	}

	bool to_host_load(T_HV<pair_t>& d_vec, std::string type, uint32_t id, bool clean){
		vector<uint32_t> vecFirst(0);
		vector<uint32_t> vecSecond(0);
		if (!comevo::Serilization::load(vecFirst, type + "f", id, clean))return 0;
		if (!comevo::Serilization::load(vecSecond, type + "s", id, clean))return 0;
		d_vec.assign(
			T_MTI(T_MZIMT(vecFirst.begin(), vecSecond.begin()), pair_create()),
			T_MTI(T_MZIMT(vecFirst.end(), vecSecond.end()), pair_create()));
		return 1;
	}

}