#include "../stdafx.h"
#include <data_source.h>
#include <data_info.h>

#include <omp.h>
#include <vector>
#include <string>

#include "ResultItem.h"

//#define GPU true

void createFilenames(std::vector<std::string> &result) {
    result.push_back(std::string("1-1-2015_pairs.json"));
    result.push_back(std::string("2-1-2015_pairs.json"));
    result.push_back(std::string("3-1-2015_pairs.json"));
    result.push_back(std::string("4-1-2015_pairs.json"));
    result.push_back(std::string("5-1-2015_pairs.json"));
    result.push_back(std::string("6-1-2015_pairs.json"));
    result.push_back(std::string("7-1-2015_pairs.json"));
    result.push_back(std::string("8-1-2015_pairs.json"));
    result.push_back(std::string("9-1-2015_pairs.json"));
    result.push_back(std::string("10-1-2015_pairs.json"));
    result.push_back(std::string("11-1-2015_pairs.json"));
    result.push_back(std::string("12-1-2015_pairs.json"));
    result.push_back(std::string("13-1-2015_pairs.json"));
    result.push_back(std::string("14-1-2015_pairs.json"));
    result.push_back(std::string("15-1-2015_pairs.json"));
    result.push_back(std::string("16-1-2015_pairs.json"));
    result.push_back(std::string("17-1-2015_pairs.json"));
    result.push_back(std::string("18-1-2015_pairs.json"));
    result.push_back(std::string("19-1-2015_pairs.json"));
    result.push_back(std::string("20-1-2015_pairs.json"));
    result.push_back(std::string("21-1-2015_pairs.json"));
    result.push_back(std::string("22-1-2015_pairs.json"));
    result.push_back(std::string("23-1-2015_pairs.json"));
    result.push_back(std::string("24-1-2015_pairs.json"));
    result.push_back(std::string("25-1-2015_pairs.json"));
    result.push_back(std::string("26-1-2015_pairs.json"));
    result.push_back(std::string("27-1-2015_pairs.json"));
    result.push_back(std::string("28-1-2015_pairs.json"));
    result.push_back(std::string("29-1-2015_pairs.json"));
    result.push_back(std::string("30-1-2015_pairs.json"));
    result.push_back(std::string("31-1-2015_pairs.json"));
    result.push_back(std::string("1-2-2015_pairs.json"));
    result.push_back(std::string("2-2-2015_pairs.json"));
    result.push_back(std::string("3-2-2015_pairs.json"));
    result.push_back(std::string("4-2-2015_pairs.json"));
    result.push_back(std::string("5-2-2015_pairs.json"));
    result.push_back(std::string("6-2-2015_pairs.json"));
    result.push_back(std::string("7-2-2015_pairs.json"));
    result.push_back(std::string("8-2-2015_pairs.json"));
    result.push_back(std::string("9-2-2015_pairs.json"));
    result.push_back(std::string("10-2-2015_pairs.json"));
    result.push_back(std::string("11-2-2015_pairs.json"));
    result.push_back(std::string("12-2-2015_pairs.json"));
    result.push_back(std::string("13-2-2015_pairs.json"));
    result.push_back(std::string("14-2-2015_pairs.json"));
    result.push_back(std::string("15-2-2015_pairs.json"));
    result.push_back(std::string("16-2-2015_pairs.json"));
    result.push_back(std::string("17-2-2015_pairs.json"));
    result.push_back(std::string("18-2-2015_pairs.json"));
    result.push_back(std::string("19-2-2015_pairs.json"));
    result.push_back(std::string("20-2-2015_pairs.json"));
    result.push_back(std::string("21-2-2015_pairs.json"));
    result.push_back(std::string("22-2-2015_pairs.json"));
    result.push_back(std::string("23-2-2015_pairs.json"));
    result.push_back(std::string("24-2-2015_pairs.json"));
    result.push_back(std::string("25-2-2015_pairs.json"));
    result.push_back(std::string("26-2-2015_pairs.json"));
    result.push_back(std::string("27-2-2015_pairs.json"));
    result.push_back(std::string("28-2-2015_pairs.json"));
    result.push_back(std::string("1-3-2015_pairs.json"));
    result.push_back(std::string("2-3-2015_pairs.json"));
    result.push_back(std::string("3-3-2015_pairs.json"));
    result.push_back(std::string("4-3-2015_pairs.json"));
    result.push_back(std::string("5-3-2015_pairs.json"));
    result.push_back(std::string("6-3-2015_pairs.json"));
    result.push_back(std::string("7-3-2015_pairs.json"));
    result.push_back(std::string("8-3-2015_pairs.json"));
    result.push_back(std::string("9-3-2015_pairs.json"));
    result.push_back(std::string("10-3-2015_pairs.json"));
    result.push_back(std::string("11-3-2015_pairs.json"));
    result.push_back(std::string("12-3-2015_pairs.json"));
    result.push_back(std::string("13-3-2015_pairs.json"));
    result.push_back(std::string("14-3-2015_pairs.json"));
    result.push_back(std::string("15-3-2015_pairs.json"));
    result.push_back(std::string("16-3-2015_pairs.json"));
    result.push_back(std::string("17-3-2015_pairs.json"));
    result.push_back(std::string("18-3-2015_pairs.json"));
    result.push_back(std::string("19-3-2015_pairs.json"));
    result.push_back(std::string("20-3-2015_pairs.json"));
    result.push_back(std::string("21-3-2015_pairs.json"));
    result.push_back(std::string("22-3-2015_pairs.json"));
    result.push_back(std::string("23-3-2015_pairs.json"));
    result.push_back(std::string("24-3-2015_pairs.json"));
    result.push_back(std::string("25-3-2015_pairs.json"));
    result.push_back(std::string("26-3-2015_pairs.json"));
    result.push_back(std::string("27-3-2015_pairs.json"));
    result.push_back(std::string("28-3-2015_pairs.json"));
    result.push_back(std::string("29-3-2015_pairs.json"));
    result.push_back(std::string("30-3-2015_pairs.json"));
    result.push_back(std::string("31-3-2015_pairs.json"));
    result.push_back(std::string("1-4-2015_pairs.json"));
    result.push_back(std::string("2-4-2015_pairs.json"));
    result.push_back(std::string("3-4-2015_pairs.json"));
    result.push_back(std::string("4-4-2015_pairs.json"));
    result.push_back(std::string("5-4-2015_pairs.json"));
    result.push_back(std::string("6-4-2015_pairs.json"));
    result.push_back(std::string("7-4-2015_pairs.json"));
    result.push_back(std::string("8-4-2015_pairs.json"));
    result.push_back(std::string("9-4-2015_pairs.json"));
    result.push_back(std::string("10-4-2015_pairs.json"));
    result.push_back(std::string("11-4-2015_pairs.json"));
    result.push_back(std::string("12-4-2015_pairs.json"));
    result.push_back(std::string("13-4-2015_pairs.json"));
    result.push_back(std::string("14-4-2015_pairs.json"));
    result.push_back(std::string("15-4-2015_pairs.json"));
    result.push_back(std::string("16-4-2015_pairs.json"));
    result.push_back(std::string("17-4-2015_pairs.json"));
    result.push_back(std::string("18-4-2015_pairs.json"));
    result.push_back(std::string("19-4-2015_pairs.json"));
    result.push_back(std::string("20-4-2015_pairs.json"));
    result.push_back(std::string("21-4-2015_pairs.json"));
    result.push_back(std::string("22-4-2015_pairs.json"));
    result.push_back(std::string("23-4-2015_pairs.json"));
    result.push_back(std::string("24-4-2015_pairs.json"));
    result.push_back(std::string("25-4-2015_pairs.json"));
    result.push_back(std::string("26-4-2015_pairs.json"));
    result.push_back(std::string("27-4-2015_pairs.json"));
    result.push_back(std::string("28-4-2015_pairs.json"));
    result.push_back(std::string("29-4-2015_pairs.json"));
    result.push_back(std::string("30-4-2015_pairs.json"));
    result.push_back(std::string("1-5-2015_pairs.json"));
    result.push_back(std::string("2-5-2015_pairs.json"));
    result.push_back(std::string("3-5-2015_pairs.json"));
    result.push_back(std::string("4-5-2015_pairs.json"));
    result.push_back(std::string("5-5-2015_pairs.json"));
    result.push_back(std::string("6-5-2015_pairs.json"));
    result.push_back(std::string("7-5-2015_pairs.json"));
    result.push_back(std::string("8-5-2015_pairs.json"));
    result.push_back(std::string("9-5-2015_pairs.json"));
    result.push_back(std::string("10-5-2015_pairs.json"));
    result.push_back(std::string("11-5-2015_pairs.json"));
    result.push_back(std::string("12-5-2015_pairs.json"));
    result.push_back(std::string("13-5-2015_pairs.json"));
    result.push_back(std::string("14-5-2015_pairs.json"));
    result.push_back(std::string("15-5-2015_pairs.json"));
    result.push_back(std::string("16-5-2015_pairs.json"));
    result.push_back(std::string("17-5-2015_pairs.json"));
    result.push_back(std::string("18-5-2015_pairs.json"));
    result.push_back(std::string("19-5-2015_pairs.json"));
    result.push_back(std::string("20-5-2015_pairs.json"));
    result.push_back(std::string("21-5-2015_pairs.json"));
    result.push_back(std::string("22-5-2015_pairs.json"));
    result.push_back(std::string("23-5-2015_pairs.json"));
    result.push_back(std::string("24-5-2015_pairs.json"));
    result.push_back(std::string("25-5-2015_pairs.json"));
    result.push_back(std::string("26-5-2015_pairs.json"));
    result.push_back(std::string("27-5-2015_pairs.json"));
    result.push_back(std::string("28-5-2015_pairs.json"));
    result.push_back(std::string("29-5-2015_pairs.json"));
    result.push_back(std::string("30-5-2015_pairs.json"));
    result.push_back(std::string("31-5-2015_pairs.json"));
    result.push_back(std::string("1-6-2015_pairs.json"));
    result.push_back(std::string("2-6-2015_pairs.json"));
    result.push_back(std::string("3-6-2015_pairs.json"));
    result.push_back(std::string("4-6-2015_pairs.json"));
    result.push_back(std::string("5-6-2015_pairs.json"));
    result.push_back(std::string("6-6-2015_pairs.json"));
    result.push_back(std::string("7-6-2015_pairs.json"));
    result.push_back(std::string("8-6-2015_pairs.json"));
    result.push_back(std::string("9-6-2015_pairs.json"));
    result.push_back(std::string("10-6-2015_pairs.json"));
    result.push_back(std::string("11-6-2015_pairs.json"));
    result.push_back(std::string("12-6-2015_pairs.json"));
    result.push_back(std::string("13-6-2015_pairs.json"));
    result.push_back(std::string("14-6-2015_pairs.json"));
    result.push_back(std::string("15-6-2015_pairs.json"));
    result.push_back(std::string("16-6-2015_pairs.json"));
    result.push_back(std::string("17-6-2015_pairs.json"));
    result.push_back(std::string("18-6-2015_pairs.json"));
    result.push_back(std::string("19-6-2015_pairs.json"));
    result.push_back(std::string("20-6-2015_pairs.json"));
    result.push_back(std::string("21-6-2015_pairs.json"));
    result.push_back(std::string("22-6-2015_pairs.json"));
    result.push_back(std::string("23-6-2015_pairs.json"));
    result.push_back(std::string("24-6-2015_pairs.json"));
    result.push_back(std::string("25-6-2015_pairs.json"));
    result.push_back(std::string("26-6-2015_pairs.json"));
    result.push_back(std::string("27-6-2015_pairs.json"));
    result.push_back(std::string("28-6-2015_pairs.json"));
    result.push_back(std::string("29-6-2015_pairs.json"));
    result.push_back(std::string("30-6-2015_pairs.json"));
    result.push_back(std::string("1-7-2015_pairs.json"));
    result.push_back(std::string("2-7-2015_pairs.json"));
    result.push_back(std::string("3-7-2015_pairs.json"));
    result.push_back(std::string("4-7-2015_pairs.json"));
    result.push_back(std::string("5-7-2015_pairs.json"));
    result.push_back(std::string("6-7-2015_pairs.json"));
    result.push_back(std::string("7-7-2015_pairs.json"));
    result.push_back(std::string("8-7-2015_pairs.json"));
    result.push_back(std::string("9-7-2015_pairs.json"));
    result.push_back(std::string("10-7-2015_pairs.json"));
    result.push_back(std::string("11-7-2015_pairs.json"));
    result.push_back(std::string("12-7-2015_pairs.json"));
    result.push_back(std::string("13-7-2015_pairs.json"));
    result.push_back(std::string("14-7-2015_pairs.json"));
    result.push_back(std::string("15-7-2015_pairs.json"));
    result.push_back(std::string("16-7-2015_pairs.json"));
    result.push_back(std::string("17-7-2015_pairs.json"));
    result.push_back(std::string("18-7-2015_pairs.json"));
    result.push_back(std::string("19-7-2015_pairs.json"));
    result.push_back(std::string("20-7-2015_pairs.json"));
    result.push_back(std::string("21-7-2015_pairs.json"));
    result.push_back(std::string("22-7-2015_pairs.json"));
    result.push_back(std::string("23-7-2015_pairs.json"));
    result.push_back(std::string("24-7-2015_pairs.json"));
    result.push_back(std::string("25-7-2015_pairs.json"));
    result.push_back(std::string("26-7-2015_pairs.json"));
    result.push_back(std::string("27-7-2015_pairs.json"));
    result.push_back(std::string("28-7-2015_pairs.json"));
    result.push_back(std::string("29-7-2015_pairs.json"));
    result.push_back(std::string("30-7-2015_pairs.json"));
    result.push_back(std::string("31-7-2015_pairs.json"));
    result.push_back(std::string("1-8-2015_pairs.json"));
    result.push_back(std::string("2-8-2015_pairs.json"));
    result.push_back(std::string("3-8-2015_pairs.json"));
    result.push_back(std::string("4-8-2015_pairs.json"));
    result.push_back(std::string("5-8-2015_pairs.json"));
    result.push_back(std::string("6-8-2015_pairs.json"));
    result.push_back(std::string("7-8-2015_pairs.json"));
    result.push_back(std::string("8-8-2015_pairs.json"));
    result.push_back(std::string("9-8-2015_pairs.json"));
    result.push_back(std::string("10-8-2015_pairs.json"));
    result.push_back(std::string("11-8-2015_pairs.json"));
    result.push_back(std::string("12-8-2015_pairs.json"));
    result.push_back(std::string("13-8-2015_pairs.json"));
    result.push_back(std::string("14-8-2015_pairs.json"));
    result.push_back(std::string("15-8-2015_pairs.json"));
    result.push_back(std::string("16-8-2015_pairs.json"));
    result.push_back(std::string("17-8-2015_pairs.json"));
    result.push_back(std::string("18-8-2015_pairs.json"));
    result.push_back(std::string("19-8-2015_pairs.json"));
    result.push_back(std::string("20-8-2015_pairs.json"));
    result.push_back(std::string("21-8-2015_pairs.json"));
    result.push_back(std::string("22-8-2015_pairs.json"));
    result.push_back(std::string("23-8-2015_pairs.json"));
    result.push_back(std::string("24-8-2015_pairs.json"));
    result.push_back(std::string("25-8-2015_pairs.json"));
    result.push_back(std::string("26-8-2015_pairs.json"));
    result.push_back(std::string("27-8-2015_pairs.json"));
    result.push_back(std::string("28-8-2015_pairs.json"));
    result.push_back(std::string("29-8-2015_pairs.json"));
    result.push_back(std::string("30-8-2015_pairs.json"));
    result.push_back(std::string("31-8-2015_pairs.json"));
    result.push_back(std::string("1-9-2015_pairs.json"));
    result.push_back(std::string("2-9-2015_pairs.json"));
    result.push_back(std::string("3-9-2015_pairs.json"));
    result.push_back(std::string("4-9-2015_pairs.json"));
    result.push_back(std::string("5-9-2015_pairs.json"));
    result.push_back(std::string("6-9-2015_pairs.json"));
    result.push_back(std::string("7-9-2015_pairs.json"));
    result.push_back(std::string("8-9-2015_pairs.json"));
    result.push_back(std::string("9-9-2015_pairs.json"));
    result.push_back(std::string("10-9-2015_pairs.json"));
    result.push_back(std::string("11-9-2015_pairs.json"));
    result.push_back(std::string("12-9-2015_pairs.json"));
    result.push_back(std::string("13-9-2015_pairs.json"));
    result.push_back(std::string("14-9-2015_pairs.json"));
    result.push_back(std::string("15-9-2015_pairs.json"));
    result.push_back(std::string("16-9-2015_pairs.json"));
    result.push_back(std::string("17-9-2015_pairs.json"));
    result.push_back(std::string("18-9-2015_pairs.json"));
    result.push_back(std::string("19-9-2015_pairs.json"));
    result.push_back(std::string("20-9-2015_pairs.json"));
    result.push_back(std::string("21-9-2015_pairs.json"));
    result.push_back(std::string("22-9-2015_pairs.json"));
    result.push_back(std::string("23-9-2015_pairs.json"));
    result.push_back(std::string("24-9-2015_pairs.json"));
    result.push_back(std::string("25-9-2015_pairs.json"));
    result.push_back(std::string("26-9-2015_pairs.json"));
    result.push_back(std::string("27-9-2015_pairs.json"));
    result.push_back(std::string("28-9-2015_pairs.json"));
    result.push_back(std::string("29-9-2015_pairs.json"));
    result.push_back(std::string("30-9-2015_pairs.json"));
    result.push_back(std::string("1-10-2015_pairs.json"));
    result.push_back(std::string("2-10-2015_pairs.json"));
    result.push_back(std::string("3-10-2015_pairs.json"));
    result.push_back(std::string("4-10-2015_pairs.json"));
    result.push_back(std::string("5-10-2015_pairs.json"));
    result.push_back(std::string("6-10-2015_pairs.json"));
    result.push_back(std::string("7-10-2015_pairs.json"));
    result.push_back(std::string("8-10-2015_pairs.json"));
    result.push_back(std::string("9-10-2015_pairs.json"));
    result.push_back(std::string("10-10-2015_pairs.json"));
    result.push_back(std::string("11-10-2015_pairs.json"));
    result.push_back(std::string("12-10-2015_pairs.json"));
    result.push_back(std::string("13-10-2015_pairs.json"));
    result.push_back(std::string("14-10-2015_pairs.json"));
    result.push_back(std::string("15-10-2015_pairs.json"));
    result.push_back(std::string("16-10-2015_pairs.json"));
    result.push_back(std::string("17-10-2015_pairs.json"));
    result.push_back(std::string("18-10-2015_pairs.json"));
    result.push_back(std::string("19-10-2015_pairs.json"));
    result.push_back(std::string("20-10-2015_pairs.json"));
    result.push_back(std::string("21-10-2015_pairs.json"));
    result.push_back(std::string("22-10-2015_pairs.json"));
    result.push_back(std::string("23-10-2015_pairs.json"));
    result.push_back(std::string("24-10-2015_pairs.json"));
    result.push_back(std::string("25-10-2015_pairs.json"));
    result.push_back(std::string("26-10-2015_pairs.json"));
    result.push_back(std::string("27-10-2015_pairs.json"));
    result.push_back(std::string("28-10-2015_pairs.json"));
    result.push_back(std::string("29-10-2015_pairs.json"));
    result.push_back(std::string("30-10-2015_pairs.json"));
    result.push_back(std::string("31-10-2015_pairs.json"));
    result.push_back(std::string("1-11-2015_pairs.json"));
    result.push_back(std::string("2-11-2015_pairs.json"));
    result.push_back(std::string("3-11-2015_pairs.json"));
    result.push_back(std::string("4-11-2015_pairs.json"));
    result.push_back(std::string("5-11-2015_pairs.json"));
    result.push_back(std::string("6-11-2015_pairs.json"));
    result.push_back(std::string("7-11-2015_pairs.json"));
    result.push_back(std::string("8-11-2015_pairs.json"));
    result.push_back(std::string("9-11-2015_pairs.json"));
    result.push_back(std::string("10-11-2015_pairs.json"));
    result.push_back(std::string("11-11-2015_pairs.json"));
    result.push_back(std::string("12-11-2015_pairs.json"));
    result.push_back(std::string("13-11-2015_pairs.json"));
    result.push_back(std::string("14-11-2015_pairs.json"));
    result.push_back(std::string("15-11-2015_pairs.json"));
    result.push_back(std::string("16-11-2015_pairs.json"));
    result.push_back(std::string("17-11-2015_pairs.json"));
    result.push_back(std::string("18-11-2015_pairs.json"));
    result.push_back(std::string("19-11-2015_pairs.json"));
    result.push_back(std::string("20-11-2015_pairs.json"));
    result.push_back(std::string("21-11-2015_pairs.json"));
    result.push_back(std::string("22-11-2015_pairs.json"));
    result.push_back(std::string("23-11-2015_pairs.json"));
    result.push_back(std::string("24-11-2015_pairs.json"));
    result.push_back(std::string("25-11-2015_pairs.json"));
    result.push_back(std::string("26-11-2015_pairs.json"));
    result.push_back(std::string("27-11-2015_pairs.json"));
    result.push_back(std::string("28-11-2015_pairs.json"));
    result.push_back(std::string("29-11-2015_pairs.json"));
    result.push_back(std::string("30-11-2015_pairs.json"));
    result.push_back(std::string("1-12-2015_pairs.json"));
    result.push_back(std::string("2-12-2015_pairs.json"));
    result.push_back(std::string("3-12-2015_pairs.json"));
    result.push_back(std::string("4-12-2015_pairs.json"));
    result.push_back(std::string("5-12-2015_pairs.json"));
    result.push_back(std::string("6-12-2015_pairs.json"));
    result.push_back(std::string("7-12-2015_pairs.json"));
    result.push_back(std::string("8-12-2015_pairs.json"));
    result.push_back(std::string("9-12-2015_pairs.json"));
    result.push_back(std::string("10-12-2015_pairs.json"));
    result.push_back(std::string("11-12-2015_pairs.json"));
    result.push_back(std::string("12-12-2015_pairs.json"));
    result.push_back(std::string("13-12-2015_pairs.json"));
    result.push_back(std::string("14-12-2015_pairs.json"));
    result.push_back(std::string("15-12-2015_pairs.json"));
    result.push_back(std::string("16-12-2015_pairs.json"));
    result.push_back(std::string("17-12-2015_pairs.json"));
    result.push_back(std::string("18-12-2015_pairs.json"));
    result.push_back(std::string("19-12-2015_pairs.json"));
    result.push_back(std::string("20-12-2015_pairs.json"));
    result.push_back(std::string("21-12-2015_pairs.json"));
    result.push_back(std::string("22-12-2015_pairs.json"));
    result.push_back(std::string("23-12-2015_pairs.json"));
    result.push_back(std::string("24-12-2015_pairs.json"));
    result.push_back(std::string("25-12-2015_pairs.json"));
    result.push_back(std::string("26-12-2015_pairs.json"));
    result.push_back(std::string("27-12-2015_pairs.json"));
    result.push_back(std::string("28-12-2015_pairs.json"));
    result.push_back(std::string("29-12-2015_pairs.json"));
    result.push_back(std::string("30-12-2015_pairs.json"));
    result.push_back(std::string("31-12-2015_pairs.json"));
}

int main()
{
    printf("\nBachelor Evolution\n\n");
	if (DISPLAY_MEMORY)display_device_memory();



    std::vector<std::string> filenames;
    createFilenames(filenames);

    ResultItem result;

#ifdef GPU
    for (size_t i=0; i<filenames.size(); i++) {
#else
    #pragma omp parallel for shared(result)
    for (size_t i=0; i<filenames.size(); i++) {
#endif
        std::string file = filenames[i];
        std::cout << "=== FILENAME: " << file << " ===" << std::endl;
        std::cout << "OpenMP threads: " << omp_get_thread_num() << std::endl;
        display_device_memory();

        comevo::Source source_raw;
        comevo::Source source_snaps;
        std::vector<uint32_t> parameter;
        parameter.push_back(1);
        parameter.push_back(0);
        source_raw.set_source(file, RAW, EDGES, parameter);

//        ResultItem result(file);
//        result.put_value("total_nodes", source_raw.get_total_nodes());
//        result.put_value("snapshot_with_max_nodes", source_raw.get_max_nodes());
//        result.put_value("average_nodes", source_raw.get_avg_nodes());
//        result.put_value("total_edges", source_raw.get_total_edges());
//        result.put_value("snapshot_with_max_edges", source_raw.get_max_edges());
//        result.put_value("average_edges", source_raw.get_avg_edges());

        uint32_t iterations = 3; // TODO: remove magic

#ifdef GPU
            Timing::create_time(6);
            Timing::start_time(6);
            Timing::start_time_cpu(6);
            Threshold threshold = Threshold(2, 3);
            algorithm_propinquity(source_raw, source_snaps, 0, 0, threshold, 0, iterations, 0);

            Timing::stop_time(6);
            Timing::stop_time_cpu(6);
#else
            Timing::start_time_cpu(7);
            comevohost::Threshold host_threshold = comevohost::Threshold(2, 3);
            comevohost::algorithm_propinquity(source_raw, source_snaps, 0, 0, host_threshold, 0, iterations, 0);

            Timing::stop_time_cpu(7);
#endif
//        result.put_value("snaps_count", source_snaps.get_m().size());
//        result.put_value("communities_count", source_snaps.get_total_communities());
//        result.put_value("max_communities", source_snaps.get_max_communities());
//        result.put_value("average_communities_count", source_snaps.get_avg_communities());

        std::unordered_map<std::string, std::vector<snapshot_t>> map;
        map.insert(std::pair<std::string, std::vector<snapshot_t>>(std::string(file), source_snaps.get_snaps()));
        result.add_snapshots(map);

        std::cout << "----------" << std::endl;

        //source_snaps.display();
    }

    std::ofstream outputFile("../output/output.json");
    cereal::JSONOutputArchive oarchive(outputFile);
    result.serialize(oarchive);
    outputFile.flush();
    outputFile.close();

	return 0;
}

