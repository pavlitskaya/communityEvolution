#include "../stdafx.h"
#include <data_source.h>
#include <data_info.h>

#include <omp.h>
#include <vector>
#include <string>
#include <sstream>

#include "ResultItem.h"

//#define GPU

void communityDetection(std::vector<std::string>& filenames) {
    if (DISPLAY_MEMORY)display_device_memory();

    ResultItem* result = new ResultItem();
    std::stringstream snaps_out_stream;

#ifdef GPU
    for (size_t i=0; i<filenames.size(); i++) {
#else
    //#pragma omp parallel for shared(result)
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

        uint32_t iterations = 3; // TODO: remove magic

#ifdef GPU
            Timing::create_time(6);
            Timing::start_time(6);
            Timing::start_time_cpu(6);
            Threshold threshold = Threshold(2, 3); // TODO: remove magic
            if (algorithm_propinquity(source_raw, source_snaps, 0, 0, threshold, 0, iterations, 0)) {
                std::cout << "Detection successful." << std::endl;

                for (size_t snap_i=0; snap_i < source_snaps.get_snaps().size(); snap_i++) {
                    snaps_out_stream << "# Snapshot " << snap_i+1 << ", " << source_snaps.get_snap(snap_i).size() << " communities" << std::endl;
                    for (size_t comm_i=0; comm_i<source_snaps.get_snap(snap_i).size(); comm_i++) {
                        auto snap_snaps = source_snaps.get_snap(snap_i);
                        for (auto item : snap_snaps[comm_i]) {
                            snaps_out_stream << item << " ";
                        }
                        snaps_out_stream << std::endl;
                    }
                }
                snaps_out_stream << std::endl;

            } else {
                std::cerr << "Community detection returned FALSE. Stopping execution." << std::endl;
                return 1;
            }

            Timing::stop_time(6);
            Timing::stop_time_cpu(6);
#else
            Timing::start_time_cpu(7);
            comevohost::Threshold host_threshold = comevohost::Threshold(2, 3);
            comevohost::algorithm_propinquity(source_raw, source_snaps, 0, 0, host_threshold, 0, iterations, 0);

            Timing::stop_time_cpu(7);
#endif

        std::unordered_map<std::string, std::vector<snapshot_t>> map;
        map.insert(std::pair<std::string, std::vector<snapshot_t>>(std::string(file), source_snaps.get_snaps()));
        result->add_snapshots(map);

        std::cout << "----------" << std::endl;

        std::ofstream statusOutFile("../output/status.txt");
        statusOutFile << "Finished file " << file << std::endl;
        statusOutFile.flush();
        statusOutFile.close();

    }

    std::ofstream statusOutFile("../output/status.txt");
    statusOutFile << "Finished detection. Preparing output." << std::endl;
    statusOutFile.flush();
    statusOutFile.close();

    time_t t = time(0);
    std::cout << "Saving JSON" << std::endl;
    std::ofstream outputFile("../output/output-"+std::to_string(t)+".json");

    for (auto snap : result->snapshots) {
        outputFile << "{\"snapshot\": \"" << snap.begin()->first << "\", ";
        outputFile << "\"communities\": [";
        bool commComma = false;
        for (auto comm : snap.begin()->second.at(0)) {
            if (!commComma) { commComma = true; }
            else { outputFile << ", "; }
            outputFile << "[";

            bool comma = false;
            for (auto entry : comm) {
                if (!comma) { comma = true; }
                else { outputFile << ", "; }
                outputFile << entry;
            }

            outputFile << "]";
        }
        outputFile << "] }" << std::endl;
    }

    outputFile.flush();
    outputFile.close();

    std::cout << "Saving snapshots for event extraction input." << std::endl;
    std::string snaps_filename = "bachelor_snaps-" + std::to_string(t) + ".txt";
    std::ofstream snapsOutFile("snaps/" + snaps_filename);
    snapsOutFile  << snaps_out_stream.rdbuf();
    snapsOutFile.flush();
    snapsOutFile.close();
}

void communityEvolution(std::string& filename) {
    comevo::Source loaded_snaps;
    loaded_snaps.set_source(filename, FileType::SNAPS);
    if (comevohost::algorithm_event_extraction(loaded_snaps, 0.8, 0, true)) {
        std::cout << "Event extraction finished." << std::endl;
    } else {
        std::cerr << "Event extraction failed." << std::endl;
    }
}

/**
 * Run application with at least one flag and filename of the file specifying input file in the end.
 * E.g. ./bachelorInterface -x inputFiles.txt
 *
 * Available flags:
 * -d Detect communities.
 * -e Run community evolution.
 *
 * In case of -x: input file should contain one filename per line specifying files that should be
 * taken as input for the event extraction. Files should be placed in storage/raw directory.
 *
 * In case of -e input file should be the file generated during the event extraction.
 * File should be placed in the storage/snaps directory.
 *
 */
int main(int argc, char* argv[])
{
    std::cout << "Bachelor Evolution" << std::endl << std::endl;

    if (argc < 3) {
        std::cerr << "Too few arguments given. Run program with one flag and filename: -x|-e filename" << std::endl;
        return 2;
    }

    std::string filename = std::string(argv[2]);

    if (std::string(argv[1]).compare(std::string("-d")) == 0) {
        std::cout << "Community detection selected." << std::endl;
        std::vector<std::string> filenames;
        std::ifstream inFiles(filename);
        while (inFiles.good()) {
            std::string newFile;
            std::getline(inFiles, newFile);
            filenames.push_back(newFile);
        }
        std::cout << "Got " << filenames.size() << " input files." << std::endl;
        communityDetection(filenames);

        return 0;
    }

    if (std::string(argv[1]).compare(std::string("-e")) == 0) {
        std::cout << "Community evolution selected." << std::endl;

        std::string inputFile(argv[2]);
        communityEvolution(inputFile);

        return 0;
    }

    std::cerr << "Didn't understand what to do. Rething your flags input." << std::endl;

	return 0;
}

