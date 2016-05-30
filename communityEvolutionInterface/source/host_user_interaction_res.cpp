#include "../stdafx.h"
#include "../header/host_user_interaction_res.h"

using namespace std;

void user_interaction(uint32_t& choice, string &filename, uint32_t menu){
	switch (menu){
	case 0:
		cout << "Choose between:\n";
		cout << "(press 0 to go back)\n";
		cout << "1: Manage Data\n"; // menu 1
		cout << "2: Algorithms\n"; // menu 2
		cout << "3: Display Data\n"; // menu 3
		cout << "4: Help\n"; // menu 4
		cout << "5: Exit\n"; // menu 5
		cin >> choice;
		break;
	case 1:
		cout << "Manage data:\n";
		cout << "Choose between..\n";
		cout << "1: Set Defaults\n";
		cout << "2: Load Data\n";
		cout << "3: Store Data\n";
		cout << "4: Display Files\n";
		cin >> choice;
		break;
	case 11:
		cout << "Set Defaults: \n";
		cout << "Please wait..\n";
		break;
	case 1101:
		cout << "Load Defaults: \n";
		cout << "Problem loading defaults. Check whether default files exist\n";
		break;
	case 12:
		cout << "Load Data: \n";
		cout << "Choose between..\n";
		cout << "1: Load Raw Data\n";
		cout << "2: Load pairs\n";
		cout << "3: Load snapshots\n";
		cin >> choice;
		break;
	case 1201:
		cout << "Current files:\n";
		cout << "------------- \n";
		break;
	case 1202:
		cout << "------------- \n";
		cout << "Pick one\n";
		cin >> choice;
		cout << "Please wait..\n";
		break;
	case 121:
		cout << "Load Raw Data: \n";
		cout << "Choose between..\n";
		cout << "1: Convert Edges (node to node) \n";
		cout << "2: Convert CSV (Date, Node, Thread) \n";
		cin >> choice;
		break;
	case 1211:
		cout << "Convert Edges: \n";
		break;
	case 12111:
		cout << "Split data in slices? 0: No 1: Yes\n";
		cin >> choice;
		break;
	case 12112:
		cout << "Please enter size of each slice (example: 10000)\n";
		cin >> choice;
		break;
	case 1212:
		cout << "Convert CSV: \n";
		break;
	case 1212001:
		cout << "Do you want to specify timing? 0: No 1: Yes\n";
		cin >> choice;
		break;
	case 1212002:
		cout << "Start date, year: \n";
		cin >> choice;
		break; 
	case 1212003:
		cout << "Start date, month: \n";
		cin >> choice;
		break;
	case 1212004:
		cout << "Start date, day: \n";
		cin >> choice;
		break;
	case 1212005:
		cout << "Final date, year: \n";
		cin >> choice;
		break;
	case 1212006:
		cout << "Final date, month: \n";
		cin >> choice;
		break;
	case 1212007:
		cout << "Final date, day: \n";
		cin >> choice;
		break;
	case 121201:
		cout << "Please name number of lines to read (example: 5000, 0 for all) \n";
		cin >> choice;
		break;
	case 121202:
		cout << "Please name size of interval \n";
		cin >> choice;
		break;
	case 121203:
		cout << "Please name size of overlap \n";
		cin >> choice;
		break;
	case 122:
		cout << "Load Pairs: \n";
		break;
	case 123:
		cout << "Load Communities: \n";
		break;
	case 13:
		cout << "Store Data: \n";
		cout << "Choose between..\n";
		cout << "1: Store Pairs\n";
		cout << "2: Store Communities\n";
		//cout << "3: Store results\n";
		cin >> choice;
		break;
	case 1301:
		cout << "Store in binary format? 0: No 1: Yes\n";
		cin >> choice;
		break;
	case 131:
		cout << "Store Pairs: \n";
		cout << "Enter filename (example: raw100x14x3 lines-interval-overlap)\n";
		cin >> filename;
		cout << "Please wait..\n";
		break;
	case 132:
		cout << "Store Communities: \n";
		cout << "Enter filename (example: snaps100x14x3 lines-interval-overlap)\n";
		cin >> filename;
		cout << "Please wait..\n";
		break;
	case 140:
		cout << "Current files:\n";
		cout << "------------- \n";
		break;
	case 1401:
		cout << "------------- \n";
		break;
	case 2:
		cout << "Manage calculation:\n";
		cout << "Choose between..\n";
//		cout << "1: Generate snapshots via CPU, Clique-algorithmus \n";
//		cout << "2: Generate snapshots via GPU, Clique-algorithmus \n";
//		cout << "3: Generate merged snapshots via CPU, Clique-algorithmus \n";
//		cout << "4: Generate merged snapshots via GPU, Clique-algorithmus \n";
		cout << "5: Analyse snapshots via CPU, Event extraction \n";
		cout << "6: Analyse snapshots via GPU, Event extraction \n";
		cout << "7: Extract snapshots via Zhang Propinquity CPU \n";
		cout << "8: Extract snapshots via Zhang Propinquity GPU \n";
		cin >> choice;
		break;
	case 25:
		cout << "Analyse snapshots via CPU, Event extraction: \n";
		cout << "Measure time? 0: No 1: Yes\n";
		cin >> choice;
		cout << "Input value for kappa (merge/split boundary, example: 0.8) \n";
		break;
	case 26:
		cout << "Analyse snapshots via GPU, Event extraction: \n";
		cout << "Measure time? 0: No 1: Yes\n";
		cin >> choice;
		cout << "Input value for kappa (merge/split boundary, example: 0.8) \n";
		break;
	case 26001:
		cout << "Store results? 0: No 1: Yes\n";
		cin >> choice;
		break;
	case 2601:
		cout << "Display results? 0: No 1: Yes\n";
		cin >> choice;
		break;
	case 27:
		cout << "Analyse snapshots via Zhang Propinquity CPU: \n";
		cout << "Measure time? 0: No 1: Yes\n";
		cin >> choice;
		break;
	case 28:
		cout << "Analyse snapshots via Zhang Propinquity GPU: \n";
		cout << "Measure time? 0: No 1: Yes\n";
		cin >> choice;
		break;
	case 2801:
		cout << "Set Thresholds, alpha, beta (example: 2, 3) \n";
		break;
	case 2802:
		cout << "Set number of iterations (example: 3) \n";
		cin >> choice;
		break;
	case 3:
		cout << "Display Data\n"; 
		cout << "Choose between..\n";
		cout << "1: Display Pairs \n";
		cout << "2: Display Snaps \n";
		cin >> choice;
		break;
		/*
	case 20: "Please wait..\n";
		break;*/
	case 5:
		cout << "Help\n"; // menu 3
		cout << "1: How to use\n";
		cout << "2: Example\n";
		cin >> choice;
		break;
	case 100:
		cout << "Was not successful\n";
		break;
	case 101:
		cout << "Was successful\n";
		break;
	case 102:
		cout << "Please wait..\n";
		break;
	}
	std::cout << "\n";
}