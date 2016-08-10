cmake_minimum_required (VERSION 2.8.11)
project (communityEvolution)

cmake_policy(SET CMP0023 OLD)

find_package(CUDA QUIET REQUIRED)

set(CUDA_SEPARABLE_COMPILATION ON)
set(CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS} -arch=sm_20 -std=c++11)

if (${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
include_directories(${CMAKE_SOURCE_DIR}/lib/dirent/include)
add_definitions(-DARCH_WINDOWS)
endif(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")

include_directories(${CMAKE_SOURCE_DIR}/lib/cereal)

add_definitions(-D_MWAITXINTRIN_H_INCLUDED -std=c++11)

add_subdirectory (communityEvolutionDll)
add_subdirectory (communityEvolutionInterface)
add_subdirectory (bachelorInterface)
