# communityEvolution

Commmunity Evolution is a project with the target to provide a framework analysing large datasets with the support of a multicore GPU framework. 

check the howtouse.pdf for instructions on how to setup this project. 

### Using cmake project
Tested on Windows with Visual Studio 2013 and Linux with CUDA 6.5, gcc5.2 and gcc4.8
#### Requirements
* CUDA installed
* dirent (https://github.com/tronkko/dirent) installed (already included for Windows, install manually for Linux and Mac)

#### Build
* create build directory inside the project
* run ```cmake ..```
* if no errors and project files are generated, open project files and build (on Linux: run ```make```)
* enjoy!

#### Run
Run from the storage directory, e.g. if the project was built in build directory, 
run ```../build/communityEvolutionInterface/communityEvolution```

