#include "stdafx.h"
#include "include/general_pair.h"

using namespace std;

void pair_order(pair_t& x){
	if (x.first > x.second)swap(x.first, x.second);
}