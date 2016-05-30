#pragma once

#ifdef ARCH_WINDOWS
#ifdef	DEVICESTORAGESERILIZATIONDLL_EXPORTS
#define DEVICESTORAGESERILIZATIONDLL_API __declspec(dllexport) 
#else
#define DEVICESTORAGESERILIZATIONDLL_API __declspec(dllimport) 
#endif
#else
#define DEVICESTORAGESERILIZATIONDLL_API __attribute__ ((visibility ("default")))
#endif

DEVICESTORAGESERILIZATIONDLL_API bool serialize(T_DV<pair_t>& d_pair, std::string type, uint32_t offset, uint32_t allocate, uint32_t id);

DEVICESTORAGESERILIZATIONDLL_API bool from_device_store(T_DV<pair_t>& d_val, std::string type, uint32_t offset, uint32_t allocate, uint32_t id);
DEVICESTORAGESERILIZATIONDLL_API bool to_device_load(T_DV<pair_t>& d_val, std::string type, uint32_t id, bool clean);

DEVICESTORAGESERILIZATIONDLL_API bool from_device_store(T_DV<uint32_t>& d_val, std::string type, uint32_t offset, uint32_t allocate, uint32_t id);
DEVICESTORAGESERILIZATIONDLL_API bool to_device_load(T_DV<uint32_t>& d_val, std::string type, uint32_t id, bool clean);

namespace comevohost{
	DEVICESTORAGESERILIZATIONDLL_API bool from_host_store(T_HV<pair_t>& d_val, std::string type, uint32_t offset, uint32_t allocate, uint32_t id);
	DEVICESTORAGESERILIZATIONDLL_API bool to_host_load(T_HV<pair_t>& d_val, std::string type, uint32_t id, bool clean);

	DEVICESTORAGESERILIZATIONDLL_API bool from_host_store(T_HV<uint32_t>& d_val, std::string type, uint32_t offset, uint32_t allocate, uint32_t id);
	DEVICESTORAGESERILIZATIONDLL_API bool to_host_load(T_HV<uint32_t>& d_val, std::string type, uint32_t id, bool clean);
}

