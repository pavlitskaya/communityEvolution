#include "display_elements.cu"

template void display_direct<uint32_t>(uint32_t*, uint32_t*, char*);
template void display_direct<uint32_t, uint32_t>(pair_t*, pair_t*, char*);

template void display_single<bool>(bool const &);
template void display_single<uint32_t>(uint32_t const &);
template void display_single<uint16_t>(uint16_t const &);

template void display_vector<uint32_t, uint32_t>(vector<thrust::pair<uint32_t, uint32_t> > const &);
template void display_vector<uint16_t, uint16_t>(vector<thrust::pair<uint16_t, uint16_t> > const &);
template void display_vector<time_t>(vector<time_t> const &vec);
template void display_vector<uint32_t>(vector<uint32_t> const &vec);
template void display_vector<uint16_t>(vector<uint16_t> const &vec);
template void display_vector<int>(vector<int> const &vec);
template void display_vector<uint32_t, uint32_t>(T_DV<thrust::pair<uint32_t, uint32_t> > const &);
template void display_vector<uint16_t, uint16_t>(T_DV<thrust::pair<uint16_t, uint16_t> > const &);
template void display_vector<int, int>(T_DV<thrust::pair<int, int> > const &);
template void display_vector<uint32_t>(T_DV<uint32_t> const &vec);
template void display_vector<uint16_t>(T_DV<uint16_t> const &vec);
template void display_vector<int>(T_DV<int> const &vec);
template void display_vector<bool, bool>(vector<thrust::pair<bool, bool> > const &);
template void display_vector<bool>(vector<bool> const &vec);
template void display_vector<bool, bool>(T_DV<thrust::pair<bool, bool> > const &);
template void display_vector<bool>(T_DV<bool> const &vec);
template void display_vector<uint32_t, uint32_t>(T_HV<thrust::pair<uint32_t, uint32_t> > const &);
template void display_vector<uint16_t, uint16_t>(T_HV<thrust::pair<uint16_t, uint16_t> > const &);
template void display_vector<int, int>(T_HV<thrust::pair<int, int> > const &);
template void display_vector<uint32_t>(T_HV<uint32_t> const &vec);
template void display_vector<uint16_t>(T_HV<uint16_t> const &vec);
template void display_vector<int>(T_HV<int> const &vec);
template void display_vector<float>(T_HV<float> const &vec);
template void display_vector<bool, bool>(T_HV<thrust::pair<bool, bool> > const &);
template void display_vector<bool>(T_HV<bool> const &vec);

void display_snapshot(snapshot_t& vec, char* name){
	cout << "snap " << name << endl;
	for (int i = 0; i < vec.size(); ++i){
		cout << "com " << i << endl;
		for (int j = 0; j < vec[i].size(); ++j){
			cout << vec[i][j] << " ";
		}
		cout << endl;
	}
	cout << endl;
	cout << "\n";
}

void display_snapshots(vector<snapshot_t>& vec, char* name){
	cout << name << ": " << endl;
	for (int i = 0; i < vec.size(); ++i){
		cout << "snap " << i << endl;
		for (int j = 0; j < vec[i].size(); ++j){
			cout << "com " << j << endl;
			for (int k = 0; k < vec[i][j].size(); ++k){
				cout << vec[i][j][k] << " ";
			}
			cout << endl;
		}
		cout << endl;
	}
	cout << "\n";
	cout << "\n";
}