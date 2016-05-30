#include "../stdafx.h"
#include "../header/host_user_interaction.h"

using namespace comevo;

void interact_with_user(){
	uint32_t choice, remember;
	string filename;
	U32 n, n_oS;
	Source source_raw;
	Source source_snaps;
	std::vector<uint32_t> parameter;
	dirent file;
	float kappa;
	Threshold threshold(2,3);
	comevohost::Threshold host_threshold(2, 3);
	uint32_t iterations;
	clock_t begin, end;
	uint32_t storeInFile;

	if (source_raw.set_source("bigPairs100x14x3.txt", PAIRS) &&
		source_snaps.set_source("bigSnaps100x14x3.txt", SNAPS)){
	}
	else
		user_interaction(choice, filename, 1101);

	while (true){
		user_interaction(choice, filename, 0);
		switch (choice){
			// manage data
		case 1:
			user_interaction(choice, filename, 1);
			switch (choice){

				// set defaults
			case 1:
				user_interaction(choice, filename, 11);
				if (source_raw.set_source("bigPairs100x14x3.txt", PAIRS) &&
					source_snaps.set_source("bigSnaps100x14x3.txt", SNAPS)){
					user_interaction(choice, filename, 101);
				}
				else
					user_interaction(choice, filename, 100);
				break;

				/// border
				// load data
			case 2:
				user_interaction(choice, filename, 12);
				switch (choice){
					// Load Raw Data
				case 1:
					parameter.clear();
					// pick file
					user_interaction(choice, filename, 1201);
					display_files(RAW);
					user_interaction(choice, filename, 1202);
					if (!get_file(RAW, choice, file)){
						user_interaction(choice, filename, 100);
						break;
					}
					filename = file.d_name;

					user_interaction(choice, filename, 121);
					switch (choice){

						// Convert Edges
					case 1:
						user_interaction(choice, filename, 1211);
						user_interaction(choice, filename, 12111);
						if (choice == 1){
							user_interaction(choice, filename, 12112);
							parameter.push_back(1);
							parameter.push_back(choice);
						}
						user_interaction(choice, filename, 102);
						if (source_raw.set_source(filename, RAW, EDGES, parameter))
							user_interaction(choice, filename, 101);
						else
							user_interaction(choice, filename, 100);
						break;

						// Convert CSV
					case 2:
						user_interaction(choice, filename, 1212);
						tm _from = { 0, 0, 0, 1, 0, 100, 0, 0, 0 };
						tm _to = { 0, 0, 0, 1, 0, 115, 0, 0, 0 };
						user_interaction(choice, filename, 1212001); // specify time?
						if (choice == 1){
							user_interaction(choice, filename, 1212002); // start date, year:
							_from.tm_year = choice - 1900;
							user_interaction(choice, filename, 1212003); // start date, month:
							_from.tm_mon = choice - 1;
							user_interaction(choice, filename, 1212004); // start date, day:
							_to.tm_mday = choice;
							
							user_interaction(choice, filename, 1212005); // end date, year:
							_to.tm_year = choice - 1900;
							user_interaction(choice, filename, 1212006); // end date, month:
							_to.tm_mon = choice - 1;
							user_interaction(choice, filename, 1212007); // end date, day:
							_to.tm_mday = choice;

						}
                        time_t from = max(mktime(&_from), (time_t)0);
						time_t to = mktime(&_to);

						user_interaction(choice, filename, 121201);
						parameter.push_back(choice); // limit
						parameter.push_back(from); // from
						parameter.push_back(to); // to
						user_interaction(choice, filename, 121202);
						parameter.push_back(choice); // interval
						user_interaction(choice, filename, 121203);
						parameter.push_back(choice); // overlap
						user_interaction(choice, filename, 102);
						if (source_raw.set_source(filename, RAW, CSV, parameter))
							user_interaction(choice, filename, 101);
						else
							user_interaction(choice, filename, 100);
						std::vector<pairs_t> res_pairs = source_raw.get_edges();
						break;
					}
					cout << endl;
					cout << "Number of snapshots: " << source_raw.get_m().size() << endl;
					cout << "Total nodes: " << source_raw.get_total_nodes() << endl;
					cout << "Snapshot with max nodes: " << source_raw.get_max_nodes() << endl;
					cout << "Average nodes: " << source_raw.get_avg_nodes() << endl;
					cout << "Total edges: " << source_raw.get_total_edges() << endl;
					cout << "Snapshot with max edges: " << source_raw.get_max_edges() << endl;
					cout << "Average edges: " << source_raw.get_avg_edges() << endl;
					cout << endl;
					break;

				// Load Pairs
				case 2:
					user_interaction(choice, filename, 122);
					// pick file
					user_interaction(choice, filename, 1201);
					display_files(PAIRS);
					user_interaction(choice, filename, 1202);
					if (!get_file(PAIRS, choice, file)){
						user_interaction(choice, filename, 100);
						break;
					}
					filename = file.d_name;

					source_raw.set_source(filename, PAIRS);
					break;

				// Load Communities
				case 3:
					user_interaction(choice, filename, 123);
					user_interaction(choice, filename, 1201);
					display_files(SNAPS);
					user_interaction(choice, filename, 1202);
					if (!get_file(SNAPS, choice, file)){
						user_interaction(choice, filename, 100);
						break;
					}
					filename = file.d_name;

					source_snaps.set_source(filename, SNAPS);
					break;
				}
				break;

			// Store Data
			case 3:
				user_interaction(choice, filename, 13);
				switch (choice){
				// Store Pairs
				case 1:
					user_interaction(choice, filename, 131);
					user_interaction(choice, filename, 1301);
					if (source_raw.store_in_file(filename, choice))
						user_interaction(choice, filename, 101);
					else
						user_interaction(choice, filename, 100);
					break;
				// Store Communities
				case 2:
					user_interaction(choice, filename, 132);
					user_interaction(choice, filename, 1301);
					if (source_snaps.store_in_file(filename, choice))
						user_interaction(choice, filename, 101);
					else
						user_interaction(choice, filename, 100);
					break;
				}

			// display files
			case 4:
				user_interaction(choice, filename, 140);
				display_files(ALLFILES);
				user_interaction(choice, filename, 1401);
				break;
			}
			break;

		// algorithms
		case 2:
			user_interaction(choice, filename, 2);
			switch (choice){
			// event extraction
			case 5:
				user_interaction(choice, filename, 25);
				cin >> kappa;
				remember = choice;
				user_interaction(choice, filename, 26001);
				storeInFile = 0;
				if (choice == 1)
					storeInFile = 1;

				user_interaction(choice, filename, 2601);
				if (remember){
					Timing::start_time_cpu(5);
				}
				if (comevohost::algorithm_event_extraction(source_snaps, kappa, choice, storeInFile)){
					if (remember)
						Timing::stop_time_cpu(5);
					user_interaction(choice, filename, 101);
				}
				else
					user_interaction(choice, filename, 100);
				break;

			case 6:
				user_interaction(choice, filename, 26);
				cin >> kappa;
				remember = choice;
				user_interaction(choice, filename, 26001);
				storeInFile = 0;
				if (choice == 1)
					storeInFile = 1;
				user_interaction(choice, filename, 2601);
				if (remember){
					Timing::create_time(6);
					Timing::start_time(6);
					Timing::start_time_cpu(6);
				}
				if (algorithm_event_extraction(source_snaps, kappa, choice, storeInFile)){
					if (remember){
						Timing::stop_time(6);
						Timing::stop_time_cpu(6);
					}
					user_interaction(choice, filename, 101);
				}
				else
					user_interaction(choice, filename, 100);
				break;

			// propinquity analysis
			case 7:
				user_interaction(choice, filename, 27);
				remember = choice;
				user_interaction(choice, filename, 2801);
				cin >> iterations;
				cin >> choice;
				host_threshold = comevohost::Threshold(iterations, choice);
				user_interaction(choice, filename, 2802);
				iterations = choice;
				if (remember){
					Timing::start_time_cpu(7);
				}
				if (comevohost::algorithm_propinquity(source_raw, source_snaps, 0, 0, host_threshold, 0, iterations, 0)){
					if (remember)
						Timing::stop_time_cpu(7);
					cout << endl;
					cout << "Number of snapshots: " << source_snaps.get_m().size() << endl;
					cout << "Total number of communities: " << source_snaps.get_total_communities() << endl;
					cout << "Maximum number of communities: " << source_snaps.get_max_communities() << endl;
					cout << "Average number of communities: " << source_snaps.get_avg_communities() << endl;

					cout << endl;
					user_interaction(choice, filename, 101);
				}
				else
					user_interaction(choice, filename, 100);
				break;

			case 8: 
				user_interaction(choice, filename, 28);
				remember = choice;
				user_interaction(choice, filename, 2801);
				cin >> iterations;
				cin >> choice;
				threshold = Threshold(iterations, choice);
				user_interaction(choice, filename, 2802);
				iterations = choice;
				if (remember){
					Timing::create_time(6);
					Timing::start_time(6);
					Timing::start_time_cpu(6);
				}
				if (algorithm_propinquity(source_raw, source_snaps, 0, 0, threshold, 0, iterations, 0)){
					if (remember){
						Timing::stop_time(6);
						Timing::stop_time_cpu(6);
					}
					cout << endl;
					cout << "Number of snapshots: " << source_snaps.get_m().size() << endl;
					cout << "Total number of communities: " << source_snaps.get_total_communities() << endl;
					cout << "Maximum number of communities: " << source_snaps.get_max_communities() << endl;
					cout << "Average number of communities: " << source_snaps.get_avg_communities() << endl;

					cout << endl;

					user_interaction(choice, filename, 101);
				}
				else
					user_interaction(choice, filename, 100);
				break;
			}
			break;

		// Display Data
		case 3:
			user_interaction(choice, filename, 3);
			switch (choice){
			case 1:
				source_raw.display();
				break;
			case 2:
				source_snaps.display();
				break;
			}
			break;
			// manage help
		case 4:
			break;
			// manage exit
		case 5:
			//source_raw.~Source;
			//source_snaps.~Source;
			exit(EXIT_SUCCESS);
		}
	}
}

