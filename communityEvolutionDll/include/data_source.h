#pragma once

#ifdef DATASOURCEDLL_EXPORTS
#define DATASOURCDLL_API __declspec(dllexport) 
#else
#define DATASOURCDLL_API __declspec(dllimport) 
#endif

#include "../include/local_host_headers.h"

namespace comevo{

	struct Source{
	private:
		Source_Props properties;
		uint32_t sourceId;
		std::string filename, path;
		FileType fileType;

		// intern
		bool setupDone, upToDate;
		std::string filenameIntern, pathIntern;


	public:
		DATASOURCDLL_API Source();
		DATASOURCDLL_API ~Source();

		DATASOURCDLL_API bool Source::set_source(std::vector<pairs_t>& vecPairs, std::vector<snapshot_t>& vecSnap, FileType filetype);
		DATASOURCDLL_API bool set_source(std::string filename, FileType filetype);
		DATASOURCDLL_API bool set_source(std::string filename, FileType filetype, RawType formatType, std::vector<uint32_t>& parameter);
		DATASOURCDLL_API bool convert_source();
		DATASOURCDLL_API bool convert_source(RawType formatType, std::vector<uint32_t>& parameter); // TODO
		DATASOURCDLL_API bool store_in_file(std::string filename, bool binary); 

		// characteristics
		DATASOURCDLL_API uint32_t get_number_of_objects();
		DATASOURCDLL_API uint32_t get_max_id();
		DATASOURCDLL_API uint32_t get_id();
		DATASOURCDLL_API uint32_t get_n_max(); 
		DATASOURCDLL_API std::vector<uint32_t> get_n(); 
		DATASOURCDLL_API std::vector<uint32_t> get_m(); 
		DATASOURCDLL_API uint32_t get_n(uint32_t); 
		DATASOURCDLL_API uint32_t get_m(uint32_t); 
		DATASOURCDLL_API std::vector<std::vector<uint32_t> > get_scom(); 
		DATASOURCDLL_API std::vector<uint32_t> get_scom(uint32_t); 
		DATASOURCDLL_API std::string get_filename(); 
		DATASOURCDLL_API FileType get_filetype(); 
		DATASOURCDLL_API std::string get_path();

		DATASOURCDLL_API uint32_t get_max_nodes();
		DATASOURCDLL_API uint32_t get_max_edges();
		DATASOURCDLL_API uint32_t get_total_nodes();
		DATASOURCDLL_API uint32_t get_total_edges();
		DATASOURCDLL_API uint32_t get_avg_nodes();
		DATASOURCDLL_API uint32_t get_avg_edges();

		DATASOURCDLL_API uint32_t get_total_communities();
		DATASOURCDLL_API uint32_t get_max_communities();
		DATASOURCDLL_API uint32_t get_avg_communities();

		// data
		DATASOURCDLL_API std::vector<nodes_t> get_nodes();
		DATASOURCDLL_API std::vector<pairs_t> get_edges();
		DATASOURCDLL_API nodes_t get_nodes(uint32_t);
		DATASOURCDLL_API pairs_t get_edges(uint32_t);
		DATASOURCDLL_API nodes_t Source::get_nodes(uint32_t index, uint32_t from, uint32_t to);
		DATASOURCDLL_API pairs_t Source::get_edges(uint32_t index, uint32_t from, uint32_t to);
		DATASOURCDLL_API std::vector<snapshot_t> get_snaps();
		DATASOURCDLL_API snapshot_t get_snap(uint32_t);
		DATASOURCDLL_API community_t get_community(uint32_t, uint32_t, uint32_t from, uint32_t to);
		DATASOURCDLL_API community_t get_community(uint32_t, uint32_t);

		// display
		DATASOURCDLL_API void display();
		DATASOURCDLL_API void display_properties();

		// draw

	};
}