// General
#include <iostream>
#include <stdio.h>
#include <cstdlib>
#include <time.h>
#include "windows.h"
#include <cmath>
#include <string.h>
#include <fstream>
#include "opencv2/video/tracking.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/videoio/videoio.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "Globals.h"

// Namespaces
using std::string;
using namespace std;
using namespace cv;

//data files
#ifdef OFFLINE
std::ifstream *IMU;
std::ifstream *VID_timestamp;
VideoCapture *VIDEO;

//Global parameters to update
int end_of_file;
float deltaT;
#endif

gpsCoords currGPSCoords;
gpsCoords initGPSCoords;
euler_angles eulerFromSensors;
euler_angles prevEulerFromSensors;
atomic<bool> eulerSpeedChanged;//dont know what it doest
Mat currentframe;
float distanceSonar;
float offset;

//Functions
void *open_data(char* path){
	//initialize
	char File_name_IMU[50];
	char File_name_VID_timestamp[50];
	char File_name_VIDEO[50];
	//build file name
	strcpy_s(File_name_IMU, path);
	strcat_s(File_name_IMU, "\\IMU.csv");
	strcpy_s(File_name_VID_timestamp, path);
	strcat_s(File_name_VID_timestamp, "\\VID_timestamp.csv");
	strcpy_s(File_name_VIDEO, path);
	strcat_s(File_name_VIDEO, "\\VIDEO.MP4");
	//open files
	IMU = new std::ifstream(File_name_IMU, std::ifstream::in);
	VID_timestamp = new std::ifstream(File_name_VID_timestamp, std::ifstream::in);
	*VID_timestamp >> deltaT;
	VIDEO = new VideoCapture(File_name_VIDEO);
	return NULL;
}
void *updateSensors(void *args){
	float video_time=0,file_time;
	float pitch = 0, roll = 0, yaw = 0, alt = 0;
	float AccX = 0, AccY = 0, AccZ = 0;
	//Future variables gyro_x = 0, gyro_y = 0, gyro_z = 0, gravity_x = 0, gravity_y = 0, gravity_z = 0;
	char comma;
	double gpslon = 0, gpslat = 0;
	Mat jank;
	video_time = 0;
	//first pull
	end_of_file = 0;
	*IMU >> file_time >> comma >> gpslon >> comma >> gpslat >> comma >> alt >> comma >> AccX >> comma >> AccY >> comma >> AccZ >> comma >> roll >> comma >> pitch >> comma >> yaw;
	eulerFromSensors.pitch = pitch;
	eulerFromSensors.roll = roll;
	eulerFromSensors.yaw = yaw;
	currGPSCoords.lon = gpslon;
	currGPSCoords.lat = gpslat;
	initGPSCoords = currGPSCoords;
	distanceSonar = alt;
	offset = file_time;
	eulerSpeedChanged.store(true);//dont know what it does
	*VIDEO >> currentframe;
	jank = currentframe;
	*VID_timestamp >> video_time;
	//loop pull
	while (!(IMU->eof())){
		if (init){
			prevEulerFromSensors = eulerFromSensors;
			*IMU >> file_time >> comma >> gpslon >> comma >> gpslat >> comma >> alt >> comma >> AccX >> comma >> AccY >> comma >> AccZ >> comma >> roll >> comma >> pitch >> comma >> yaw;
			eulerFromSensors.pitch = pitch;
			eulerFromSensors.roll = roll;
			eulerFromSensors.yaw = yaw;
			currGPSCoords.lon = gpslon;
			currGPSCoords.lat = gpslat;
			eulerSpeedChanged.store(true);
			distanceSonar = alt;
			offset = file_time;
			//video
			while (file_time + deltaT > video_time && (!currentframe.empty() || !jank.empty() || !VID_timestamp->eof())){
				*VIDEO >> jank;
				*VID_timestamp >> video_time;
			}
			*VIDEO >> currentframe;
			*VID_timestamp >> video_time;
			if (currentframe.empty() || VID_timestamp->eof()){
				end_of_file = 1;
				return NULL;
			}
			Sleep(100);
		}
	}
	end_of_file = 1;
	return NULL;
}
void close_data(){
	IMU->close();
	VID_timestamp->close();
	return;
}