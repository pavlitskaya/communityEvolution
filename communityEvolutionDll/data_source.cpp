#include "stdafx.h"
#include "include/data_source.h"
#include "include/host_storage_serilization.h"
#include "include/device_pair.h"

using namespace std;

namespace comevo{
	static U32 maxId = 0;
	static U32 sourceCount = 0;

	Source::Source() : sourceId(maxId), setupDone(0), upToDate(0) {
		filenameIntern = "internData0" + to_string(sourceId) + ".b";
		ofstream ofs("../storage/intern/" + filenameIntern, ios::binary);
		ofs.close();
		properties.nMax = 0;
		++maxId;
		
		++sourceCount;
	}

	Source::~Source(){
		string path;
		find_file(filenameIntern, path);
		if (remove(path.c_str()) != 0)
			perror("Error deleting file");
		if (sourceCount != 0){
			sourceCount = sourceCount - 1;
            sourceCount = max((U32)0, sourceCount);
		}
	}

	bool Source::set_source(vector<pairs_t>& vecPairs, vector<snapshot_t>& vecSnap, FileType filetype){
		if (filetype != SNAPS & PAIRS)return 0;
		this->filename = "";
		this->fileType = filetype;

		string pathSource, pathTarget;
		if (!find_file(filenameIntern, pathTarget)) return 0;
		ofstream writefile(pathTarget, ios::binary);
		ISOPEN(writefile, filenameIntern);

		if (filetype == PAIRS)store_pairs_direct(writefile, vecPairs, properties);
		if (filetype == SNAPS){
			properties.scomSnap.clear();
			vector < U32 > scom;
			for (uint32_t i = 0; i < vecSnap.size(); ++i){
				for (uint32_t j = 0; j < vecSnap[i].size(); ++j){
					scom.push_back(vecSnap[i][j].size());
				}
				properties.scomSnap.push_back(scom);
			}
			store_snaps_direct(writefile, vecSnap, properties);
		}
		
		this->setupDone = true;
		this->upToDate = false;
		return 1;
	}

	bool Source::set_source(string filename, FileType filetype){
		properties.mSnap.clear();
		properties.nMax = 0;
		properties.nSnap.clear();
		properties.scomSnap.clear();
		this->filename = filename;
		this->fileType = filetype;

		if (!find_file(this->filename, this->path))return 0;

		if (!convert_source())return 0;

		this->setupDone = true;
		this->upToDate = false;
		return 1;
	}

	bool Source::set_source(string filename, FileType filetype, RawType formatType, vector<uint32_t>& parameter){
		properties.mSnap.clear();
		properties.nMax = 0;
		properties.nSnap.clear();
		properties.scomSnap.clear();
		this->filename = filename;
		this->fileType = filetype;

		if (!find_file(this->filename, this->path))return 0;

		if (!convert_source(formatType	, parameter))return 0;

		this->setupDone = true;
		this->upToDate = false;
		return 1;
	}

	bool Source::convert_source(){
		if (fileType == RAW){
			cerr << "please pass correct type." << endl;
			return 0;
		}
		if (!convert_file(properties, filename, fileType, filenameIntern, false, true)){
			cerr << "problem filling file." << endl;
			return 0;
		}
		this->upToDate = false;
		return 1;
	}

	bool Source::convert_source(RawType formatType, vector<uint32_t>& parameter){
		if (!convert_raw(properties, filename, fileType, filenameIntern, formatType, parameter)){
			cerr << "problem filling file." << endl;
			return 0;
		}
		this->upToDate = false;
		return 1;
	}

	bool Source::store_in_file(string filename, bool binary){
		// check
		if (filename.empty()){
			cerr << "filename empty." << endl;
			return 0;
		}

		// create target file:
		if(fileType == PAIRS) {
			ofstream ofs("../storage/pairs/" + filename, ios::binary);
			ofs.close();
		}
		if (fileType == SNAPS) {
			ofstream ofs("../storage/snaps/" + filename, ios::binary);
			ofs.close();
		}

		vector<pairs_t> vec_pairs;
		vector<snapshot_t> snaps;
		if (!binary && fileType == PAIRS)
			vec_pairs = get_edges();
		if (!binary && fileType == SNAPS)
			snaps = get_snaps();
		if(!store_file(filenameIntern, filename, fileType, binary, vec_pairs, snaps, properties))return 0;
		return 1;
	}

	// characteristics
	uint32_t Source::get_number_of_objects(){ 
		cout << sourceCount << endl;
		return sourceCount; }
	uint32_t Source::get_max_id(){ return maxId; }
	uint32_t Source::get_id(){ return sourceId; }
	uint32_t Source::get_n_max(){ return properties.nMax; }
	vector<uint32_t> Source::get_n(){ return properties.nSnap; }
	vector<uint32_t> Source::get_m(){ return properties.mSnap; }
	uint32_t Source::get_n(uint32_t id){ return properties.nSnap[id]; }
	uint32_t Source::get_m(uint32_t id){ return properties.mSnap[id]; }
	vector<vector<uint32_t> > Source::get_scom(){ return properties.scomSnap; }
	vector<uint32_t> Source::get_scom(uint32_t id){ return properties.scomSnap[id]; }
	string Source::get_filename(){ return filename; }
	FileType Source::get_filetype(){ return fileType; }
	string Source::get_path(){ return path; }

	uint32_t Source::get_max_nodes(){
		if (!properties.nSnap.empty())
			return *std::max_element(properties.nSnap.begin(), properties.nSnap.end());
		return 0;
	}
	uint32_t Source::get_max_edges(){
		if (!properties.mSnap.empty())
			return *std::max_element(properties.mSnap.begin(), properties.mSnap.end());
		return 0;
	}
	uint32_t Source::get_total_nodes(){
		if (!properties.nSnap.empty())
			return std::accumulate(properties.nSnap.begin(), properties.nSnap.end(), 0);
		return 0;
	}
	uint32_t Source::get_total_edges(){
		if (!properties.nSnap.empty())
			return std::accumulate(properties.mSnap.begin(), properties.mSnap.end(), 0);
		return 0;
	}
	uint32_t Source::get_avg_nodes(){
		if (!properties.nSnap.empty())
			return std::accumulate(properties.nSnap.begin(), properties.nSnap.end(), 0)
			/ properties.nSnap.size();
		return 0;
	}
	uint32_t Source::get_avg_edges(){
		if (!properties.nSnap.empty())
			return std::accumulate(properties.mSnap.begin(), properties.mSnap.end(), 0) / properties.mSnap.size();
		return 0;
	}
	
	uint32_t Source::get_total_communities(){
		vector<snapshot_t> snaps = get_snaps();
		uint32_t count = 0;
		for (snapshot_t snap : snaps){
			count += snap.size();
		}
		return count;
	}
	uint32_t Source::get_max_communities(){
		vector<snapshot_t> snaps = get_snaps();
		uint32_t maximum = 0;
		for (snapshot_t snap : snaps){
            maximum = max(snap.size(), (size_t)maximum);
		}
		return maximum;
	}
	uint32_t Source::get_avg_communities(){
		vector<snapshot_t> snaps = get_snaps();
		uint32_t count = 0;
		for (snapshot_t snap : snaps){
			count += snap.size();
		}
		return count / snaps.size();
	}

	vector<nodes_t> Source::get_nodes(){
		vector<pairs_t> vec_pairs = get_edges();
		vector<nodes_t> vec_nodes(vec_pairs.size());
		for (uint32_t i = 0; i < vec_pairs.size(); ++i){
			pairsToUniqueNodes(vec_pairs[i], vec_nodes[i]);
		}
		return vec_nodes;
	}

	nodes_t Source::get_nodes(uint32_t index){
		nodes_t nodes;
        pairs_t pairs = get_edges(index);
        pairsToUniqueNodes(pairs, nodes);
		return nodes;
	}

	nodes_t Source::get_nodes(uint32_t index, uint32_t from, uint32_t to){
		nodes_t nodes;
		nodes = get_nodes(index);
		nodes.erase(nodes.begin() + to + 1, nodes.end());
		nodes.erase(nodes.begin(), nodes.begin() + from);
		return nodes;
	}

	vector<pairs_t> Source::get_edges(){
		vector<pairs_t> vec_pairs;
		Serilization::load_pairs(filenameIntern, properties.mSnap, vec_pairs);
		return vec_pairs;
	}

	pairs_t Source::get_edges(uint32_t index){
		pairs_t pairs;
		if (properties.mSnap.size() < index)return pairs;
		Serilization::load_pairs(filenameIntern, index, properties.mSnap, pairs);
		return pairs;
	}

	pairs_t Source::get_edges(uint32_t index, uint32_t from, uint32_t to){
		pairs_t pairs;
		if (properties.mSnap.size() < index)return pairs;
		Serilization::load_pairs(filenameIntern, index, from, to, properties.mSnap, pairs);
		return pairs;
	}

	vector<snapshot_t> Source::get_snaps(){
		vector<snapshot_t> snaps;
		Serilization::load_snaps(filenameIntern, properties.scomSnap, snaps);
		return snaps;
	}

	snapshot_t Source::get_snap(uint32_t index){
		snapshot_t snap;
		Serilization::load_snap(filenameIntern, index, properties.scomSnap, snap);
		return snap;
	}

	community_t Source::get_community(uint32_t index_snap, uint32_t index_com, uint32_t from, uint32_t to){
		community_t com;
		Serilization::load_com(filenameIntern, index_snap, index_com, from, to, properties.scomSnap, com);
		return com;
	}

	community_t Source::get_community(uint32_t index_snap, uint32_t index_com){
		community_t com;
		Serilization::load_com(filenameIntern, index_snap, index_com, properties.scomSnap, com);
		return com;
	}

	void Source::display(){
		if (fileType == PAIRS || fileType == RAW){
			vector<pairs_t> edges = get_edges();
			for (uint32_t i = 0; i != edges.size(); ++i){
				char textToWrite[16];
				sprintf(textToWrite, "pairs %lu", i);
				display_vector<uint32_t, uint32_t>(edges[i], textToWrite);
			}
		}

		if (fileType == SNAPS){
            std::vector<snapshot_t> snaps = get_snaps();
            display_snapshots(snaps, "snaps");
		}
	}

	void Source::display_properties(){
		//properties.mSnap
	}

}
