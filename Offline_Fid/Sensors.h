// General
#include <iostream>
#include <stdio.h>
#include <cstdlib>
#include <cmath>
#include <string.h>
#include <fstream>
#include "opencv2/video/tracking.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/videoio/videoio.hpp"
#include "opencv2/highgui/highgui.hpp"

// Namespaces
using std::string;
using namespace std;

void *open_data(char* path);
void *updateSensors(void *args);
void close_data();