#pragma once

#ifdef MATRIXOPERATIONSDLL
#define MATRIXOPERATIONSDLL_API __declspec(dllexport) 
#else
#define MATRIXOPERATIONSDLL_API __declspec(dllimport) 
#endif

MATRIXOPERATIONSDLL_API bool matrices_create(uint32_t rowSize, uint32_t amount, uint32_t value, std::vector<T_HV<uint32_t> >& matrices);

MATRIXOPERATIONSDLL_API bool create_adjacency();