#include "stdafx.h"
#include "include/host_storage_human.h"
#include "include/display_elements.h"
#include "include/general_pair.h"
#include "include/device_pair.h"
#include "include/device_pair_construct.h"

using namespace std;

namespace comevo{
	const char *fileTypeFolder[] = { "all", "raw", "pairs", "snaps", "results", "info", "intern" };

	bool find_file(string filename, string &path){
		vector<pair<dirent, string> > files = get_files(ALLFILES);
		for (vector<pair<dirent, string> >::iterator it = files.begin(); it != files.end(); ++it){
			if (strcmp((*it).first.d_name, filename.c_str()) == 0){
				path = (*it).second + "/" + filename;
				return 1;
			}
		}
		cerr << "problem finding file '" << filename << "'" << "Add it to the storage directory." << endl;
		return 0;

	}

	vector<pair<dirent, string> > get_files(FileType folder){
		vector<pair<dirent, string> > files;

		DIR *d;
		struct dirent *dir;
		bool all = false;
		if (folder == ALLFILES){
			all = true;
			folder = static_cast<FileType>(folder + 1);
		}

		do {
			string filename = "../storage/";
			filename += fileTypeFolder[folder];

			d = opendir(filename.c_str());
			if (d)
			{
				while ((dir = readdir(d)) != NULL)
					if (dir->d_type == DT_REG)
						files.push_back(pair<dirent, string>(*dir, filename));
				closedir(d);
			}
			folder = static_cast<FileType>(folder + 1);
		} while (all && folder <= INTERN);
		return files;

	}

	void display_files(FileType folder){
		vector<pair<dirent, string>> files = get_files(folder);

		cout << fileTypeFolder[folder] << " files" << endl;

		uint32_t count = 1;
		for (vector<pair<dirent, string>>::iterator it = files.begin(); it != files.end(); ++it){
			dirent dir = (*it).first;
			printf("%d: %s\n", count, dir.d_name);
			++count;
		}
	}

	bool get_file(FileType folder, uint32_t file_id, dirent& file){
		vector<pair<dirent, string>> files = get_files(folder);

		uint32_t count = 1;
		for (vector<pair<dirent, string>>::iterator it = files.begin(); it != files.end(); ++it){
			if (count == file_id){
				file = (*it).first;
				return 1;
			}
			++count;
		}
		return 0;
	}

	bool convertLineToStringInt(string& line, string& _s, U32& _i){
		istringstream iss(line);
		string nsign;
		iss >> nsign >> _s >> _i;
		if (_s == "")
			return 0;
		if (_i == 0)
			return 0;
		return 1;
	}

	bool convertLineToPairs(string& line, vector<pair_t>& _pairs){
		pair_t p;
		uint32_t size = count(line.begin(), line.end(), ':');
		if (size == 0)return 1;
		_pairs.reserve(size);
		replace(line.begin(), line.end(), ':', ' ');
		istringstream iss(line);
		while (iss >> p.first){
			iss >> p.second;
			pair_order(p);
			_pairs.push_back(move(p));
		}
		if (_pairs.size() != size) return 0;
		return 1;
	}

	bool convertLineToPair(string& line, pair_t& _pair){
		istringstream iss(line);
		iss >> _pair.first >> _pair.second;
		if (_pair.first == _pair.second)
			return 0;
		pair_order(_pair);
		return 1;
	}

	bool convertLineToInts(string& line, vector<U32>& vec){
		istringstream iss(line);
		vec = vector<U32>(istream_iterator<U32>(iss),
			istream_iterator<U32>());
		if (vec.empty()) return 0;
		return 1;
	}

	bool store_pairs(ofstream& ofs, vector<pairs_t>& vec_pairs, Source_Props& properties){
		ofs << "# " << vec_pairs.size() << " Snapshots ";
		ofs << properties.nMax + 1 << " Nodes ";
		ofs << endl;
		uint32_t count = 0;
		for (vector<pairs_t>::iterator it = vec_pairs.begin(); it != vec_pairs.end(); ++it){
			ofs << "# snap " << ++count << endl;
			for (pairs_t::iterator it2 = (*it).begin(); it2 != (*it).end(); ++it2){
				pair_t p = *it2;
				ofs << p.first << ":" << p.second << " ";
			}
			ofs << endl;
		}
		return 1;
	}

	bool store_snaps(ofstream& ofs, vector<snapshot_t>& snaps, Source_Props& properties){
		ofs << "# " << snaps.size() << " Snapshots ";
		ofs << endl;

		uint32_t count = 0;
		for (vector<snapshot_t>::iterator it = snaps.begin(); it != snaps.end(); ++it){
			++count;
			ofs << "# Snapshot " << count << " " 
				<< properties.scomSnap[count - 1].size() << " Communities" << endl;
			for (snapshot_t::iterator it2 = (*it).begin(); it2 != (*it).end(); ++it2){
				for (community_t::iterator it3 = (*it2).begin(); it3 != (*it2).end(); ++it3){
					ofs << *it3 << " ";
				}
				ofs << endl;
			}
			if (it != snaps.end() - 1)ofs << endl;
		}
		return 1;
	}

	bool store_pairs_direct(ofstream& ofs, vector<pairs_t>& vecPairs, Source_Props& properties){
		properties.nMax = 0;
		properties.nSnap.clear();
		properties.mSnap.clear();
		vector<U32> nodes;
		for (uint32_t i = 0; i < vecPairs.size(); ++i){
			
			pairsToNodes(vecPairs[i], nodes);
			properties.nMax = max(properties.nMax, *max_element(nodes.begin(), nodes.end()));
			pairsToUniqueNodes(vecPairs[i], nodes);
			properties.nSnap.push_back(nodes.size());
			properties.mSnap.push_back(vecPairs[i].size());

			// fill
			ofs.write((char *)&vecPairs[i].front(), sizeof(pair_t)*vecPairs[i].size());
		}
		return 1;
	}

	bool store_snaps_direct(ofstream& ofs, vector<snapshot_t>& vecSnaps, Source_Props& properties){
		properties.scomSnap.clear();
		for (uint32_t i = 0; i < vecSnaps.size(); ++i){
			vector < U32 > scom;
			for (uint32_t j = 0; j < vecSnaps[i].size(); ++j){
				ofs.write((char *)&*vecSnaps[i][j].begin(), sizeof(U32)*vecSnaps[i][j].size());
				scom.push_back(vecSnaps[i][j].size());
			}
			properties.scomSnap.push_back(scom);
			scom.clear();
		}
		return 1;
	}

	bool store_file(string& filenameSource, string& filenameTarget, FileType fileType, bool binary, vector<pairs_t>& vec_pairs, vector<snapshot_t>& snaps, Source_Props& properties){
		
		// common
		string pathSource, pathTarget;
		if (!find_file(filenameSource, pathSource)) return 0;
		if (!find_file(filenameTarget, pathTarget)) return 0;
		ifstream readfile(pathSource, ios::binary);
		ISOPEN(readfile, filenameSource);

		// binary
		if (binary){
            ofstream writefile(pathTarget, ios::binary);
            ISOPEN(writefile, filenameTarget);
			writefile << readfile.rdbuf();
			readfile.close();
            writefile.close();
			return 1;
		} 
		else{
            ofstream writefile(pathTarget);
			ISOPEN(writefile, filenameTarget);

			if (fileType == PAIRS){
				// write pairs to file
                if(!store_pairs(writefile, vec_pairs, properties))return 0;
			}

			// snaps
			if (fileType == SNAPS){
                if (!store_snaps(writefile, snaps, properties))return 0;
			}
            writefile.close();
		}
        readfile.close();
		return 1;

	}

	bool convert_snaps(Source_Props& properties, ifstream& pathSource, ofstream& pathTarget){
		properties.scomSnap.clear();
		string line, str_val;
		U32 start = 0, i_val;
		pair_t p;
		vector < U32 > vec;
		vector < U32 > scom;
		while (getline(pathSource, line)){
			// comment entry
			if (line.find('#', start) != string::npos){
			}
			// line empty (snapshot ends)
			else if (line.size() == 0){
				properties.scomSnap.push_back(scom);
				scom.clear();
			}
			else if (convertLineToInts(line, vec)){
				pathTarget.write((char *)&*vec.begin(), sizeof(U32)*vec.size());
				scom.push_back(vec.size());
			}
			else{
			}
		}
		if (scom.size() > 0){
			properties.scomSnap.push_back(scom);
		}
		return 1;
	}

	bool convert_pairs(Source_Props& properties, ifstream& readfile, ofstream& writefile){
		properties.nMax = 0;
		properties.nSnap.clear();
		properties.mSnap.clear();
		string line, str_val;
		U32 start = 0, i_val;
		pair_t p;
		vector<pair_t> pairs;
		vector<U32> nSnap, mSnap;
		vector<U32> nodes;

		while (getline(readfile, line)){
			// comment entry
			if (line.find('#', start) != string::npos)continue;
			if (convertLineToPairs(line, pairs)){

				// analyse
				// pairs to nodes
				pairsToNodes(pairs, nodes);
				if (pairs.size() > 0)
					properties.nMax = max(properties.nMax, *max_element(nodes.begin(), nodes.end()));
				pairsToUniqueNodes(pairs, nodes);
				properties.nSnap.push_back(nodes.size());
				properties.mSnap.push_back(pairs.size());

				// fill
				if (pairs.size() > 0)
					writefile.write((char *)&pairs.front(), sizeof(pair_t)*pairs.size());
				//pathTarget.write((char *)&"\n\r", sizeof(char) * 2);
				pairs.clear();
			}
			else{
				return 0;
			}
		}
		return 1;
	}

	bool convert_file(Source_Props& properties, string filenameSource, FileType fileType, string filenameTarget, bool binarySource, bool binaryTarget){

		// common
		string pathSource, pathTarget;
		if (!find_file(filenameSource, pathSource)) return 0;
		if (!find_file(filenameTarget, pathTarget)) return 0;
		ofstream writefile(pathTarget, ios::binary);
		ISOPEN(writefile, filenameTarget);

		// binary
		if (binarySource){
			ifstream readfile(pathSource, ios::binary);
			ISOPEN(readfile, filenameSource);
			if (binaryTarget)
				writefile << readfile.rdbuf();
			readfile.close();
			writefile.close();
			return 1;
		}

		ifstream readfile(pathSource);
		ISOPEN(readfile, filenameSource);

		// pairs
		if (fileType == PAIRS){
			if (!convert_pairs(properties, readfile, writefile)) return 0;
		}

		// snaps
		if (fileType == SNAPS){
			if (!convert_snaps(properties, readfile, writefile)) return 0;
		}

		readfile.close();
		writefile.close();
		return 1;
	}
	
	bool convert_raw(Source_Props& properties, string filenameSource, FileType fileType, string filenameTarget, RawType formatType, vector<uint32_t>& parameter){
		// common
		string pathSource, pathTarget;
		if (!find_file(filenameSource, pathSource)) return 0;
		if (!find_file(filenameTarget, pathTarget)) return 0;
		ofstream writefile(pathTarget, ios::binary);
		ISOPEN(writefile, filenameTarget);
		ifstream readfile(pathSource);
		uint32_t limit = 0;

		// edges only
		if (formatType == EDGES){
			string line;
			uint32_t linecount = 0;
			uint32_t start = 0;
			pair_t _pair;
			uint32_t count = 0;
			pairs_t pairs;
			while (getline(readfile, line)){
				// split data
				if (!parameter.empty()){
					if (parameter[0] == 1){
						if (limit == 0)
							limit = parameter[1];
						else if (limit - linecount == 0){
							limit += parameter[1];

							// next snap
							nodes_t nodes;
							if (pairs.size() > 0){
								std::sort(pairs.begin(), pairs.end());
								pairs.erase(std::unique(pairs.begin(), pairs.end()), pairs.end());
								writefile.write((char *)&pairs.front(), sizeof(pair_t)*pairs.size());
								pairsToUniqueNodes(pairs, nodes);
								if (nodes.size() > 0)
									properties.nMax = max(properties.nMax, *max_element(nodes.begin(), nodes.end()));
							}
							properties.nSnap.push_back(nodes.size());
							properties.mSnap.push_back(pairs.size());
							if (pairs.size() > 0)
								writefile.write((char *)&pairs.front(), sizeof(pair_t)*pairs.size());
							nodes.clear();
							pairs.clear();
						}
					}
				}

				// comment entry
				if (line.find('#', start) != string::npos)continue;
				if (line.size() == 0)continue;
				istringstream iss(line);
				iss >> _pair.first >> _pair.second;
				if (_pair.first != _pair.second){
					pair_order(_pair);
					pairs.push_back(_pair);
					//if (std::find(pairs.begin(), pairs.end(), _pair) == pairs.end()){
						// properties.nMax = max(properties.nMax, max(_pair.first, _pair.second));
				}
				++linecount;

			}
			nodes_t nodes;
			if (pairs.size() > 0){
				std::sort(pairs.begin(), pairs.end());
				pairs.erase(std::unique(pairs.begin(), pairs.end()), pairs.end());
				writefile.write((char *)&pairs.front(), sizeof(pair_t)*pairs.size());
				pairsToUniqueNodes(pairs, nodes);
				if (nodes.size() > 0)
					properties.nMax = max(properties.nMax, *max_element(nodes.begin(), nodes.end()));
			}
			properties.nSnap.push_back(nodes.size());
			properties.mSnap.push_back(pairs.size());
		}

		// csv
		else if (formatType == CSV){
			convert_csv(properties, readfile, writefile, parameter);
		}
		readfile.close();
		writefile.close();
	}

	bool convert_csv(Source_Props& properties, std::ifstream& readfile, std::ofstream& writefile, std::vector<uint32_t>& parameter){
		if (parameter.size() < 1) return 0;
		uint32_t limit = parameter[0];
        if (limit == 0)limit = numeric_limits<uint32_t>::max();
		time_t from = parameter[1]; // convert to time_t
		time_t to = parameter[2];
		uint32_t interval = parameter[3];
		uint32_t overlap = parameter[4];
		if (interval < overlap){
			cerr << "interval must not be smaller than overlap" << endl;
			return 0;
		}
		
		//printf("limit: %lu from: %lld to: %lld interval: %lu overlap: %lu \n", limit, from, to, interval, overlap);

		string line;
		uint32_t count = 0;
		vector<time_t> times;
		time_t cur_time;
		string time_str;
		vector<uint32_t> threads;
		uint32_t thread;
		vector<uint32_t> users;
		uint32_t user;
		struct tm * _tm;
		time_t rawtime;
		std::time(&rawtime);
		_tm = localtime(&rawtime);
		time_t time_original, time_delimiter;
		uint32_t thread_pre;
		bool first_entry = true;
		while (getline(readfile, line) && count < limit){

			replace(line.begin(), line.end(), '-', ' ');
			replace(line.begin(), line.end(), ':', ' ');
			replace(line.begin(), line.end(), ',', ' ');
			istringstream iss(line);
			iss >> _tm->tm_year >> _tm->tm_mon >> _tm->tm_mday
				>> _tm->tm_hour >> _tm->tm_min >> _tm->tm_sec
				>> thread >> user;
			_tm->tm_year -= 1900;
			_tm->tm_hour = 1; _tm->tm_min = 1; _tm->tm_sec = 1;
			cur_time = mktime(_tm);

			// first
			if (first_entry){
				if (cur_time < from){
					continue;
				}
			}
			// last
			else{
				if (cur_time > to){
					break;
				}
			}
			if (first_entry){
				time_delimiter = cur_time + interval * 86400;
				first_entry = false;
			}

			// new snapshot
			while (cur_time >= time_delimiter){
				if (threads.size() > 1){
					vector<pair_t> pairs = create_snapshot(threads, users);
					nodes_t nodes;
					pairsToNodes(pairs, nodes);
					if (nodes.size() > 0)
						properties.nMax = max(properties.nMax, *max_element(nodes.begin(), nodes.end()));
					pairsToUniqueNodes(pairs, nodes);
					properties.nSnap.push_back(nodes.size());
					properties.mSnap.push_back(pairs.size());

					// fill
					if (nodes.size() > 0)
						writefile.write((char *)&pairs.front(), sizeof(pair_t)*pairs.size());
				}
				else{
					properties.nSnap.push_back(0);
					properties.mSnap.push_back(0);
				}

				time_delimiter = time_delimiter - overlap * 86400;
				vector<time_t>::iterator t_it = lower_bound(times.begin(), times.end(), time_delimiter);
				uint32_t t_count = t_it - times.begin();
				// reassign
				times.erase(times.begin(), times.begin() + t_count);
				threads.erase(threads.begin(), threads.begin() + t_count);
				users.erase(users.begin(), users.begin() + t_count);

				time_delimiter += interval * 86400;
			}
			times.push_back(cur_time);
			threads.push_back(thread);
			users.push_back(user);

			++count;
		}

		if (threads.size() > 1){
			nodes_t nodes;
			vector<pair_t> pairs = create_snapshot(threads, users);
			pairsToNodes(pairs, nodes);
			properties.nMax = max(properties.nMax, *max_element(nodes.begin(), nodes.end()));
			pairsToUniqueNodes(pairs, nodes);
			properties.nSnap.push_back(nodes.size());
			properties.mSnap.push_back(pairs.size());

			// fill
			writefile.write((char *)&pairs.front(), sizeof(pair_t)*pairs.size());
		}
		else{
			properties.nSnap.push_back(0);
			properties.mSnap.push_back(0);
		}
		
		return 1;
	}

	vector<pair_t> create_snapshot(vector<uint32_t>& threads, vector<uint32_t>& users){
		vector<pair_t> pairs;
		// make unique

		generate_unique_pairs(threads, users, pairs);

		return pairs;

	}

	void storeVector(ofstream& writefile, std::vector<bool>& vec, char* name){
        writefile << "\"" << name << "\": [";
		if (!vec.empty()){

            bool comma = false;
			for (std::vector<bool>::const_iterator it = vec.begin(); it != vec.end(); ++it){
                if (!comma) { comma = true; }
                else { writefile << ", "; }
                writefile << *it;
			}
		}
        writefile << "]";
	}

	void storeTripleVector(ofstream& writefile, std::vector<tuple_triple>& vec, char* name, bool split){
        writefile << "\"" << name << "\": ";

        if (vec.size() == 0) {
            writefile << "[]";
            return;
        }

        writefile << "[";
        bool comma = false;
		for (std::vector<tuple_triple>::iterator it = vec.begin(); it != vec.end(); ++it){
            if (!comma) { comma = true; }
            else { writefile << ", "; }

			tuple_triple trip = *it;
            if (split) {
                writefile << "{\"from\": " << thrust::get<0>(trip) << ", \"into\": [" << thrust::get<1>(trip) << ", " << thrust::get<2>(trip) << "] }";
            } else {
                writefile << "{\"from\": [" << thrust::get<0>(trip) << ", " << thrust::get<1>(trip) << "], \"into\": " << thrust::get<2>(trip) << "} ";
            }
        }

        writefile << "]";
	}

	void storePairVector(ofstream& writefile, std::vector<pair_ti>& vec, char* name, char* str){
        writefile << "\"" << name << "\": ";

        if (vec.size() == 0) {
            writefile << "[]";
            return;
        }

        writefile << "[";
        bool comma = false;
		for (std::vector<pair_ti>::iterator it = vec.begin(); it != vec.end(); ++it){
            if (!comma) { comma = true; }
            else { writefile << ", "; }

			pair_ti p = *it;
            writefile << "{\"x\": " << p.first << ", \"" << std::string(str) << "\": " << p.second << "}";
        }
        writefile << "]";
	}

    bool save_to_file(std::string filename, uint32_t snap1, uint32_t snap2, std::vector<bool>& _dissolve, std::vector<bool>& _form, std::vector<tuple_triple>& _merge, std::vector<tuple_triple>& _split, std::vector<pair_ti>& _continue, uint32_t _appear, uint32_t _disappear, std::vector<pair_ti>& _join, std::vector<pair_ti>& _leve){

		// open file
		ofstream writefile(filename);
		ISOPEN(writefile, filename);
		
        writefile << "{"<< std::endl;

        writefile << "\"snap1\":" << snap1 << "," << std::endl;
        writefile << "\"snap2\":" << snap2 << "," << std::endl;

        writefile << "\"sizes\": " << std::endl << "    { "
                     "\"dissolve\": " << thrust::count(_dissolve.begin(), _dissolve.end(), 1) <<
                     ", \"form\": " << thrust::count(_form.begin(), _form.end(), 1) <<
                     ", \"merge\": " << _merge.size() <<
                     ", \"split\": " << _split.size() <<
                     ", \"continue\": " << _continue.size() <<
                     ", \"appear\": " << _appear <<
                     ", \"disappear\": " << _disappear <<
                     ", \"join\": " << _join.size() <<
                     ", \"leave\": " << _leve.size()
                  << "}, " << std::endl;

        writefile << "\"events\": {" << endl;

        writefile << "    ";
		storeVector(writefile, _dissolve, "dissolve");
        writefile << "," << std::endl;
        writefile << "    ";
		storeVector(writefile, _form, "form");
        writefile << "," << std::endl;
        writefile << "    ";
		storeTripleVector(writefile, _merge, "merge", 0);
        writefile << "," << std::endl;
        writefile << "    ";
		storeTripleVector(writefile, _split, "split", 1);
        writefile << "," << std::endl;
        writefile << "    ";
		storePairVector(writefile, _continue, "continue", "#");
        writefile << "," << std::endl;
        writefile << "    ";
		storePairVector(writefile, _join, "join", "to");
        writefile << "," << std::endl;
        writefile << "    ";
        storePairVector(writefile, _leve, "leave", "from");
		
        writefile << std::endl << "    }" << std::endl;
        writefile << "}" << std::endl;
		writefile.close();
		return 1;
	}
}
