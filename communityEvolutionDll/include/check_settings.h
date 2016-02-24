#pragma once

#ifdef CHECKSETTINGSDLL_EXPORTS
#define CHECKSETTINGSDLL_API __declspec(dllexport) 
#else
#define CHECKSETTINGSDLL_API __declspec(dllimport) 
#endif

namespace SpaceAny
{
	struct Any{
	private:
		uint32_t n, m;

	public:
		CHECKSETTINGSDLL_API Any();
		CHECKSETTINGSDLL_API ~Any();

		CHECKSETTINGSDLL_API bool set_n(uint32_t n);
		CHECKSETTINGSDLL_API bool set_m(uint32_t m);
		CHECKSETTINGSDLL_API uint32_t get_n();
		CHECKSETTINGSDLL_API uint32_t get_m();
		CHECKSETTINGSDLL_API std::vector<uint32_t> get_vec();

	};
}