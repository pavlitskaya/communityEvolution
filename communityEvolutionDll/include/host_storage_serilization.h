#pragma once

#ifdef HOSTSTORAGESERILIZATIONDLL_EXPORTS
#define HOSTSTORAGESERILIZATIONDLL_API __declspec(dllexport) 
#else
#define HOSTSTORAGESERILIZATIONDLL_API __declspec(dllimport) 
#endif

namespace comevo{

	class Serilization
	{

		//map with sizes
	public:
		HOSTSTORAGESERILIZATIONDLL_API static bool Serilization::store_compress(std::vector<uint32_t>& vec, std::string type, uint32_t id);
		HOSTSTORAGESERILIZATIONDLL_API static bool Serilization::load_compress(std::vector<uint32_t>& vec, std::string type, uint32_t id, bool clean);
		HOSTSTORAGESERILIZATIONDLL_API static bool Serilization::store(T_HV<uint32_t>& vec, std::string type, uint32_t id);
		HOSTSTORAGESERILIZATIONDLL_API static bool Serilization::load(T_HV<uint32_t>& vec, std::string type, uint32_t id, bool clean);
		HOSTSTORAGESERILIZATIONDLL_API static bool Serilization::store(std::vector<uint32_t>& vec, std::string type, uint32_t id);
		HOSTSTORAGESERILIZATIONDLL_API static bool Serilization::load(std::vector<uint32_t>& vec, std::string type, uint32_t id, bool clean);
		HOSTSTORAGESERILIZATIONDLL_API static bool Serilization::store(T_HV<pair_t>& h_vec, std::string type, uint32_t id);
		HOSTSTORAGESERILIZATIONDLL_API static bool Serilization::load(T_HV<pair_t>& h_vec, std::string type, uint32_t id, bool clean);
		HOSTSTORAGESERILIZATIONDLL_API static bool Serilization::store(std::vector<pair_t>& h_vec, std::string type, uint32_t id);
		HOSTSTORAGESERILIZATIONDLL_API static bool Serilization::load(std::vector<pair_t>& h_vec, std::string type, uint32_t id, bool clean);
		HOSTSTORAGESERILIZATIONDLL_API static void Serilization::load_pairs(std::string filename, uint32_t index, uint32_t from, uint32_t to, std::vector<uint32_t>& sourceSize, pairs_t& pairs);
		HOSTSTORAGESERILIZATIONDLL_API static void Serilization::load_pairs(std::string filename, uint32_t index, std::vector<uint32_t>& sourceSize, pairs_t& pairs);
		static void Serilization::load_pairs(std::string filename, std::vector<uint32_t>& sourceSize, std::vector<std::vector<pair_t> >& target);
		static void Serilization::load_snap(std::string filename, uint32_t index, std::vector < std::vector<uint32_t> >& sourceSize, snapshot_t& snap);
		static void Serilization::load_snaps(std::string filename, std::vector < std::vector<uint32_t> >& sourceSize, std::vector<snapshot_t>& snaps);
		static bool Serilization::store(uint32_t* item, uint32_t size, std::string type, uint32_t id);
		static bool Serilization::load(uint32_t* &item, uint32_t& size, std::string type, uint32_t id, bool clean);
		static bool Serilization::store(pair_t* item, uint32_t size, std::string type, uint32_t id);
		static bool Serilization::load(pair_t* &item, uint32_t& size, std::string type, uint32_t id, bool clean);
		static void Serilization::load_com(std::string filename, uint32_t index_snap, uint32_t index_com, std::vector<std::vector<uint32_t> >& sourceSize, community_t& com);
		static void Serilization::load_com(std::string filename, uint32_t index_snap, uint32_t index_com, uint32_t from, uint32_t to, std::vector<std::vector<uint32_t> >& sourceSize, community_t& com);
		//static bool Serilization::process_file(std::string filename, FileType fileType, U32 &n, U32 &m, U32 &n_oS);
	private:
		Serilization() {};
		static void Serilization::load_snap(std::ifstream& ifs, std::vector < uint32_t >& sourceSize, snapshot_t& snap);
		static void Serilization::load_pairs(std::ifstream& ifs, uint32_t sourceSize, pairs_t& pairs);
		static void Serilization::load_com(std::ifstream& ifs, uint32_t sourceSize, community_t& com);

	};

}