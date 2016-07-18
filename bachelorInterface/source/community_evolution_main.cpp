#include "../stdafx.h"
#include "../header/host_user_interaction.h"
#include <data_source.h>

#include <data_info.h>

#define GPU true

int main()
{
    printf("\nBachelor Evolution\n\n");
	if (DISPLAY_MEMORY)display_device_memory();

    comevo::Source source_raw;
    comevo::Source source_snaps;
    std::vector<uint32_t> parameter;
    parameter.push_back(1);
    parameter.push_back(0);
    source_raw.set_source(std::string("test.txt"), RAW, EDGES, parameter);

    cout << "Total nodes: " << source_raw.get_total_nodes() << endl;
    cout << "Snapshot with max nodes: " << source_raw.get_max_nodes() << endl;
    cout << "Average nodes: " << source_raw.get_avg_nodes() << endl;
    cout << "Total edges: " << source_raw.get_total_edges() << endl;
    cout << "Snapshot with max edges: " << source_raw.get_max_edges() << endl;
    cout << "Average edges: " << source_raw.get_avg_edges() << endl;
    cout << endl;

    uint32_t iterations = 3; // TODO: remove magic

    if (GPU) {
        Timing::create_time(6);
        Timing::start_time(6);
        Timing::start_time_cpu(6);
	Threshold threshold = Threshold(2, 3);
        algorithm_propinquity(source_raw, source_snaps, 0, 0, threshold, 0, iterations, 0);

        Timing::stop_time(6);
        Timing::stop_time_cpu(6);
    } else {
        Timing::start_time_cpu(7);
	comevohost::Threshold host_threshold = comevohost::Threshold(2, 3);
        comevohost::algorithm_propinquity(source_raw, source_snaps, 0, 0, host_threshold, 0, iterations, 0);

        Timing::stop_time_cpu(7);
    }

    cout << "Number of snapshots: " << source_snaps.get_m().size() << endl;
    cout << "Total number of communities: " << source_snaps.get_total_communities() << endl;
    cout << "Maximum number of communities: " << source_snaps.get_max_communities() << endl;
    cout << "Average number of communities: " << source_snaps.get_avg_communities() << endl;

    cout << endl;

	return 0;
}

