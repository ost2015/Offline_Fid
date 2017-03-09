#include <atomic>
#include "opencv2/video/tracking.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/videoio/videoio.hpp"
#include "opencv2/highgui/highgui.hpp"
#define WIDTH_RES 720
#define HEIGHT_RES 480
#define PI 3.14159265

using namespace cv;

/* Structs Declaration */
#ifndef GLOBALS_H_
#define GLOBALS_H_
typedef struct {
	float roll; /*< Roll angle (rad, -pi..+pi)*/
	float pitch; /*< Pitch angle (rad, -pi..+pi)*/
	float yaw; /*< Yaw angle (rad, -pi..+pi)*/
	float rollspeed;
	float pitchspeed;
	float yawspeed;
}euler_angles;

typedef struct{
	double x;
	double y;
}locationStruct;

typedef struct{
	double x;
	double y;
	double z;
}gyro;

typedef struct{
	double lat;
	double lon;
	double alt;
}gpsCoords;
#endif
extern int end_of_file;

// location of the UAV
extern locationStruct currLocation;
extern locationStruct lastFlowStepSections[4];
extern locationStruct lastFlowStep;
extern locationStruct gpsLocation;
// struct of Euler angles
extern euler_angles eulerFromSensors;
extern euler_angles prevEulerFromSensors;
extern gyro GyroFromSensors;
extern std::atomic<bool> eulerSpeedChanged;
// distance- input from sensor
extern float prevDistanceSonar;
extern float distanceSonar;
#ifdef OFFLINE
//Video for offline mode
extern Mat currentframe;
extern Mat prevframe;
#endif
// flag- active operation
extern int active;
extern int init;
// GPS initial and current coordinates
extern gpsCoords currGPSCoords;
extern gpsCoords initGPSCoords;
// flag- stop opticalFlow
extern int end_of_file;
// global timestamp
extern float offset;