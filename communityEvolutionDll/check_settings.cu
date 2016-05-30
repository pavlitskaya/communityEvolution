#include "stdafx.h"
#include "include/check_settings.h"

using namespace std;

namespace SpaceAny{

	Any::Any(){
		this->n = 0;
		this->m = 0;
	}

	Any::~Any(){

	}

	bool Any::set_n(uint32_t n){
		vector<int> v;
		this->n = n;
		return 1;
	}

	bool Any::set_m(uint32_t m){
		this->m = m;
		return 1;
	}

	uint32_t Any::get_n(){
		return this->n;
	}

	uint32_t Any::get_m(){
		return this->m;
	}

	vector<uint32_t> Any::get_vec(){
		vector<uint32_t> vec;
		return vec;
	}

}