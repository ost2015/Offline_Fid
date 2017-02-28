// General
#include <iostream>
#include <stdio.h>
#include <cstdlib>
#include <chrono>
#include <cmath>
#include <string.h>
#include <inttypes.h>
#include <fstream>
#include <signal.h>
#include <time.h>
#include "windows.h"
#include "Globals.h"
#include "Sensors.h"
#include "OpticalFlow.h"
#include "opencv2\opencv.hpp"
#include "opencv2/video/tracking.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/videoio/videoio.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "pthread.h"

using namespace std::chrono;
using namespace cv;

int main(int argc, char **argv) {
	cout << "reading from input file" << endl;
	open_data(argv[1]);
	pthread_t update;
	pthread_create(&update, NULL, updateSensors, NULL);
	Sleep(100);
	OpticalFlow(argv[1]);
#ifdef SHOW_VID
	while (!end_of_file){
		cout << "Pitch = " << eulerFromSensors.pitch << ", Roll = " << eulerFromSensors.roll << ", Yaw = " << eulerFromSensors.yaw << endl;
		if (!currentframe.empty()){
			imshow("frame", currentframe);
			waitKey(100);
		}
	}
#endif
	close_data();
	return 1;
}