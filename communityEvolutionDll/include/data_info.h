#pragma once

#ifdef ARCH_WINDOWS
#ifdef DATAINFODLL_EXPORTS
#define DATAINFODLL_API __declspec(dllexport) 
#else
#define DATAINFODLL_API __declspec(dllimport) 
#endif
#else
#define DATAINFODLL_API __attribute__ ((visibility ("default")))
#endif

/* Returns the amount of free and total memory on the current GPU device.
*/
DATAINFODLL_API pair_t get_device_memory();

/* Displays the amount of free and total memory on the current GPU device.
*/
DATAINFODLL_API void display_device_memory();
