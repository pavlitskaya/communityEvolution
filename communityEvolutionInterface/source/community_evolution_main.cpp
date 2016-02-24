#include "../stdafx.h"
#include "../header/host_user_interaction.h"
#include <data_info.h>


int main()
{
	printf("\nCommunity Analysis\n\n");
	if (DISPLAY_MEMORY)display_device_memory();

	while (true){
		Beep(523, 500);
		interact_with_user();
		system("pause");
	}

	return 0;
}

