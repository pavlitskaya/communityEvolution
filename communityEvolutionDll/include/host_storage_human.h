#pragma once
#include "../include/general_defines.h"
#include <dirent.h>

#ifdef ARCH_WINDOWS
#ifdef HOSTSTORAGEHUMANDLL_EXPORTS
#define HOSTSTORAGEHUMANDLL_API __declspec(dllexport) 
#else
#define HOSTSTORAGEHUMANDLL_API __declspec(dllimport) 
#endif
#else
#define HOSTSTORAGEHUMANDLL_API __attribute__ ((visibility ("default")))
#endif


namespace comevo{

	/* Finds file in storage. Returns true if file exists. Sets path to the correc tpath if file was found.
	*/
	HOSTSTORAGEHUMANDLL_API bool find_file(std::string filename, std::string &path);

	/* Gathers all files in storage.
	*/
	HOSTSTORAGEHUMANDLL_API std::vector<std::pair<dirent, std::string> > get_files(FileType folder);

	/* Display all files in storage.
	*/
	HOSTSTORAGEHUMANDLL_API void display_files(FileType folder);

	/* Gets a specific file. Will pick the x (file_id) file in the folder. Returns false if nothing was found.
	*/
	HOSTSTORAGEHUMANDLL_API bool get_file(FileType folder, uint32_t file_id, dirent& file);

	/* Reads T from a file. needs as delimiter
	*/
	template <typename T> void read_file_count(std::string filename, std::vector<uint32_t>& counts, T delimiter);

	template <typename T> void read_file(std::string filename, std::vector<std::vector<T> >& vec_of_vec, T delimiter);
	
	bool store_pairs(std::ofstream& ofs, std::vector<pairs_t>& vec_pairs, Source_Props& properties);
	bool store_snaps(std::ofstream& ofs, std::vector<snapshot_t>& snaps, Source_Props& properties);
	bool store_pairs_direct(std::ofstream& ofs, std::vector<pairs_t>& vecPairs, Source_Props& properties);
	bool store_snaps_direct(std::ofstream& ofs, std::vector<snapshot_t>& vecSnaps, Source_Props& properties);
	bool store_file(std::string& filenameSource, std::string& filenameTarget, FileType fileType, bool binary, std::vector<pairs_t>& vec_pairs, std::vector<snapshot_t>& snaps, Source_Props& properties);

	bool convert_pairs(Source_Props& properties, std::ifstream& readfile, std::ofstream& pathTarget);

	bool convert_file(Source_Props& properties, std::string filenameSource, FileType fileType, std::string filenameTarget, bool binarySource, bool binaryTarget);

	bool convert_raw(Source_Props& properties, std::string filenameSource, FileType fileType, std::string filenameTarget, RawType rawType, std::vector<uint32_t>& parameter);

	bool convert_csv(Source_Props& properties, std::ifstream& readfile, std::ofstream& writefile, std::vector<uint32_t>& parameter);

	std::vector<pair_t> create_snapshot(std::vector<uint32_t>& threads, std::vector<uint32_t>& users);

	bool save_to_file(std::string filename, std::vector<bool>& _dissolve, std::vector<bool>& _form, std::vector<tuple_triple>& _merge, std::vector<tuple_triple>& _split, std::vector<pair_ti>& _continue, uint32_t _appear, uint32_t _disappear, std::vector<pair_ti>& _join, std::vector<pair_ti>& _leve);

}
