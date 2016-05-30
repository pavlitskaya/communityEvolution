#include "stdafx.h"
#include "include/host_storage_serilization.h"
#include "include/display_elements.h"
#include "include/host_storage_human.h"
#include "include/general_pair_structs.h"
#include "include/device_help.h"

using namespace std;

namespace comevo{

	static map<pair<string, uint32_t>, uint32_t> type_id_size;

	bool maxPair1(pair<U32, U32> p1, pair<U32, U32> p2) { return p1.first < p2.first; }
	bool maxPair2(pair<U32, U32> p1, pair<U32, U32> p2) { return p1.second < p2.second; }
	
	bool Serilization::store_compress(vector<uint32_t>& vec, string type, uint32_t id){
		string filename = "temp_vec_" + to_string(id) + "." + type;
		ofstream file(filename, ios::out | ofstream::binary);
		ISOPEN(file, filename);
		if (!vec.empty())file.write((char *)&*vec.begin(), sizeof(uint32_t)*vec.size());
		file.close();
		return 1;
	}

	bool Serilization::load_compress(vector<uint32_t>& vec, string type, uint32_t id, bool clean){
		string filename = "temp_vec_" + to_string(id) + "." + type;
		ifstream file(filename, ios::ate | ios::in | ifstream::binary);
		ISOPEN(file, filename);
		uint32_t size = file.tellg() / sizeof(uint32_t);
		file.seekg(0);
		vec.resize(size);
		if (!vec.empty())file.read((char *)&*vec.begin(), sizeof(uint32_t)*size);
		file.close();
		if (clean)
			if (remove(filename.c_str()) != 0)
				perror("Error deleting file");
		return 1;
	}

	bool Serilization::store(T_HV<uint32_t>& h_vec, string type, uint32_t id){
		//vector<uint32_t> vec(h_vec.begin(), h_vec.end());
		store(&*h_vec.begin(), h_vec.size(), type, id);
		return 1;
	}

	bool Serilization::load(T_HV<uint32_t>& h_vec, string type, uint32_t id, bool clean){
		string filename = "temp_vec_" + to_string(id) + "." + type;
		ifstream file(filename, ios::ate | ios::in | ifstream::binary);
		ISOPEN(file, filename);
		uint32_t size = file.tellg() / sizeof(uint32_t);
		file.seekg(0);
		allocate_vector<uint32_t>(h_vec, size);
		
		if (size > 0)file.read((char *)&*h_vec.begin(), sizeof(uint32_t)*size);
		file.close();
		if (clean)
			if (remove(filename.c_str()) != 0)
				perror("Error deleting file");
		return 1;
	}
	
	
	bool Serilization::store(T_HV<pair_t>& h_vec, string type, uint32_t id){
		vector<pair_t> vec(h_vec.begin(), h_vec.end());
		store(vec, type, id);
		return 1;
	}

	bool Serilization::load(T_HV<pair_t>& h_vec, string type, uint32_t id, bool clean){
		vector<pair_t> vec(0);
		load(vec, type, id, clean);
		fill_vector<pair_t>(vec, h_vec);
		return 1;
	}
	
	bool Serilization::store(vector<uint32_t>& vec, string type, uint32_t id){
		string filename = "temp_vec_" + to_string(id) + "." + type;
		ofstream file(filename, ios::out | ofstream::binary);
		ISOPEN(file, filename);
		if(!vec.empty())file.write((char *)&*vec.begin(), sizeof(uint32_t)*vec.size());
		file.close();
		return 1;
	}

	bool Serilization::load(vector<uint32_t>& vec, string type, uint32_t id, bool clean){
		string filename = "temp_vec_" + to_string(id) + "." + type;
		ifstream file(filename, ios::ate | ios::in | ifstream::binary);
		ISOPEN(file, filename);
		uint32_t size = file.tellg() / sizeof(uint32_t);
		file.seekg(0);
		vec.resize(size);
		if (!vec.empty())file.read((char *)&*vec.begin(), sizeof(uint32_t)*size);
		file.close();
		if (clean)
			if (remove(filename.c_str()) != 0)
				perror("Error deleting file");
		return 1;
	}

	bool Serilization::store(vector<pair_t>& vec, string type, uint32_t id){
		string filename = "temp_vec_" + to_string(id) + "." + type;
		//string filenameSecond = "temp_vec_second_" + to_string(id) + "." + type;
		ofstream file(filename, ios::out | ofstream::binary);
		ISOPEN(file, filename);
		if (!vec.empty())file.write((char *)&*vec.begin(), sizeof(pair_t)*vec.size());
		file.close();
		/*string filenameFirst = "temp_vec_first_" + to_string(id) + "." + type;
		string filenameSecond = "temp_vec_second_" + to_string(id) + "." + type;
		ofstream fileFirst(filenameFirst, ios::out | ofstream::binary);
		ISOPEN(fileFirst, filenameFirst);
		std::copy(T_MTI(vec.begin(), first_element()), T_MTI(vec.end(), first_element()),
			ostream_iterator<uint32_t>(fileFirst));
		fileFirst.close();
		ofstream fileSecond(filenameSecond, ios::out | ofstream::binary);
		ISOPEN(fileSecond, filenameSecond);
		std::copy(T_MTI(vec.begin(), second_element()), T_MTI(vec.end(), second_element()), ostream_iterator<uint32_t>(fileSecond));
		fileSecond.close();*/
		return 1;
	}

	bool Serilization::load(vector<pair_t>& vec, string type, uint32_t id, bool clean){
		string filename = "temp_vec_" + to_string(id) + "." + type;
		ifstream file(filename, ios::ate | ios::in | ifstream::binary);
		ISOPEN(file, filename);
		uint32_t size = file.tellg() / sizeof(pair_t);
		file.seekg(0);
		vec.resize(size);
		if (!vec.empty())file.read((char *)&*vec.begin(), sizeof(pair_t)*size);

		file.close();

		/*vector<uint32_t> vecFirst(0);
		vector<uint32_t> vecSecond(0);
		string filenameFirst = "temp_vec_first_" + to_string(id) + "." + type;
		string filenameSecond = "temp_vec_second_" + to_string(id) + "." + type;
		ifstream fileFirst(filenameFirst, ios::in | ifstream::binary);
		ISOPEN(fileFirst, filenameFirst);
		ifstream fileSecond(filenameSecond, ios::in | ifstream::binary);
		ISOPEN(fileSecond, filenameSecond);
		vecFirst.assign((istream_iterator<uint32_t>(fileFirst)),
			(istream_iterator<uint32_t>()));
		vecSecond.assign((istream_iterator<uint32_t>(fileSecond)),
			(istream_iterator<uint32_t>()));
		vec.assign(
			T_MTI(T_MZIMT(vecFirst.begin(), vecSecond.begin()), pair_create()),
			T_MTI(T_MZIMT(vecFirst.end(), vecSecond.end()), pair_create()));
		fileFirst.close();
		fileSecond.close();*/
		if (clean)
			if (remove(filename.c_str()) != 0)// || remove(filenameSecond.c_str()) != 0)
				perror("Error deleting file");
		return 1;
	}



	void Serilization::load_com(std::string filename, uint32_t index_snap, uint32_t index_com, uint32_t from, uint32_t to, std::vector<std::vector<uint32_t> >& sourceSize, community_t& com){
		string path;
		if (!find_file(filename, path))return;
		ifstream ifs(path, ios::binary);
		uint32_t offset = 0;
		for (uint32_t i = 0; i < index_snap; ++i){
			offset += std::accumulate(sourceSize[i].begin(), sourceSize[i].end(), 0);
		}
		offset += std::accumulate(sourceSize[index_snap].begin(), sourceSize[index_snap].begin() + index_com, 0);
		offset += from;
		ifs.seekg(offset * sizeof(uint32_t));
		Serilization::load_com(ifs, _min(to - from, sourceSize[index_snap][index_com] - from), com);
		ifs.close();
	}

	void Serilization::load_com(std::string filename, uint32_t index_snap, uint32_t index_com, std::vector<std::vector<uint32_t> >& sourceSize, community_t& com){
		string path;
		if (!find_file(filename, path))return;
		ifstream ifs(path, ios::binary);
		uint32_t offset = 0;
		for (uint32_t i = 0; i < index_snap; ++i){
			offset += std::accumulate(sourceSize[i].begin(), sourceSize[i].end(), 0);
		}
		offset += std::accumulate(sourceSize[index_snap].begin(), sourceSize[index_snap].begin() + index_com, 0);
		ifs.seekg(offset * sizeof(uint32_t));
		Serilization::load_com(ifs, sourceSize[index_snap][index_com], com);
		ifs.close();
	}
	
	void Serilization::load_com(std::ifstream& ifs, uint32_t sourceSize, community_t& com){
		uint32_t* item = (uint32_t*)malloc(sizeof(uint32_t)* sourceSize);
		ifs.read((char *)item, sizeof(uint32_t)*sourceSize);
		com = community_t(item, item + sourceSize);
		free(item);
	}

	void Serilization::load_snap(std::ifstream& ifs, std::vector < uint32_t >& sourceSize, snapshot_t& snap){
		if (sourceSize.size() == 0)return;
		for (uint32_t j = 0; j < sourceSize.size(); ++j){
			community_t com;
			Serilization::load_com(ifs, sourceSize[j], com);
			snap.push_back(com);
		}
	}

	void Serilization::load_snaps(std::string filename, std::vector < std::vector<uint32_t> >& sourceSize, std::vector<snapshot_t>& snaps){
		string path;
		if (!find_file(filename, path))return;
		ifstream ifs(path, ios::binary);
		for (uint32_t i = 0; i < sourceSize.size(); ++i){
			snapshot_t snap;
			Serilization::load_snap(ifs, sourceSize[i], snap);
			snaps.push_back(snap);
		}
		ifs.close();
	}

	void Serilization::load_snap(std::string filename, uint32_t index, std::vector < std::vector<uint32_t> >& sourceSize, snapshot_t& snap){
		string path;
		if (!find_file(filename, path))return;
		ifstream ifs(path, ios::binary);

		uint32_t offset = 0;
		for (uint32_t i = 0; i < index; ++i){
			offset += std::accumulate(sourceSize[i].begin(), sourceSize[i].end(), 0);
		}
		ifs.seekg(offset * sizeof(uint32_t));
		Serilization::load_snap(ifs, sourceSize[index], snap);
		ifs.close();
	}

	void Serilization::load_pairs(std::ifstream& ifs, uint32_t sourceSize, pairs_t& pairs){
		pair_t* item = (pair_t*)malloc(sizeof(pair_t)* sourceSize);
		ifs.read((char *)item, sizeof(pair_t)*sourceSize);
		pairs = pairs_t(item, item + sourceSize);
		free(item);
	}

	void Serilization::load_pairs(string filename, uint32_t index, uint32_t from, uint32_t to, std::vector<uint32_t>& sourceSize, pairs_t& pairs){
		string path;
		if (!find_file(filename, path))return;
		ifstream ifs(path, ios::binary);
		uint32_t offset = std::accumulate(sourceSize.begin(), sourceSize.begin() + index, 0);
		offset += from;
		ifs.seekg(offset * sizeof(pair_t));
		Serilization::load_pairs(ifs, _min(to - from, sourceSize[index] - from), pairs);
		ifs.close();
	}

	void Serilization::load_pairs(string filename, uint32_t index, std::vector<uint32_t>& sourceSize, pairs_t& pairs){
		string path;
		if (!find_file(filename, path))return;
		ifstream ifs(path, ios::binary);
		uint32_t offset = std::accumulate(sourceSize.begin(), sourceSize.begin() + index, 0);
		ifs.seekg(offset * sizeof(pair_t));
		Serilization::load_pairs(ifs, sourceSize[index], pairs);
		ifs.close();
	}

	void Serilization::load_pairs(std::string filename, std::vector<uint32_t>& sourceSize, std::vector<std::vector<pair_t> >& target){
		string path;
		if (!find_file(filename, path))return;
		ifstream ifs(path, ios::binary);
		for (uint32_t i = 0; i < sourceSize.size(); ++i){
			pairs_t pairs;
			Serilization::load_pairs(ifs, sourceSize[i], pairs);
			target.push_back(pairs);
		}
		ifs.close();
	}


	bool Serilization::store(uint32_t* item, uint32_t size, string type, uint32_t id){
		string filename = "temp_vec_" + to_string(id) + "." + type;
		ofstream file(filename, ios::out | ofstream::binary);
		ISOPEN(file, filename);
		if (size > 0)file.write((char *)item, sizeof(uint32_t)*size);
		file.close();
	}

	bool Serilization::load(uint32_t* &item, uint32_t& size, string type, uint32_t id, bool clean){
		string filename = "temp_vec_" + to_string(id) + "." + type;
		ifstream ifs(filename, ios::binary);
		size = type_id_size[pair<string, uint32_t>(type, id)];
		item = (uint32_t*)malloc(sizeof(uint32_t)*size);
		ifs.read((char *)item, sizeof(uint32_t)*size);
		ifs.close();
		if (clean)
			if (remove(filename.c_str()) != 0)
				perror("Error deleting file");
		return 1;
	}

	bool Serilization::store(pair_t* item, uint32_t size, string type, uint32_t id){
		string filename = "temp_vec_" + to_string(id) + "." + type;
		type_id_size.erase(pair<string, uint32_t>(type, id));
		type_id_size.insert(pair<pair<string, uint32_t>, uint32_t>(pair<string, uint32_t>(type, id), size));
		ofstream ofs(filename, ios::binary);
		ofs.write((char *)item, sizeof(pair_t)*size);
		ofs.close();
		return 1;
	}

	bool Serilization::load(pair_t* &item, uint32_t& size, string type, uint32_t id, bool clean){
		uint32_t run = 0;
		string filename = "temp_vec_" + to_string(id) + "." + type;
		ifstream ifs(filename, ios::binary);
		if (!ifs.is_open()){
            std::this_thread::sleep_for (std::chrono::milliseconds(50));
			ifstream ifs(filename, ios::binary);
		}
		if (ifs.is_open()){
			size = type_id_size[pair<string, uint32_t>(type, id)];
			if (size > 0){
				do{
					++run;
                    std::this_thread::sleep_for (std::chrono::milliseconds(50*run));
					item = (pair_t*)malloc(sizeof(pair_t)*size);
				} while (item == NULL && run < 10);
				if (item == NULL){
					cout << size << endl;
					cout << id << endl;
					printf("allocation went wrong\n");
					item = (pair_t*)malloc(sizeof(pair_t) * 0);
					size = 0;
				}
				else{
					ifs.read((char *)item, sizeof(pair_t)*size);
				}
			}
			ifs.close();
		}
		else{
			printf("Cant open file\n");

		}
		if (clean)
			if (remove(filename.c_str()) != 0)
				perror("Error deleting file");
		return 1;
	}
}
